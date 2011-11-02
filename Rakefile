require 'rubygems'
require 'bundler/setup'
require 'rake'

require 'bundler/gem_tasks'

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'yard'

YARD::Rake::YardocTask.new(:doc) do |t|
  t.options = ['--no-private', '-m', 'markdown', '-o', './doc/public/yard']
end

task :default => :spec
