# coding: utf-8
require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "moip"
    gem.summary = "Gem para utilização da API MoIP"
    gem.description = "Gem para utilização da API MoIP"
    gem.email = "guilherme.ruby@gmail.com"
    gem.homepage = "http://github.com/guinascimento/moip"
    gem.authors = ["Guilherme Nascimento"]
    gem.add_development_dependency "rspec", "~> 2.1.0"
    gem.add_dependency "nokogiri", "~> 1.4.3"
    gem.add_dependency "httparty", "~> 0.6.1"
    gem.add_dependency "activesupport", '>= 2.3.2'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'

desc "Run all examples"
RSpec::Core::RakeTask.new

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "moip #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

