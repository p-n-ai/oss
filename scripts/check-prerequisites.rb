#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require_relative "lib/oss_validation"

def find_required_chains(topic_id, topics, trail = nil)
  trail ||= [topic_id]
  required = topics.fetch(topic_id).fetch("required")
  return [trail] if required.empty?

  required.flat_map do |dependency|
    if !topics.key?(dependency) || trail.include?(dependency)
      [trail + [dependency]]
    else
      find_required_chains(dependency, topics, trail + [dependency])
    end
  end
end

topics = {}
topics_by_syllabus = Hash.new { |hash, key| hash[key] = [] }
errors = []
cycles = []

OssValidation.topic_files.each do |path|
  data = OssValidation.load_yaml(path)
  topic_id = data["id"]
  syllabus_id = data["syllabus_id"] || "unknown"
  prerequisites = data["prerequisites"] || {}
  required = Array(prerequisites["required"])
  recommended = Array(prerequisites["recommended"])

  if topic_id.nil? || topic_id.empty?
    errors << "#{path}: missing topic id"
    next
  end

  if topics.key?(topic_id)
    errors << "duplicate topic id: #{topic_id}"
    next
  end

  topics[topic_id] = {
    "path" => path,
    "syllabus_id" => syllabus_id,
    "required" => required,
    "recommended" => recommended
  }
  topics_by_syllabus[syllabus_id] << topic_id
end

topics.each do |topic_id, meta|
  (meta["required"] + meta["recommended"]).each do |dependency|
    errors << "#{topic_id}: missing prerequisite topic #{dependency}" unless topics.key?(dependency)
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
  topics.fetch(topic_id).fetch("required").each do |dependency|
    dfs.call(dependency) if topics.key?(dependency)
  end
  stack.pop
  state[topic_id] = :visited
end

topics.keys.sort.each do |topic_id|
  dfs.call(topic_id) unless state.key?(topic_id)
end

if cycles.empty?
  puts "PASS: no prerequisite cycles detected"
else
  puts "FAIL: prerequisite cycles detected"
  seen = Set.new
  cycles.each do |cycle|
    rendered = cycle.join(" -> ")
    next if seen.include?(rendered)

    puts "- #{rendered}"
    seen << rendered
  end
end

puts
puts "Prerequisite chains by syllabus"
topics_by_syllabus.keys.sort.each do |syllabus_id|
  puts "- #{syllabus_id}"
  topics_by_syllabus[syllabus_id].sort.each do |topic_id|
    chains = find_required_chains(topic_id, topics)
    rendered = chains.map { |chain| chain.reverse.join(" -> ") }.join(" | ")
    recommended = topics.fetch(topic_id).fetch("recommended")
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
