require 'bundler/gem_tasks'

def root
  Pathname.new(File.dirname(__FILE__))
end

def test_files
  Dir[root.join('test', '*_test.rb')].map{|x| x.inspect}.join(' ')
end

namespace :test do
  desc "Check code quality"
  task :quality do
    %w|roodi flog flay|.each do |e|
      puts "=== #{e.capitalize} #{'=' * 80}"
      sh "#{e} lib/**/*.rb"
      puts
    end
  end

  namespace :unit do
    test_files.split(' ').each do |tt|
      name = File.basename(tt, '.rb"')[0..-6]
      desc "Run #{name} unit test"
      task name do
        sh "ruby #{root.join('test', 'loader.rb')} #{tt}"
      end
    end
  end

  desc "List the tests spec"
  task :spec do
    require 'test/unit'
    test_files.delete('"').split(' ').sort.each do |file|
      out = Test::Unit::TestCase.new(nil).capture_io { load file }.join
      klass = File.basename(file, '.rb').classify

      unless Object.const_defined?(klass.to_s)
        puts "Skipping #{klass} because it doesn't map to a Class"
        next
      end

      klass = klass.constantize
      name = klass.name.gsub('Test', '')
      puts name, '-' * name.size
      test_methods = klass.instance_methods.grep(/^test/).map {|s| s.to_s.gsub(/^test: /, '')}.sort
      test_methods.each { |m| puts "    " << m }
      puts out.nil? || out.empty? ? nil : [out, nil]
    end

    exit 1 # to skip running tests suite
  end
end

desc "Run all tests"
task :test do
  sh "ruby #{root.join('test', 'loader.rb')} #{test_files}"
end

namespace :test do
  task :prepare_coverage do
    ENV['COVERAGE'] = '1'
  end

  desc "Run tests coverage report"
  task :coverage => [:prepare_coverage, :test]
end

task :default => :test
