#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

module OssValidation
  ROOT = Pathname(__dir__).join("..", "..").expand_path
  CURRICULA_ROOT = ROOT.join("curricula")
  CONCEPTS_ROOT = ROOT.join("concepts")
  TAXONOMY_ROOT = ROOT.join("taxonomy")
  TOPIC_ID_PATTERN = /\A(?:[A-Z]{2,3}[0-9]+|[A-Z]{2,3}-[A-Z])-[0-9]{2}\z/

  EXPECTED_INVENTORY = {
    syllabus: 3,
    subject: 89,
    subject_grade: 21,
    topic: 180,
    topic_variant: 53,
    assessment: 115,
    assessment_variant: 53,
    example: 115,
    example_variant: 53,
    concept: 2,
    taxonomy: 0
  }.freeze

  SCHEMAS = {
    syllabus: "schema/syllabus.schema.json",
    subject: "schema/subject.schema.json",
    subject_grade: "schema/subject-grade.schema.json",
    topic: "schema/topic.schema.json",
    topic_variant: "schema/topic-variant.schema.json",
    assessment: "schema/assessments.schema.json",
    assessment_variant: "schema/assessments.schema.json",
    example: "schema/examples.schema.json",
    example_variant: "schema/examples.schema.json",
    concept: "schema/concept.schema.json",
    taxonomy: "schema/taxonomy.schema.json"
  }.freeze

  module_function

  def load_yaml(path)
    data = YAML.safe_load(path.read, permitted_classes: [], aliases: false) || {}
    raise "#{path}: expected YAML object" unless data.is_a?(Hash)

    data
  rescue Psych::SyntaxError => error
    raise "#{path}: YAML parse failed: #{error.message}"
  end

  def content_yaml_files
    [CURRICULA_ROOT, CONCEPTS_ROOT, TAXONOMY_ROOT].flat_map do |root|
      next [] unless root.exist?

      Dir.glob(root.join("**", "*.{yaml,yml}").to_s).map { |path| Pathname(path) }
    end.sort
  end

  def artifact_type(path)
    path = Pathname(path).expand_path
    relative = path.relative_path_from(ROOT)
    parts = relative.each_filename.to_a
    basename = path.basename.to_s

    return :concept if parts.first == "concepts"
    return :taxonomy if parts.first == "taxonomy"
    return nil unless parts.first == "curricula"
    return :syllabus if basename == "syllabus.yaml"
    return :subject if basename == "subject.yaml"
    return :subject_grade if basename == "subject-grade.yaml"

    topics_index = parts.index("topics")
    return nil if topics_index.nil?

    variant = parts[topics_index + 1] == "translations"
    return variant ? :assessment_variant : :assessment if basename.end_with?(".assessments.yaml")
    return variant ? :example_variant : :example if basename.end_with?(".examples.yaml")

    variant ? :topic_variant : :topic
  rescue ArgumentError
    nil
  end

  def artifact_groups
    groups = Hash.new { |hash, key| hash[key] = [] }
    content_yaml_files.each { |path| groups[artifact_type(path)] << path }
    groups.each_value(&:sort!)
    groups
  end

  def files_for(type)
    artifact_groups.fetch(type, [])
  end

  def syllabus_files
    files_for(:syllabus)
  end

  def subject_files
    files_for(:subject)
  end

  def subject_grade_files
    files_for(:subject_grade)
  end

  def topic_files
    files_for(:topic)
  end

  def topic_variant_files
    files_for(:topic_variant)
  end

  def assessment_files
    files_for(:assessment)
  end

  def assessment_variant_files
    files_for(:assessment_variant)
  end

  def example_files
    files_for(:example)
  end

  def example_variant_files
    files_for(:example_variant)
  end

  def concept_files
    files_for(:concept)
  end

  def taxonomy_files
    files_for(:taxonomy)
  end

  def schema_for(path)
    type = artifact_type(path)
    schema = SCHEMAS[type]
    schema && ROOT.join(schema)
  end

  def relative_path(path)
    Pathname(path).expand_path.relative_path_from(ROOT).to_s
  end

  def inventory_errors
    groups = artifact_groups
    errors = []
    unclassified = groups.fetch(nil, [])
    unless unclassified.empty?
      errors << "unclassified YAML: #{unclassified.map { |path| relative_path(path) }.join(', ')}"
    end

    EXPECTED_INVENTORY.each do |type, expected|
      actual = groups.fetch(type, []).length
      next if actual == expected

      errors << "#{type}: expected #{expected}, found #{actual}"
    end

    classified_count = EXPECTED_INVENTORY.keys.sum { |type| groups.fetch(type, []).length }
    expected_total = EXPECTED_INVENTORY.values.sum
    errors << "total: expected #{expected_total}, found #{classified_count}" unless classified_count == expected_total
    errors
  end

  def linked_file(topic_path, relative_path)
    return nil if relative_path.nil? || relative_path.empty?

    Pathname(topic_path).dirname.join(relative_path)
  end

  def canonical_path_for_variant(path)
    path = Pathname(path).expand_path
    parts = path.relative_path_from(ROOT).each_filename.to_a
    topics_index = parts.index("topics")
    return nil unless topics_index && parts[topics_index + 1] == "translations"
    return nil if parts.length <= topics_index + 3

    ROOT.join(*parts[0..topics_index]).join(*parts[(topics_index + 3)..])
  end

  def locale_for_variant(path)
    parts = Pathname(path).each_filename.to_a
    topics_index = parts.index("topics")
    return nil unless topics_index && parts[topics_index + 1] == "translations"

    parts[topics_index + 2]
  end

  def prerequisite_id(reference)
    case reference
    when String
      reference if TOPIC_ID_PATTERN.match?(reference)
    when Hash
      topic_id = reference["id"]
      topic_id if topic_id.is_a?(String) && TOPIC_ID_PATTERN.match?(topic_id)
    end
  end

  def prerequisite_ids(data)
    prerequisites = data["prerequisites"]
    return { "required" => [], "recommended" => [] } unless prerequisites.is_a?(Hash)

    {
      "required" => Array(prerequisites["required"]).map { |reference| prerequisite_id(reference) },
      "recommended" => Array(prerequisites["recommended"]).map { |reference| prerequisite_id(reference) }
    }
  end

  def topic_key(_syllabus_id, topic_id)
    topic_id
  end

  def syllabus_family_root(path)
    Pathname(path).dirname
  end

  def build_syllabus_catalog
    catalog = {}
    duplicates = []

    syllabus_files.each do |path|
      data = load_yaml(path)
      syllabus_id = data["id"]
      next if syllabus_id.nil? || syllabus_id.empty?

      if catalog.key?(syllabus_id)
        duplicates << {
          "syllabus_id" => syllabus_id,
          "paths" => [catalog.fetch(syllabus_id).fetch("path"), path]
        }
        next
      end

      catalog[syllabus_id] = {
        "id" => syllabus_id,
        "path" => path,
        "family_root" => syllabus_family_root(path),
        "country_id" => data["country_id"],
        "subjects" => Array(data["subjects"])
      }
    end

    [catalog, duplicates]
  end

  def build_topic_catalog(syllabi)
    topics = {}
    topics_by_id = Hash.new { |hash, key| hash[key] = [] }
    duplicates = []

    topic_files.each do |path|
      data = load_yaml(path)
      topic_id = data["id"]
      syllabus_id = data["syllabus_id"]
      subject_id = data["subject_id"]
      subject_grade_id = data["subject_grade_id"] || subject_id
      next if topic_id.nil? || topic_id.empty?

      syllabus = syllabi[syllabus_id]
      if topics.key?(topic_id)
        duplicates << {
          "topic_id" => topic_id,
          "paths" => [topics.fetch(topic_id).fetch("path"), path]
        }
        next
      end

      topic = {
        "key" => topic_id,
        "path" => path,
        "topic_id" => topic_id,
        "syllabus_id" => syllabus_id,
        "subject_id" => subject_id,
        "subject_grade_id" => subject_grade_id,
        "family_root" => syllabus ? syllabus.fetch("family_root") : path
      }

      topics[topic_id] = topic
      topics_by_id[topic_id] << topic
    end

    [topics, topics_by_id, duplicates]
  end

  def render_topic_reference(topic)
    syllabus_id = topic["syllabus_id"]
    topic_id = topic.fetch("topic_id")
    syllabus_id.nil? || syllabus_id.empty? ? topic_id : "#{syllabus_id}:#{topic_id}"
  end

  def resolve_topic_reference(topic_id:, from_topic:, topics_by_id:)
    _ = from_topic
    candidates = topics_by_id.fetch(topic_id, [])
    return { "status" => "missing", "matches" => [] } if candidates.empty?
    return { "status" => "ok", "topic" => candidates.first } if candidates.length == 1

    { "status" => "ambiguous", "matches" => candidates }
  end

  def load_linked_topic_id(topic_path, relative_path)
    file_path = linked_file(topic_path, relative_path)
    return [nil, nil] if file_path.nil? || !file_path.exist?

    [load_yaml(file_path)["topic_id"], file_path]
  end

  def translation_exists?(topic_path)
    topic_path = Pathname(topic_path)
    translations_root = topic_path.dirname.join("translations")
    return false unless translations_root.exist?

    translations_root.each_child.any? do |locale_dir|
      locale_dir.directory? && locale_dir.join(topic_path.basename).exist?
    end
  end
end
