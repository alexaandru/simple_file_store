require 'test/unit'
require 'fileutils'

require 'rubygems'
require 'shoulda'
if RUBY_VERSION >= '1.9.0'
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
    add_group "Libraries",   "/lib/"
    command_name "Combined Tests"
  end if ENV['COVERAGE']
end

require './lib/simple_file_store'
# The testing fstore root
AppRoot = File.dirname(__FILE__)

module SimpleFileStore

  class TestCase < Test::Unit::TestCase

    def assert_dir_content_difference(dir, depth = ['*'], difference = 1)
      raise ArgumentError, "Directory not found" unless File.exist?(dir)
      before_content = Dir[File.join(dir, *depth)]
      yield
      after_content = Dir[File.join(dir, *depth)]
      assert_equal before_content.size + difference, after_content.size,
        "Expected an increase of #{difference} in '#{dir}' folder contents, got a difference of #{after_content.size - before_content.size}"
      after_content - before_content
    end

    def assert_no_dir_content_difference(dir, depth = ['*'], &block)
      assert_dir_content_difference(dir, depth, 0, &block)
    end

    def assert_attributes_set(ts, file_content, record_id, expected_file_name)
      assert_equal file_content, ts.content, "Should set file/data"
      assert_equal File.basename(expected_file_name), ts.file_name, "Should set file_name"
      assert_equal record_id, ts.record_id, "Should set record ID"
      assert ts.timestamp, "Should set timestamp"
      assert ts.usec, "Should set timestamp/.usec"
      assert_equal 'csv', ts.content_type, "Should set content_type"
      assert_match %r|/test/fstore$|, ts.root.to_s, "Should set root"
      assert_match %r|#{expected_file_name}$|, ts.path.to_s, "Should set path"
    end

  end

end
