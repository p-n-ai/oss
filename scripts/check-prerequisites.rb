#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require_relative "lib/oss_validation"

syllabi, syllabus_duplicates = OssValidation.build_syllabus_catalog
topics, topics_by_id, topic_duplicates = OssValidation.build_topic_catalog(syllabi)
errors = []
edges = {}

syllabus_duplicates.each do |duplicate|
  paths = duplicate.fetch("paths").map { |path| OssValidation.relative_path(path) }.join(", ")
  errors << "duplicate syllabus id #{duplicate.fetch('syllabus_id')}: #{paths}"
end

topic_duplicates.each do |duplicate|
  paths = duplicate.fetch("paths").map { |path| OssValidation.relative_path(path) }.join(", ")
  errors << "duplicate global topic id #{duplicate.fetch('topic_id')}: #{paths}"
end

OssValidation.topic_files.each do |path|
  data = OssValidation.load_yaml(path)
  topic_id = data["id"]
  next if topic_id.nil? || topic_id.empty?

  prerequisites = data["prerequisites"].is_a?(Hash) ? data["prerequisites"] : {}
  dependencies = {}
  %w[required recommended].each do |kind|
    dependencies[kind] = []
    Array(prerequisites[kind]).each_with_index do |reference, index|
      dependency = OssValidation.prerequisite_id(reference)
      if dependency.nil?
        errors << "#{topic_id}: prerequisites.#{kind}[#{index}] must be a canonical topic ID"
      else
        dependencies[kind] << dependency
      end
    end
  end
  required = dependencies.fetch("required")
  recommended = dependencies.fetch("recommended")

  duplicates = required & recommended
  duplicates.each do |dependency|
    errors << "#{topic_id}: prerequisite #{dependency} is both required and recommended"
  end

  (required + recommended).each do |dependency|
    if dependency == topic_id
      errors << "#{topic_id}: prerequisite cannot reference itself"
    elsif !topics.key?(dependency)
      errors << "#{topic_id}: missing prerequisite topic #{dependency}"
    end
  end

  edges[topic_id] = {
    "required" => required.uniq,
    "recommended" => recommended.uniq
  }
end

cycles = []
state = {}
stack = []

visit = lambda do |topic_id|
  case state[topic_id]
  when :visiting
    start = stack.index(topic_id) || 0
    cycles << (stack[start..] + [topic_id])
    return
  when :visited
    return
  end

  state[topic_id] = :visiting
  stack << topic_id
  edges.fetch(topic_id, {}).fetch("required", []).each do |dependency|
    visit.call(dependency) if edges.key?(dependency)
  end
  stack.pop
  state[topic_id] = :visited
end

edges.keys.sort.each { |topic_id| visit.call(topic_id) }

seen_cycles = Set.new
cycles.each do |cycle|
  rendered = cycle.join(" -> ")
  next unless seen_cycles.add?(rendered)

  errors << "required prerequisite cycle: #{rendered}"
end

if errors.empty?
  edge_count = edges.values.sum do |dependencies|
    dependencies.fetch("required").length + dependencies.fetch("recommended").length
  end
  puts "PASS: prerequisite graph is globally resolvable and acyclic"
  puts "- canonical topics: #{topics.length}"
  puts "- graph edges: #{edge_count}"
  exit 0
end

puts "FAIL: invalid prerequisite graph"
errors.each { |error| puts "- #{error}" }
exit 1
