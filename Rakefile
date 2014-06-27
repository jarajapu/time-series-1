# rubocop: disable LeadingCommentSpace
#! /usr/bin/env rake
# rubocop: enable LeadingCommentSpace
require 'bundler/gem_tasks'
require 'yard'
require 'rspec/core/rake_task'
require 'reek/rake/task'
require 'rubocop/rake_task'

task default: :build

# If there are test failures, you'll need to write code to address them.
# So no point in continuing to run the style tests.
desc 'Runs all spec tests'
RSpec::Core::RakeTask.new(:spec)

desc 'Runs yard'
YARD::Rake::YardocTask.new(:yard)

desc 'smells the lib directory, which Reek defaults to anyway'
Reek::Rake::Task.new(:reek_lib) do |task|
  task.verbose = true
end

desc 'smells the spec directory, which is less important than lib'
Reek::Rake::Task.new(:reek_spec) do |task|
  task.source_files = 'spec/**/*.rb'
  task.verbose = true
end

desc 'runs Rubocop'
Rubocop::RakeTask.new

desc 'Runs test and code cleanliness suite: Rubocop, Reek, rspec, and yard'
task run_guards: [:spec, :yard, :reek_lib, :rubocop]

task build: :run_guards
