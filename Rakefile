begin; require 'bones'; rescue LoadError; abort '### Please install the "bones" gem ###'; end

task :default => 'test:run'
task 'gem:release' => 'test:run'

ver = `cat version.txt`.strip

Bones {
  name         'simple_file_store'
  version      ver
  authors      'Alex Ungur'
  email        'alexaandru@gmail.com'
  url          'http://rubygems.org/gems/simple_file_store'
  readme_file  'README.asciidoc'
  ignore_file  '.gitignore'
  depend_on    'activesupport', :version => '~>2.3.0'
  depend_on    'bones',      :development => true
  depend_on    'bones-rcov', :development => true
}

#
# Rake task below copied and adapted from Shoulda gem.
# The below code is copyrighted by their respective authors:
#
#
# Credits
# Shoulda is maintained and funded by {thougthbot}[http://thoughtbot.com/community]
#
# License
#
# Shoulda is Copyright © 2006-2010 Tammer Saleh, Thoughtbot. It is free software,
# and may be redistributed under the terms specified in the MIT-LICENSE file.
#
namespace :shoulda do
  desc "List the names of the test methods in a specification like format"
  task :list do
    $LOAD_PATH.unshift("test")
    $LOAD_PATH.unshift("lib")

    require 'test/unit'
    require 'rubygems'
    require 'active_support'

    # bug in test unit.  Set to true to stop from running.
    Test::Unit.run = true

    test_files = Dir.glob(File.join('test', 'test_*_store.rb'))
    test_files.each do |file|
      load file
      klass = File.basename(file, '.rb').classify
      unless Object.const_defined?(klass.to_s)
        puts "Skipping #{klass} because it doesn't map to a Class"
        next
      end
      klass = klass.constantize

      puts klass.name.gsub('Test', '')

      test_methods = klass.instance_methods.grep(/^test/).map {|s| s.gsub(/^test: /, '')}.sort
      test_methods.each {|m| puts "  " + m }
    end
  end
end

namespace :test do
  desc "Build test coverage report (rcov)"
  task :coverage do
    sh "rcov --text-report test/test_*_file_store.rb -Itest -Ilib"
  end

  desc "Check code quality"
  task :quality do
    %w|roodi flog flay|.each do |e|
      puts "=== #{e.capitalize} #{'=' * 80}"
      sh "#{e} lib/**/*.rb"
      puts
    end
  end
end
