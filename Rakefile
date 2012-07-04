# coding: utf-8
require 'rubygems'
require 'rake'

require 'rspec/core/rake_task'

task :default => :spec
RSpec::Core::RakeTask.new

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "moip #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

