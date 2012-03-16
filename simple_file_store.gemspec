# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'simple_file_store/version'

Gem::Specification.new do |s|
  s.name        = 'simple_file_store'
  s.version     = SimpleFileStore::VERSION
  s.authors     = ['Alex Ungur']
  s.date        = '2011-12-17'
  s.email       = ['alexaandru@gmail.com']
  s.homepage    = %q|http://rubygems.org/gems/simple_file_store|
  s.summary     = %q|A file storing/loading micro-framework.|
  s.description = %q|A micro-framework for automating storing and loading files to/from the filesystem.|

  s.rubyforge_project = 'simple_file_store'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.rdoc_options  = ['--main', 'README.asciidoc']

  # specify any dependencies here; for example:
  s.add_runtime_dependency 'activesupport', ['~>2.3.0']
  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'roodi'
  s.add_development_dependency 'flay'
  s.add_development_dependency 'flog'
end
