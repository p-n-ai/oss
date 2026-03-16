#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/oss_validation"

syllabi = {}
subjects = {}
topics = {}
errors = []

OssValidation.syllabus_files.each do |path|
  data = OssValidation.load_yaml(path)
  syllabus_id = data["id"]

  if syllabus_id.nil? || syllabus_id.empty?
    errors << "#{path}: missing syllabus id"
    next
  end

  if syllabi.key?(syllabus_id)
    errors << "duplicate syllabus id: #{syllabus_id}"
    next
  end

  syllabi[syllabus_id] = {
    "path" => path,
    "subjects" => Array(data["subjects"])
  }
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

  if topics.key?(topic_id)
    errors << "duplicate topic id: #{topic_id}"
    next
  end

  topics[topic_id] = {
    "path" => path,
    "syllabus_id" => syllabus_id,
    "subject_id" => subject_id,
    "prerequisites" => data["prerequisites"] || {},
    "ai_teaching_notes" => data["ai_teaching_notes"],
    "examples_file" => data["examples_file"],
    "assessments_file" => data["assessments_file"]
  }
end

topics.each do |topic_id, meta|
  errors << "#{topic_id}: unknown syllabus_id #{meta['syllabus_id']}" unless syllabi.key?(meta["syllabus_id"])
  unless subjects.key?([meta["syllabus_id"], meta["subject_id"]])
    errors << "#{topic_id}: unknown subject reference #{meta['subject_id']} in #{meta['syllabus_id']}"
  end

  prerequisites = meta["prerequisites"]
  (Array(prerequisites["required"]) + Array(prerequisites["recommended"])).each do |dependency|
    errors << "#{topic_id}: unknown prerequisite topic #{dependency}" unless topics.key?(dependency)
  end

  %w[ai_teaching_notes examples_file assessments_file].each do |field|
    relative_path = meta[field]
    next if relative_path.nil? || relative_path.empty?

    file_path = meta["path"].dirname.join(relative_path)
    errors << "#{topic_id}: missing #{field} file #{file_path}" unless file_path.exist?
  end
end

subjects.each do |(syllabus_id, subject_id), meta|
  errors << "#{meta['path']}: unknown syllabus_id #{syllabus_id}" unless syllabi.key?(syllabus_id)

  meta["topics"].each do |topic_id|
    topic = topics[topic_id]
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

    topic = topics[topic_id]
    if topic.nil?
      errors << "#{concept_id}: unknown topic #{topic_id}"
      next
    end

    next if topic["syllabus_id"] == syllabus_id

    errors << "#{concept_id}: topic #{topic_id} belongs to #{topic['syllabus_id']}, not #{syllabus_id}"
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
