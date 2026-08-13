#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/oss_validation"

errors = OssValidation.inventory_errors
unless errors.empty?
  puts "FAIL: curriculum artifact inventory drifted"
  errors.each { |error| puts "- #{error}" }
  exit 1
end

puts "PASS: exact curriculum artifact inventory"
OssValidation::EXPECTED_INVENTORY.each do |type, count|
  puts "- #{type}: #{count}"
end
puts "- total: 684"
