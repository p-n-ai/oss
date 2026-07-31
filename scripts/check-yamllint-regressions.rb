#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'fileutils'
require 'set'
require 'tmpdir'

REPO_ROOT = File.expand_path('..', __dir__)
CONFIG_PATH = File.join(REPO_ROOT, '.yamllint.yml')

def lint_findings(paths, working_directory)
  stdout, stderr, status = Open3.capture3(
    'yamllint',
    '-f',
    'parsable',
    '-c',
    CONFIG_PATH,
    *paths,
    chdir: working_directory
  )

  unless status.success? || status.exitstatus == 1
    warn stderr
    abort 'yamllint could not inspect the requested files'
  end

  findings = Hash.new do |files, path|
    files[path] = Hash.new { |rules, key| rules[key] = [] }
  end

  stdout.each_line do |line|
    match = line.match(/\A(.+?):\d+:\d+: \[(warning|error)\].* \(([^()]+)\)\s*\z/)
    abort "unexpected yamllint output: #{line}" unless match

    findings[match[1]][[match[2], match[3]]] << line.strip
  end
  findings
end

def tracked_paths(base_commit, paths)
  stdout, stderr, status = Open3.capture3(
    'git',
    'ls-tree',
    '-r',
    '--name-only',
    base_commit,
    '--',
    *paths,
    chdir: REPO_ROOT
  )
  abort stderr unless status.success?

  stdout.lines(chomp: true).to_set
end

def baseline_findings(base_commit, paths)
  available_paths = tracked_paths(base_commit, paths)

  Dir.mktmpdir('oss-yamllint-baseline') do |directory|
    available_paths.each do |path|
      content, stderr, status = Open3.capture3(
        'git',
        'show',
        "#{base_commit}:#{path}",
        chdir: REPO_ROOT
      )
      abort stderr unless status.success?

      destination = File.join(directory, path)
      FileUtils.mkdir_p(File.dirname(destination))
      File.write(destination, content)
    end

    return {} if available_paths.empty?

    lint_findings(available_paths.to_a.sort, directory)
  end
end

base_commit = ARGV.shift
abort 'usage: check-yamllint-regressions.rb BASE_COMMIT FILE...' unless base_commit && !ARGV.empty?

paths = ARGV.sort
current_by_path = lint_findings(paths, REPO_ROOT)
baseline_by_path = baseline_findings(base_commit, paths)

regressions = []

paths.each do |path|
  current = current_by_path.fetch(path, {})
  baseline = baseline_by_path.fetch(path, {})
  current.each do |key, lines|
    added_count = lines.length - baseline.fetch(key, []).length
    next unless added_count.positive?

    regressions << [path, key, added_count, lines]
  end
end

if regressions.empty?
  puts "PASS: no new yamllint findings across #{paths.length} touched YAML file(s)"
  exit 0
end

regressions.each do |path, (severity, rule), added_count, lines|
  warn "FAIL: #{path} adds #{added_count} #{severity} finding(s) for #{rule}"
  lines.each { |line| warn "  #{line}" }
end

abort "FAIL: #{regressions.length} yamllint rule regression(s)"
