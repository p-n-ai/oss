#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/oss_validation"

errors = []

OssValidation.content_yaml_files.each do |path|
  OssValidation.load_yaml(path)
rescue StandardError => error
  errors << error.message
end

if errors.empty?
  puts "PASS: all #{OssValidation.content_yaml_files.length} content YAML files parse as objects"
  exit 0
end

warn "FAIL: #{errors.length} content YAML file(s) failed to parse"
errors.each { |error| warn "- #{error}" }
exit 1
