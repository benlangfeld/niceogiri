require 'rubygems'
require 'bundler/setup'
require 'rake'

require 'bundler/gem_tasks'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'spec'
  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'spec'
  test.pattern = 'spec/**/*_spec.rb'
  test.rcov_opts += ['--exclude \/Library\/Ruby,spec\/', '--xrefs']
  test.verbose = true
end

require 'yard'

YARD::Rake::YardocTask.new(:doc) do |t|
  t.options = ['--no-private', '-m', 'markdown', '-o', './doc/public/yard']
end

task :default => :test
