require 'test/unit'
require 'fileutils'

require 'rubygems'
require 'shoulda'
require 'simple_file_store'

# The testing fstore root
AppRoot = File.dirname(__FILE__)

class Test::Unit::TestCase
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
end
