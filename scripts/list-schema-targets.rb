#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/oss_validation"

requested_types = ARGV.map(&:to_sym)
unknown_types = requested_types - OssValidation::EXPECTED_INVENTORY.keys
unless unknown_types.empty?
  warn "unknown artifact type(s): #{unknown_types.join(', ')}"
  exit 2
end

types = requested_types.empty? ? OssValidation::EXPECTED_INVENTORY.keys : requested_types

types.each do |type|
  OssValidation.files_for(type).each do |path|
    schema = OssValidation.schema_for(path)
    unless schema && schema.file?
      warn "#{OssValidation.relative_path(path)}: missing schema for #{type}"
      exit 1
    end

    puts [
      type,
      OssValidation.relative_path(schema),
      OssValidation.relative_path(path)
    ].join("|")
  end
end
