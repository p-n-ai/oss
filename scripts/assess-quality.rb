#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require_relative "lib/oss_validation"

HEADING_PATTERNS = {
  "teaching_sequence" => [
    /^##+\s+Teaching Sequence\s*$/i,
    /^##+\s+Teaching Sequence\s*&\s*Strategy\s*$/i
  ],
  "misconceptions" => [
    /^##+\s+High Alert Misconceptions\s*$/i,
    /^##+\s+Common Misconceptions\s*$/i
  ],
  "engagement_hooks" => [
    /^##+\s+Engagement Hooks\s*$/i
  ]
}.freeze

def level0?(data)
  data["id"] && data["name"] && !Array(data["learning_objectives"]).empty?
end

def level1?(data)
  prerequisites = data["prerequisites"]
  level0?(data) && prerequisites.is_a?(Hash) && data["difficulty"] && !Array(data["bloom_levels"]).empty?
end

def teaching_signals(topic_path, data)
  notes_path = OssValidation.linked_file(topic_path, data["ai_teaching_notes"])
  return [false, ["ai_teaching_notes missing"], nil] if notes_path.nil?
  return [false, ["ai_teaching_notes file missing: #{notes_path.basename}"], notes_path] unless notes_path.exist?

  content = notes_path.read
  missing = HEADING_PATTERNS.map do |label, patterns|
    label unless patterns.any? { |pattern| content.match?(pattern) }
  end.compact

  [missing.empty?, missing, notes_path]
end

def next_level_requirements(level, topic_path, data, signals)
  case level
  when -1
    ["id", "name", "learning_objectives"]
  when 0
    ["prerequisites", "difficulty", "bloom_levels"]
  when 1
    signals.fetch("level2_missing")
  when 2
    missing = []
    assessments_path = OssValidation.linked_file(topic_path, data["assessments_file"])
    examples_path = OssValidation.linked_file(topic_path, data["examples_file"])
    missing << "assessments_file field missing" if assessments_path.nil?
    missing << "assessments_file missing: #{assessments_path.basename}" if assessments_path && !assessments_path.exist?
    missing << "examples_file field missing" if examples_path.nil?
    missing << "examples_file missing: #{examples_path.basename}" if examples_path && !examples_path.exist?
    missing
  when 3
    missing = []
    missing << "translation file" unless signals.fetch("translation_exists")
    missing << "cross_curriculum entries" unless signals.fetch("has_cross_curriculum")
    missing << "manual peer-review metadata unavailable"
    missing
  else
    ["manual curriculum authority validation metadata unavailable"]
  end
end

def assess_topic(topic_path)
  data = OssValidation.load_yaml(topic_path)
  claimed = Integer(data.fetch("quality_level", 0) || 0)
  actual = -1

  actual = 0 if level0?(data)
  actual = 1 if level1?(data)

  has_level2, level2_missing, notes_path = teaching_signals(topic_path, data)
  actual = 2 if actual >= 1 && has_level2

  assessments_path = OssValidation.linked_file(topic_path, data["assessments_file"])
  examples_path = OssValidation.linked_file(topic_path, data["examples_file"])
  has_level3 = actual >= 2 &&
    !assessments_path.nil? && assessments_path.exist? &&
    !examples_path.nil? && examples_path.exist?
  actual = 3 if has_level3

  signals = {
    "level2_missing" => level2_missing,
    "translation_exists" => OssValidation.translation_exists?(topic_path),
    "has_cross_curriculum" => !Array(data["cross_curriculum"]).empty?
  }

  manual_signals = []
  manual_signals << "translation file present" if signals["translation_exists"]
  manual_signals << "cross_curriculum present" if signals["has_cross_curriculum"]
  manual_signals << "Level 4/5 remain manual-only" if actual >= 3

  {
    "path" => topic_path,
    "topic_id" => data["id"] || topic_path.basename(".yaml").to_s,
    "syllabus_id" => data["syllabus_id"] || "unknown",
    "claimed_quality_level" => claimed,
    "actual_quality_level" => actual,
    "status" => claimed > actual ? "overclaimed" : "ok",
    "missing_requirements" => next_level_requirements(actual, topic_path, data, signals),
    "manual_signals" => manual_signals,
    "notes_path" => notes_path,
    "assessments_path" => assessments_path,
    "examples_path" => examples_path
  }
end

def print_report(results)
  grouped = results.group_by { |result| result["syllabus_id"] }

  puts "=== OSS Quality Assessment ==="
  grouped.keys.sort.each do |syllabus_id|
    puts "Syllabus: #{syllabus_id}"
    grouped.fetch(syllabus_id).sort_by { |result| result["topic_id"] }.each do |result|
      puts "- #{result['topic_id']}: claimed=#{result['claimed_quality_level']} actual=#{result['actual_quality_level']} status=#{result['status']}"
      unless result["missing_requirements"].empty?
        puts "  missing_next: #{result['missing_requirements'].join(', ')}"
      end
      unless result["manual_signals"].empty?
        puts "  manual_signals: #{result['manual_signals'].join(', ')}"
      end
    end
    puts
  end

  counts = Hash.new(0)
  results.each { |result| counts[result["actual_quality_level"]] += 1 }
  overclaimed = results.count { |result| result["status"] == "overclaimed" }

  puts "Summary"
  counts.keys.sort.each { |level| puts "- level #{level}: #{counts[level]}" }
  puts "- overclaimed: #{overclaimed}"
end

options = { "report" => false }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/assess-quality.rb [--report]"
  parser.on("--report", "Print the full grouped report") { options["report"] = true }
end.parse!

results = OssValidation.topic_files.map { |path| assess_topic(path) }
print_report(results) if options["report"]

overclaimed = results.select { |result| result["status"] == "overclaimed" }
unless overclaimed.empty?
  puts "FAIL: topic quality overclaims detected"
  overclaimed.each do |result|
    puts "- #{result['topic_id']}: claimed #{result['claimed_quality_level']} > actual #{result['actual_quality_level']}"
  end
  exit 1
end

puts "PASS: quality assessment completed for #{results.length} topic(s)"
