#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/oss_validation"

syllabi, syllabus_duplicates = OssValidation.build_syllabus_catalog
subjects = {}
topics, topics_by_id, topic_duplicates = OssValidation.build_topic_catalog(syllabi)
errors = []

syllabus_duplicates.each do |duplicate|
  paths = duplicate.fetch("paths").join(", ")
  errors << "duplicate syllabus id: #{duplicate.fetch('syllabus_id')} (files: #{paths})"
end

topic_duplicates.each do |duplicate|
  paths = duplicate.fetch("paths").join(", ")
  errors << "duplicate topic key: #{duplicate.fetch('syllabus_id')}:#{duplicate.fetch('topic_id')} (files: #{paths})"
end

OssValidation.subject_files.each do |path|
  data = OssValidation.load_yaml(path)
  syllabus_id = data["syllabus_id"]
  subject_id = data["id"]

  if syllabus_id.nil? || syllabus_id.empty? || subject_id.nil? || subject_id.empty?
    errors << "#{path}: missing subject id or syllabus_id"
    next
  end

  key = [syllabus_id, subject_id]
  if subjects.key?(key)
    errors << "duplicate subject key: #{syllabus_id}:#{subject_id}"
    next
  end

  subjects[key] = {
    "path" => path,
    "topics" => Array(data["topics"])
  }
end

OssValidation.topic_files.each do |path|
  data = OssValidation.load_yaml(path)
  topic_id = data["id"]
  syllabus_id = data["syllabus_id"]
  subject_id = data["subject_id"]

  if [topic_id, syllabus_id, subject_id].any? { |value| value.nil? || value.empty? }
    errors << "#{path}: missing topic id, syllabus_id, or subject_id"
    next
  end

  topic_key = OssValidation.topic_key(syllabus_id, topic_id)
  topic = topics[topic_key]
  unless topic
    errors << "#{path}: topic index missing for #{syllabus_id}:#{topic_id}"
    next
  end

  topic["prerequisites"] = data["prerequisites"] || {}
  topic["ai_teaching_notes"] = data["ai_teaching_notes"]
  topic["examples_file"] = data["examples_file"]
  topic["assessments_file"] = data["assessments_file"]
end

topics.each_value do |meta|
  topic_ref = OssValidation.render_topic_reference(meta)
  errors << "#{topic_ref}: unknown syllabus_id #{meta['syllabus_id']}" unless syllabi.key?(meta["syllabus_id"])
  unless subjects.key?([meta["syllabus_id"], meta["subject_id"]])
    errors << "#{topic_ref}: unknown subject reference #{meta['subject_id']} in #{meta['syllabus_id']}"
  end

  prerequisites = meta["prerequisites"]
  (Array(prerequisites["required"]) + Array(prerequisites["recommended"])).each do |dependency|
    resolution = OssValidation.resolve_topic_reference(topic_id: dependency, from_topic: meta, topics_by_id: topics_by_id)
    case resolution.fetch("status")
    when "missing"
      errors << "#{topic_ref}: unknown prerequisite topic #{dependency}"
    when "ambiguous"
      matches = resolution.fetch("matches").map { |topic| OssValidation.render_topic_reference(topic) }.join(", ")
      errors << "#{topic_ref}: ambiguous prerequisite topic #{dependency} (matches: #{matches})"
    end
  end

  %w[ai_teaching_notes examples_file assessments_file].each do |field|
    relative_path = meta[field]
    next if relative_path.nil? || relative_path.empty?

    file_path = meta["path"].dirname.join(relative_path)
    unless file_path.exist?
      errors << "#{topic_ref}: missing #{field} file #{file_path}"
      next
    end

    next unless %w[examples_file assessments_file].include?(field)

    begin
      linked_topic_id, = OssValidation.load_linked_topic_id(meta["path"], relative_path)
      next if linked_topic_id == meta["topic_id"]

      errors << "#{topic_ref}: #{field} points to topic #{linked_topic_id || 'unknown'}"
    rescue StandardError => error
      errors << "#{topic_ref}: failed to read #{field} #{file_path} (#{error.message})"
    end
  end
end

subjects.each do |(syllabus_id, subject_id), meta|
  errors << "#{meta['path']}: unknown syllabus_id #{syllabus_id}" unless syllabi.key?(syllabus_id)

  meta["topics"].each do |topic_id|
    topic = topics[OssValidation.topic_key(syllabus_id, topic_id)]
    if topic.nil?
      errors << "#{syllabus_id}:#{subject_id}: missing topic #{topic_id}"
      next
    end

    next if topic["syllabus_id"] == syllabus_id && topic["subject_id"] == subject_id

    errors << "#{syllabus_id}:#{subject_id}: topic #{topic_id} points to #{topic['syllabus_id']}:#{topic['subject_id']}"
  end
end

syllabi.each do |syllabus_id, meta|
  meta["subjects"].each do |subject_id|
    errors << "#{syllabus_id}: missing subject #{subject_id}" unless subjects.key?([syllabus_id, subject_id])
  end
end

OssValidation.concept_files.each do |path|
  data = OssValidation.load_yaml(path)
  concept_id = data["id"] || path.basename.to_s

  Array(data["curricula"]).each do |item|
    syllabus_id = item["syllabus"]
    topic_id = item["topic"]

    unless syllabi.key?(syllabus_id)
      errors << "#{concept_id}: unknown syllabus #{syllabus_id}"
      next
    end

    topic = topics[OssValidation.topic_key(syllabus_id, topic_id)]
    if topic.nil?
      matches = topics_by_id.fetch(topic_id, [])
      if matches.empty?
        errors << "#{concept_id}: unknown topic #{topic_id}"
      else
        owners = matches.map { |match| OssValidation.render_topic_reference(match) }.join(", ")
        errors << "#{concept_id}: topic #{topic_id} is not present in #{syllabus_id} (matches: #{owners})"
      end
    end
  end
end

if errors.empty?
  puts "PASS: all syllabus, subject, topic, file, and concept references are valid"
  puts "- syllabi: #{syllabi.length}"
  puts "- subjects: #{subjects.length}"
  puts "- topics: #{topics.length}"
  puts "- concepts: #{OssValidation.concept_files.length}"
  exit 0
end

puts "FAIL: broken references detected"
errors.each { |error| puts "- #{error}" }
exit 1
