#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require_relative "lib/oss_validation"

def find_required_chains(topic_key, topics, trail = nil)
  trail ||= [topic_key]
  required = topics.fetch(topic_key).fetch("resolved_required")
  return [trail] if required.empty?

  required.flat_map do |dependency|
    if !topics.key?(dependency) || trail.include?(dependency)
      [trail + [dependency]]
    else
      find_required_chains(dependency, topics, trail + [dependency])
    end
  end
end

syllabi, syllabus_duplicates = OssValidation.build_syllabus_catalog
topics, topics_by_id, topic_duplicates = OssValidation.build_topic_catalog(syllabi)
topics_by_syllabus = Hash.new { |hash, key| hash[key] = [] }
errors = []
cycles = []

syllabus_duplicates.each do |duplicate|
  paths = duplicate.fetch("paths").join(", ")
  errors << "duplicate syllabus id: #{duplicate.fetch('syllabus_id')} (files: #{paths})"
end

topic_duplicates.each do |duplicate|
  paths = duplicate.fetch("paths").join(", ")
  errors << "duplicate topic key: #{duplicate.fetch('syllabus_id')}:#{duplicate.fetch('topic_id')} (files: #{paths})"
end

OssValidation.topic_files.each do |path|
  data = OssValidation.load_yaml(path)
  topic_id = data["id"]
  syllabus_id = data["syllabus_id"] || "unknown"
  subject_id = data["subject_id"]
  prerequisites = data["prerequisites"] || {}
  required = Array(prerequisites["required"])
  recommended = Array(prerequisites["recommended"])

  if [topic_id, syllabus_id, subject_id].any? { |value| value.nil? || value.empty? }
    errors << "#{path}: missing topic id, syllabus_id, or subject_id"
    next
  end

  topic_key = OssValidation.topic_key(syllabus_id, topic_id)
  topic = topics[topic_key]
  unless topic
    errors << "#{path}: topic index missing for #{topic_key}"
    next
  end

  topic["required"] = required
  topic["recommended"] = recommended
  topic["resolved_required"] = []
  topic["resolved_recommended"] = []
  topics_by_syllabus[syllabus_id] << topic_key
end

topics.each_value do |meta|
  (meta["required"] + meta["recommended"]).each do |dependency|
    resolution = OssValidation.resolve_topic_reference(topic_id: dependency, from_topic: meta, topics_by_id: topics_by_id)
    case resolution.fetch("status")
    when "missing"
      errors << "#{OssValidation.render_topic_reference(meta)}: missing prerequisite topic #{dependency}"
    when "ambiguous"
      matches = resolution.fetch("matches").map { |topic| OssValidation.render_topic_reference(topic) }.join(", ")
      errors << "#{OssValidation.render_topic_reference(meta)}: ambiguous prerequisite topic #{dependency} (matches: #{matches})"
    else
      target = resolution.fetch("topic").fetch("key")
      bucket = meta["required"].include?(dependency) ? "resolved_required" : "resolved_recommended"
      meta.fetch(bucket) << target
    end
  end
end

state = {}
stack = []

dfs = lambda do |topic_id|
  case state[topic_id]
  when :visiting
    start_index = stack.index(topic_id) || 0
    cycles << (stack[start_index..] + [topic_id])
    return
  when :visited
    return
  end

  state[topic_id] = :visiting
  stack << topic_id
  topics.fetch(topic_id).fetch("resolved_required").each do |dependency|
    dfs.call(dependency) if topics.key?(dependency)
  end
  stack.pop
  state[topic_id] = :visited
end

topics.keys.sort.each do |topic_key|
  dfs.call(topic_key) unless state.key?(topic_key)
end

if cycles.empty?
  puts "PASS: no prerequisite cycles detected"
else
  puts "FAIL: prerequisite cycles detected"
  seen = Set.new
  cycles.each do |cycle|
    rendered = cycle.map { |topic_key| OssValidation.render_topic_reference(topics.fetch(topic_key)) }.join(" -> ")
    next if seen.include?(rendered)

    puts "- #{rendered}"
    seen << rendered
  end
end

puts
puts "Prerequisite chains by syllabus"
topics_by_syllabus.keys.sort.each do |syllabus_id|
  puts "- #{syllabus_id}"
  topics_by_syllabus[syllabus_id].sort_by { |topic_key| topics.fetch(topic_key).fetch("topic_id") }.each do |topic_key|
    chains = find_required_chains(topic_key, topics)
    rendered = chains.map do |chain|
      chain.reverse.map { |key| topics.fetch(key).fetch("topic_id") }.join(" -> ")
    end.join(" | ")
    recommended = topics.fetch(topic_key).fetch("recommended")
    topic_id = topics.fetch(topic_key).fetch("topic_id")
    if recommended.empty?
      puts "  - #{topic_id}: #{rendered}"
    else
      puts "  - #{topic_id}: #{rendered} | recommended=#{recommended.join(', ')}"
    end
  end
end

unless errors.empty?
  puts
  puts "FAIL: invalid prerequisite references"
  errors.each { |error| puts "- #{error}" }
end

exit(cycles.empty? && errors.empty? ? 0 : 1)
