require 'test/helper'

# This is pretending to encrypt something.
module App
  extend self

  def rot13(str)
    str.tr "A-Za-z", "N-ZA-Mn-za-m"
  end

  alias :encrypt :rot13
  alias :decrypt :rot13
end

class TestSecureStore < SimpleFileStore

  include SecureFileStore

  file_name_tokens :res_id, :alt_res_id

end

class TestSecureFileStore < Test::Unit::TestCase
  context "Auto-saving to SecureFileStore" do
    setup do
      @res_id       = "102"
      @alt_res_id   = "foobar"
      @file_content = "foo bar baz"
      @file_names   = assert_dir_content_difference('test/fstore/test_secure_stores') {
        @ts = TestSecureStore.new(:content => @file_content, :res_id => @res_id, :alt_res_id => @alt_res_id)
      }
      @expected_file_name = "test/fstore/test_secure_stores/#{@res_id}-#{@alt_res_id}.csv"
    end

    teardown do
      @file_names.each {|f| File.unlink(f)} unless @file_names.nil?
    end

    should "save content to store" do
      assert File.exist?(@expected_file_name)
      assert_equal @expected_file_name, @file_names.first
    end

    should "set attributes" do
      assert_attributes_set(@ts, @file_content, @res_id, @alt_res_id, @expected_file_name)
    end
  end

  context "Auto-loading from SecureFileStore" do
    setup do
      @res_id       = "1"
      @alt_res_id   = "2"
      @file_content = "xyz"
      @file_name    = "#{@res_id}#{TestSecureStore::Separator}#{@alt_res_id}.csv"
      @file_path    = File.join('test', 'fstore', 'test_secure_stores', @file_name)
      FileUtils.mkdir_p(File.dirname(@file_path))
      File.open(@file_path, 'w') {|f| f.write @file_content}
      @file_names   = assert_no_dir_content_difference('test/fstore/test_secure_stores') {
        @ts = TestSecureStore.new(:file_name => @file_name)
      }
      @expected_file_name = "test/fstore/test_secure_stores/#{@res_id}#{TestSecureStore::Separator}#{@alt_res_id}.csv"
    end

    teardown do
      File.unlink(@file_path)
    end

    should "load content from store" do
      assert_equal App.decrypt(@file_content), @ts.content
    end

    should "set attributes" do
      assert_attributes_set(@ts, App.decrypt(@file_content), @res_id, @alt_res_id, @expected_file_name)
    end
  end

  protected

  def assert_attributes_set(ts, file_content, res_id, alt_res_id, expected_file_name)
    assert_equal file_content, ts.content, "Should set file/data"
    assert_equal File.basename(expected_file_name), ts.file_name, "Should set file_name"
    assert_equal res_id, ts.res_id, "Should set record ID"
    assert_equal alt_res_id, ts.alt_res_id, "Should set record ID"
    assert ts.timestamp, "Should set timestamp"
    assert ts.usec, "Should set timestamp/.usec"
    assert_equal 'csv', ts.content_type, "Should set content_type"
    assert_equal './test/fstore', ts.root.to_s, "Should set root"
    assert_equal './' << expected_file_name, ts.path.to_s, "Should set path"
  end

end
