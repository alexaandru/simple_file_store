begin; require 'bones'; rescue LoadError; abort '### Please install the "bones" gem ###'; end

task :default => 'test:run'
task 'gem:release' => 'test:run'

ver = `cat version.txt`.strip

Bones {
  name         'super_file_store'
  version      ver
  authors      'Alex Ungur'
  email        'alexaandru@gmail.com'
  url          'http://rubygems.org/gems/simple_file_store'
  readme_file  'README.asciidoc'
  ignore_file  '.gitignore'
  depend_on    'active_support'
  depend_on    'bones',      :development => true
  depend_on    'bones-rcov', :development => true
}
