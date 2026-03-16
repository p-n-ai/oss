#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

module OssValidation
  ROOT = Pathname(__dir__).join("..", "..").expand_path
  CURRICULA_ROOT = ROOT.join("curricula")
  CONCEPTS_ROOT = ROOT.join("concepts")

  module_function

  def load_yaml(path)
    data = YAML.safe_load(path.read, permitted_classes: [], aliases: false) || {}
    raise "#{path}: expected YAML object" unless data.is_a?(Hash)

    data
  rescue Psych::SyntaxError => error
    raise "#{path}: YAML parse failed: #{error.message}"
  end

  def topic_files
    Dir.glob(CURRICULA_ROOT.join("**", "*.yaml").to_s).map do |raw_path|
      path = Pathname(raw_path)
      next if path.basename.to_s == "syllabus.yaml"
      next if path.to_s.include?("/subjects/")
      next if path.basename.to_s.include?(".assessments.")
      next if path.basename.to_s.include?(".examples.")

      path
    end.compact.sort
  end

  def syllabus_files
    Dir.glob(CURRICULA_ROOT.join("**", "syllabus.yaml").to_s).map { |path| Pathname(path) }.sort
  end

  def subject_files
    Dir.glob(CURRICULA_ROOT.join("**", "*.yaml").to_s).map do |raw_path|
      path = Pathname(raw_path)
      path if path.to_s.include?("/subjects/")
    end.compact.sort
  end

  def concept_files
    return [] unless CONCEPTS_ROOT.exist?

    Dir.glob(CONCEPTS_ROOT.join("**", "*.yaml").to_s).map { |path| Pathname(path) }.sort
  end

  def linked_file(topic_path, relative_path)
    return nil if relative_path.nil? || relative_path.empty?

    topic_path.dirname.join(relative_path)
  end

  def topic_key(syllabus_id, topic_id)
    "#{syllabus_id}::#{topic_id}"
  end

  def syllabus_family_root(path)
    path.parent.parent
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
      next if [topic_id, syllabus_id, subject_id].any? { |value| value.nil? || value.empty? }

      syllabus = syllabi[syllabus_id]
      key = topic_key(syllabus_id, topic_id)
      if topics.key?(key)
        duplicates << {
          "topic_key" => key,
          "syllabus_id" => syllabus_id,
          "topic_id" => topic_id,
          "paths" => [topics.fetch(key).fetch("path"), path]
        }
        next
      end

      topic = {
        "key" => key,
        "path" => path,
        "topic_id" => topic_id,
        "syllabus_id" => syllabus_id,
        "subject_id" => subject_id,
        "family_root" => syllabus ? syllabus.fetch("family_root") : path.parent.parent.parent.parent
      }

      topics[topic.fetch("key")] = topic
      topics_by_id[topic_id] << topic
    end

    [topics, topics_by_id, duplicates]
  end

  def render_topic_reference(topic)
    "#{topic.fetch('syllabus_id')}:#{topic.fetch('topic_id')}"
  end

  def resolve_topic_reference(topic_id:, from_topic:, topics_by_id:)
    candidates = topics_by_id.fetch(topic_id, [])
    return { "status" => "missing", "matches" => [] } if candidates.empty?

    same_family_and_subject = candidates.select do |candidate|
      candidate.fetch("family_root") == from_topic.fetch("family_root") &&
        candidate.fetch("subject_id") == from_topic.fetch("subject_id")
    end
    return { "status" => "ok", "topic" => same_family_and_subject.first } if same_family_and_subject.length == 1
    return { "status" => "ambiguous", "matches" => same_family_and_subject } if same_family_and_subject.length > 1

    same_family = candidates.select do |candidate|
      candidate.fetch("family_root") == from_topic.fetch("family_root")
    end
    return { "status" => "ok", "topic" => same_family.first } if same_family.length == 1
    return { "status" => "ambiguous", "matches" => same_family } if same_family.length > 1

    return { "status" => "ok", "topic" => candidates.first } if candidates.length == 1

    { "status" => "ambiguous", "matches" => candidates }
  end

  def load_linked_topic_id(topic_path, relative_path)
    file_path = linked_file(topic_path, relative_path)
    return [nil, nil] if file_path.nil? || !file_path.exist?

    [load_yaml(file_path)["topic_id"], file_path]
  end

  def translation_exists?(topic_path)
    syllabus_root = topic_path.parent.parent.parent
    locales_root = syllabus_root.join("locales")
    return false unless locales_root.exist?

    relative_path = topic_path.relative_path_from(syllabus_root)
    locales_root.each_child.any? do |locale_dir|
      locale_dir.directory? && locale_dir.join(relative_path).exist?
    end
  end
end
