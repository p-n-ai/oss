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
