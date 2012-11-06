require 'bundler'
require 'spec/rake/spectask'
Bundler::GemHelper.install_tasks

Spec::Rake::SpecTask.new do |t|
  t.libs << "spec"
  t.spec_files = FileList['spec/**/*_spec.rb']
end