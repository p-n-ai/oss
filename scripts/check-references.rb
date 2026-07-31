#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require_relative "lib/oss_validation"

def duplicate_values(values)
  values.compact.group_by(&:itself).select { |_value, items| items.length > 1 }.keys
end

def topic_stem(path)
  path.basename.to_s.sub(/\.(assessments|examples)\.ya?ml\z/, "").sub(/\.ya?ml\z/, "")
end

FORBIDDEN_TOPIC_ALIASES = %w[
  mastery_block
  mastery_criteria
  mastery_parameters
  spaced_repetition
  teaching_metadata
  teaching_sequence
  pedagogical_sequence
  common_misconceptions
  misconceptions
].freeze

syllabi, syllabus_duplicates = OssValidation.build_syllabus_catalog
topics, _topics_by_id, topic_duplicates = OssValidation.build_topic_catalog(syllabi)
subjects = {}
subject_grades = {}
concepts = {}
topic_contracts = {}
errors = []

syllabus_duplicates.each do |duplicate|
  paths = duplicate.fetch("paths").map { |path| OssValidation.relative_path(path) }.join(", ")
  errors << "duplicate syllabus id #{duplicate.fetch('syllabus_id')}: #{paths}"
end

topic_duplicates.each do |duplicate|
  paths = duplicate.fetch("paths").map { |path| OssValidation.relative_path(path) }.join(", ")
  errors << "duplicate global topic id #{duplicate.fetch('topic_id')}: #{paths}"
end

syllabi.each_value do |syllabus|
  path = syllabus.fetch("path")
  syllabus_id = syllabus.fetch("id")
  country_id = syllabus.fetch("country_id")
  ref = OssValidation.relative_path(path)

  unless path.dirname.basename.to_s == syllabus_id
    errors << "#{ref}: syllabus directory must match id #{syllabus_id}"
  end
  unless path.dirname.parent.basename.to_s == country_id
    errors << "#{ref}: country directory must match country_id #{country_id.inspect}"
  end
end

OssValidation.subject_files.each do |path|
  data = OssValidation.load_yaml(path)
  subject_id = data["id"]
  syllabus_id = data["syllabus_id"]
  country_id = data["country_id"]
  ref = OssValidation.relative_path(path)

  if subject_id.nil? || subject_id.empty?
    errors << "#{ref}: missing subject id"
    next
  end
  if subjects.key?(subject_id)
    errors << "duplicate global subject id #{subject_id}: #{subjects.fetch(subject_id).fetch('path')}, #{ref}"
    next
  end

  syllabus = syllabi[syllabus_id]
  errors << "#{ref}: unknown syllabus_id #{syllabus_id.inspect}" if syllabus.nil?
  errors << "#{ref}: subject directory must match id #{subject_id}" unless path.dirname.basename.to_s == subject_id
  if syllabus && path.dirname.parent != syllabus.fetch("family_root")
    errors << "#{ref}: subject path is outside syllabus #{syllabus_id}"
  end
  if syllabus && country_id != syllabus.fetch("country_id")
    errors << "#{ref}: country_id #{country_id.inspect} disagrees with syllabus #{syllabus_id}"
  end

  subjects[subject_id] = {
    "id" => subject_id,
    "syllabus_id" => syllabus_id,
    "country_id" => country_id,
    "path" => path,
    "root" => path.dirname
  }
end

OssValidation.subject_grade_files.each do |path|
  data = OssValidation.load_yaml(path)
  grade_id = data["id"]
  subject_id = data["subject_id"]
  syllabus_id = data["syllabus_id"]
  country_id = data["country_id"]
  ref = OssValidation.relative_path(path)

  if grade_id.nil? || grade_id.empty?
    errors << "#{ref}: missing subject-grade id"
    next
  end
  if subject_grades.key?(grade_id)
    errors << "duplicate global subject-grade id #{grade_id}: #{subject_grades.fetch(grade_id).fetch('path')}, #{ref}"
    next
  end

  subject = subjects[subject_id]
  errors << "#{ref}: unknown subject_id #{subject_id.inspect}" if subject.nil?
  errors << "#{ref}: subject-grade directory must match id #{grade_id}" unless path.dirname.basename.to_s == grade_id
  if subject && path.dirname.parent != subject.fetch("root")
    errors << "#{ref}: subject-grade path is outside subject #{subject_id}"
  end
  if subject && subject.fetch("syllabus_id") != syllabus_id
    errors << "#{ref}: syllabus_id #{syllabus_id.inspect} disagrees with subject #{subject_id}"
  end
  if subject && subject.fetch("country_id") != country_id
    errors << "#{ref}: country_id #{country_id.inspect} disagrees with subject #{subject_id}"
  end

  subject_grades[grade_id] = {
    "id" => grade_id,
    "subject_id" => subject_id,
    "syllabus_id" => syllabus_id,
    "country_id" => country_id,
    "path" => path,
    "root" => path.dirname,
    "declared_topics" => data.key?("topics") ? Array(data["topics"]) : nil
  }
end

syllabi.each do |syllabus_id, syllabus|
  declared = syllabus.fetch("subjects")
  duplicate_values(declared).each do |subject_id|
    errors << "#{syllabus_id}: duplicate declared subject #{subject_id}"
  end

  actual = subjects.values.select { |subject| subject.fetch("syllabus_id") == syllabus_id }.map { |subject| subject.fetch("id") }
  (declared - actual).each { |subject_id| errors << "#{syllabus_id}: missing declared subject #{subject_id}" }
  (actual - declared).each { |subject_id| errors << "#{syllabus_id}: subject #{subject_id} is not declared by syllabus" }
end

topics_by_grade = Hash.new { |hash, key| hash[key] = [] }
topics.each_value do |topic|
  path = topic.fetch("path")
  data = OssValidation.load_yaml(path)
  topic_id = topic.fetch("topic_id")
  ref = OssValidation.relative_path(path)
  grade_root = path.dirname.parent
  grade = subject_grades.values.find { |candidate| candidate.fetch("root") == grade_root }

  FORBIDDEN_TOPIC_ALIASES.each do |field|
    errors << "#{ref}: legacy field #{field} must use the canonical nested representation" if data.key?(field)
  end
  content_standards = Array(data["content_standards"])
  content_standards.each_with_index do |standard, index|
    if standard.is_a?(Hash) && standard.key?("learning_objectives")
      errors << "#{ref}: content_standards[#{index}].learning_objectives must move to root learning_objectives"
    end
  end

  standard_ids = content_standards.map { |standard| standard["id"] if standard.is_a?(Hash) }.compact
  duplicate_values(standard_ids).each do |standard_id|
    errors << "#{ref}: duplicate content standard id #{standard_id}"
  end

  objectives = Array(data["learning_objectives"])
  objective_ids = objectives.map { |objective| objective["id"] if objective.is_a?(Hash) }.compact
  duplicate_values(objective_ids).each do |objective_id|
    errors << "#{ref}: duplicate learning objective id #{objective_id}"
  end
  objectives.each_with_index do |objective, index|
    next unless objective.is_a?(Hash) && objective["content_standard_id"]
    next if standard_ids.include?(objective["content_standard_id"])

    errors << "#{ref}: learning_objectives[#{index}].content_standard_id #{objective['content_standard_id'].inspect} is unknown"
  end
  topic_contracts[topic_id] = {
    "standard_ids" => standard_ids.to_set,
    "objective_ids" => objective_ids.to_set,
    "objective_standard_ids" => objectives.each_with_object({}) do |objective, index|
      next unless objective.is_a?(Hash) && objective["id"]

      index[objective["id"]] = objective["content_standard_id"]
    end
  }

  errors << "#{ref}: filename does not match topic id #{topic_id}" unless topic_stem(path) == topic_id
  if grade.nil?
    errors << "#{ref}: no subject-grade metadata for containing directory"
    next
  end

  {
    "subject_grade_id" => grade.fetch("id"),
    "subject_id" => grade.fetch("subject_id"),
    "syllabus_id" => grade.fetch("syllabus_id")
  }.each do |field, expected|
    actual = data[field]
    errors << "#{ref}: #{field} #{actual.inspect} must match containing #{expected}" unless actual == expected
  end
  if data.key?("country_id") && data["country_id"] != grade.fetch("country_id")
    errors << "#{ref}: country_id #{data['country_id'].inspect} must match containing #{grade.fetch('country_id')}"
  end
  topics_by_grade[grade.fetch("id")] << topic_id

  %w[ai_teaching_notes examples_file assessments_file].each do |field|
    relative_path = data[field]
    next if relative_path.nil? || relative_path.empty?

    linked_path = OssValidation.linked_file(path, relative_path)
    unless linked_path.exist?
      errors << "#{ref}: missing #{field} #{relative_path}"
      next
    end

    next if field == "ai_teaching_notes"

    linked_topic_id = OssValidation.load_yaml(linked_path)["topic_id"]
    unless linked_topic_id == topic_id
      errors << "#{ref}: #{field} points to topic #{linked_topic_id.inspect}, expected #{topic_id}"
    end
  end
end

subject_grades.each_value do |grade|
  declared = grade.fetch("declared_topics")
  if declared.nil?
    errors << "#{grade.fetch('id')}: missing reciprocal topics inventory"
    next
  end

  actual = topics_by_grade.fetch(grade.fetch("id"), [])
  duplicate_values(declared).each do |topic_id|
    errors << "#{grade.fetch('id')}: duplicate declared topic #{topic_id}"
  end
  (declared - actual).each { |topic_id| errors << "#{grade.fetch('id')}: missing declared topic #{topic_id}" }
  (actual - declared).each { |topic_id| errors << "#{grade.fetch('id')}: topic #{topic_id} is not declared" }
end

OssValidation.topic_variant_files.each do |path|
  data = OssValidation.load_yaml(path)
  canonical_path = OssValidation.canonical_path_for_variant(path)
  ref = OssValidation.relative_path(path)
  locale = OssValidation.locale_for_variant(path)

  unless canonical_path && canonical_path.exist?
    errors << "#{ref}: missing canonical topic"
    next
  end

  canonical = OssValidation.load_yaml(canonical_path)
  canonical_contract = topic_contracts.fetch(canonical["id"], {
    "standard_ids" => Set.new,
    "objective_ids" => Set.new
  })
  FORBIDDEN_TOPIC_ALIASES.each do |field|
    errors << "#{ref}: legacy field #{field} must use the canonical nested representation" if data.key?(field)
  end
  localized_standards = Array(data["content_standards"])
  localized_standards.each_with_index do |standard, index|
    if standard.is_a?(Hash) && standard.key?("learning_objectives")
      errors << "#{ref}: content_standards[#{index}].learning_objectives must move to root learning_objectives"
    end
  end

  errors << "#{ref}: id #{data['id'].inspect} differs from canonical #{canonical['id'].inspect}" unless data["id"] == canonical["id"]
  errors << "#{ref}: language #{data['language'].inspect} must match locale directory #{locale}" unless data["language"] == locale
  %w[subject_grade_id subject_id syllabus_id].each do |field|
    errors << "#{ref}: #{field} differs from canonical topic" unless data[field] == canonical[field]
  end

  localized_standard_ids = localized_standards.map do |standard|
    standard["id"] if standard.is_a?(Hash)
  end.compact
  duplicate_values(localized_standard_ids).each do |standard_id|
    errors << "#{ref}: duplicate localized content standard id #{standard_id}"
  end
  localized_standard_ids.each do |standard_id|
    next if canonical_contract.fetch("standard_ids").include?(standard_id)

    errors << "#{ref}: localized content standard #{standard_id} is absent from canonical topic"
  end
  (canonical_contract.fetch("standard_ids") - localized_standard_ids.to_set).each do |standard_id|
    errors << "#{ref}: missing localized content standard #{standard_id}"
  end

  localized_objectives = Array(data["learning_objectives"])
  objective_ids = localized_objectives.map do |objective|
    objective["id"] if objective.is_a?(Hash)
  end.compact
  duplicate_values(objective_ids).each do |objective_id|
    errors << "#{ref}: duplicate localized learning objective id #{objective_id}"
  end
  objective_ids.each do |objective_id|
    next if canonical_contract.fetch("objective_ids").include?(objective_id)

    errors << "#{ref}: localized learning objective #{objective_id} is absent from canonical topic"
  end
  (canonical_contract.fetch("objective_ids") - objective_ids.to_set).each do |objective_id|
    errors << "#{ref}: missing localized learning objective #{objective_id}"
  end
  localized_objectives.each_with_index do |objective, index|
    next unless objective.is_a?(Hash)

    standard_id = objective["content_standard_id"]
    if standard_id && !canonical_contract.fetch("standard_ids").include?(standard_id)
      errors << "#{ref}: learning_objectives[#{index}].content_standard_id #{standard_id.inspect} is absent from canonical topic"
    end
    next unless canonical_contract.fetch("objective_standard_ids").key?(objective["id"])
    next if standard_id == canonical_contract.fetch("objective_standard_ids")[objective["id"]]

    errors << "#{ref}: learning objective #{objective['id']} content_standard_id differs from canonical"
  end
end

companion_groups = {
  assessment: OssValidation.assessment_files,
  assessment_variant: OssValidation.assessment_variant_files,
  example: OssValidation.example_files,
  example_variant: OssValidation.example_variant_files
}
companion_groups.each do |type, paths|
  paths.each do |path|
    data = OssValidation.load_yaml(path)
    ref = OssValidation.relative_path(path)
    topic_id = data["topic_id"]
    stem = topic_stem(path)
    canonical_data = nil
    errors << "#{ref}: topic_id #{topic_id.inspect} must match filename #{stem}" unless topic_id == stem
    errors << "#{ref}: unknown canonical topic #{topic_id.inspect}" unless topics.key?(topic_id)

    if type.to_s.end_with?("_variant")
      canonical_path = OssValidation.canonical_path_for_variant(path)
      unless canonical_path && canonical_path.exist?
        errors << "#{ref}: missing canonical companion file"
      else
        canonical_data = OssValidation.load_yaml(canonical_path)
        canonical_topic = topics[topic_id]
        if canonical_topic && canonical_path.dirname != canonical_topic.fetch("path").dirname
          errors << "#{ref}: canonical companion is outside topic #{topic_id}"
        end
      end
    elsif topics.key?(topic_id) && path.dirname != topics.fetch(topic_id).fetch("path").dirname
      errors << "#{ref}: companion path is outside topic #{topic_id}"
    end

    collection = type.to_s.start_with?("assessment") ? Array(data["questions"]) : Array(data["worked_examples"])
    if type.to_s.start_with?("assessment")
      topic_contract = topic_contracts.fetch(topic_id, { "objective_ids" => Set.new })
      collection.each_with_index do |question, index|
        next unless question.is_a?(Hash)

        if question.key?("options")
          errors << "#{ref}: questions[#{index}].options must move under answer.options"
        end
        unless topic_contract.fetch("objective_ids").include?(question["learning_objective"])
          errors << "#{ref}: questions[#{index}].learning_objective #{question['learning_objective'].inspect} is unknown"
        end
      end
    else
      topic_contract = topic_contracts.fetch(topic_id, { "objective_ids" => Set.new })
      collection.each_with_index do |example, index|
        next unless example.is_a?(Hash) && example["learning_objective"]
        next if topic_contract.fetch("objective_ids").include?(example["learning_objective"])

        errors << "#{ref}: worked_examples[#{index}].learning_objective #{example['learning_objective'].inspect} is unknown"
      end
    end

    if type == :assessment_variant && canonical_data
      canonical_questions = Array(canonical_data["questions"]).each_with_object({}) do |question, index|
        index[question["id"]] = question if question.is_a?(Hash)
      end
      localized_ids = collection.map { |question| question["id"] if question.is_a?(Hash) }.compact

      collection.each do |question|
        next unless question.is_a?(Hash)

        question_id = question["id"]
        canonical_question = canonical_questions[question_id]
        if canonical_question.nil?
          errors << "#{ref}: localized question #{question_id.inspect} has no canonical question"
          next
        end

        unless question["learning_objective"] == canonical_question["learning_objective"]
          errors << "#{ref}: question #{question_id} learning_objective differs from canonical"
        end
        localized_answer_type = question.fetch("answer", {})["type"]
        canonical_answer_type = canonical_question.fetch("answer", {})["type"]
        unless localized_answer_type == canonical_answer_type
          errors << "#{ref}: question #{question_id} answer.type differs from canonical"
        end
      end

      (canonical_questions.keys - localized_ids).each do |question_id|
        errors << "#{ref}: missing localized question #{question_id}"
      end
    end

    if type == :example_variant && canonical_data
      canonical_examples = Array(canonical_data["worked_examples"]).each_with_object({}) do |example, index|
        index[example["id"]] = example if example.is_a?(Hash)
      end
      localized_ids = collection.map { |example| example["id"] if example.is_a?(Hash) }.compact

      collection.each do |example|
        next unless example.is_a?(Hash)

        example_id = example["id"]
        canonical_example = canonical_examples[example_id]
        if canonical_example.nil?
          errors << "#{ref}: localized worked example #{example_id.inspect} has no canonical worked example"
          next
        end
        unless example["learning_objective"] == canonical_example["learning_objective"]
          errors << "#{ref}: worked example #{example_id} learning_objective differs from canonical"
        end
      end

      (canonical_examples.keys - localized_ids).each do |example_id|
        errors << "#{ref}: missing localized worked example #{example_id}"
      end
    end

    item_ids = collection.map { |item| item["id"] if item.is_a?(Hash) }.compact
    duplicate_values(item_ids).each do |item_id|
      label = type.to_s.start_with?("assessment") ? "question" : "worked example"
      errors << "#{ref}: duplicate #{label} id #{item_id}"
    end
  end
end

OssValidation.concept_files.each do |path|
  data = OssValidation.load_yaml(path)
  concept_id = data["id"]
  ref = OssValidation.relative_path(path)
  if concept_id.nil? || concept_id.empty?
    errors << "#{ref}: missing concept id"
    next
  end
  if concepts.key?(concept_id)
    errors << "duplicate global concept id #{concept_id}: #{concepts.fetch(concept_id).fetch('path')}, #{ref}"
    next
  end

  occurrences = Array(data["curricula"]).map do |occurrence|
    next unless occurrence.is_a?(Hash)

    [occurrence["syllabus"], occurrence["topic"]]
  end.compact
  duplicate_values(occurrences).each do |syllabus_id, topic_id|
    errors << "#{concept_id}: duplicate occurrence #{syllabus_id}:#{topic_id}"
  end
  occurrences.each do |syllabus_id, topic_id|
    topic = topics[topic_id]
    errors << "#{concept_id}: unknown syllabus #{syllabus_id.inspect}" unless syllabi.key?(syllabus_id)
    if topic.nil?
      errors << "#{concept_id}: unknown topic #{topic_id.inspect}"
    elsif topic.fetch("syllabus_id") != syllabus_id
      errors << "#{concept_id}: topic #{topic_id} belongs to #{topic.fetch('syllabus_id')}, not #{syllabus_id}"
    end
  end

  concepts[concept_id] = {
    "path" => ref,
    "occurrences" => occurrences
  }
end

topics.each_value do |topic|
  data = OssValidation.load_yaml(topic.fetch("path"))
  source = [topic.fetch("syllabus_id"), topic.fetch("topic_id")]

  Array(data["cross_curriculum"]).each do |link|
    next unless link.is_a?(Hash)

    concept_id = link["concept_id"]
    target = [link["syllabus_id"], link["topic_id"]]
    concept = concepts[concept_id]
    if concept.nil?
      errors << "#{topic.fetch('topic_id')}: unknown cross-curriculum concept #{concept_id.inspect}"
      next
    end
    if target == source
      errors << "#{topic.fetch('topic_id')}: cross-curriculum link cannot target itself"
      next
    end
    if target.first == source.first
      errors << "#{topic.fetch('topic_id')}: cross-curriculum target must use a distinct syllabus"
    end

    target_topic = topics[target.last]
    if target_topic.nil? || target_topic.fetch("syllabus_id") != target.first
      errors << "#{topic.fetch('topic_id')}: unknown cross-curriculum target #{target.join(':')}"
    end

    occurrences = concept.fetch("occurrences")
    errors << "#{topic.fetch('topic_id')}: concept #{concept_id} omits source occurrence" unless occurrences.include?(source)
    errors << "#{topic.fetch('topic_id')}: concept #{concept_id} omits target occurrence" unless occurrences.include?(target)
  end
end

if errors.empty?
  puts "PASS: curriculum references and path identities are consistent"
  puts "- syllabi: #{syllabi.length}"
  puts "- subjects: #{subjects.length}"
  puts "- subject-grades: #{subject_grades.length}"
  puts "- canonical topics: #{topics.length}"
  puts "- canonical topic content contracts aligned: #{topic_contracts.length}"
  puts "- full locale topic variants aligned: #{OssValidation.topic_variant_files.length}"
  puts "- companion files: #{companion_groups.values.sum(&:length)}"
  puts "- assessment objective contracts aligned: #{OssValidation.assessment_files.length + OssValidation.assessment_variant_files.length}"
  puts "- localized assessment variants aligned: #{OssValidation.assessment_variant_files.length}"
  puts "- example objective contracts aligned: #{OssValidation.example_files.length + OssValidation.example_variant_files.length}"
  puts "- localized example variants aligned: #{OssValidation.example_variant_files.length}"
  puts "- concepts: #{concepts.length}"
  puts "- unconsumed field aliases: 0"
  exit 0
end

puts "FAIL: broken curriculum references"
errors.each { |error| puts "- #{error}" }
exit 1
