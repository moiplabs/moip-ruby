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

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "moip #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

