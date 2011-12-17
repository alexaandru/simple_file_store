require './test/base'

# This is pretending to encrypt something.
module App
  extend self

  def rot13(str)
    str.tr "A-Za-z", "N-ZA-Mn-za-m"
  end

  alias :encrypt :rot13
  alias :decrypt :rot13
end

class TestSecureStore < SimpleFileStore::Base
  features :secure

  file_name_tokens :record_id, :alt_rec_id
end

class SecureFileStoreTest < SimpleFileStore::TestCase
  context "Auto-saving to SecureFileStore" do
    setup do
      @record_id       = "102"
      @alt_rec_id   = "foobar"
      @file_content = "foo bar baz"
      @file_names   = assert_dir_content_difference('test/fstore/test_secure_stores') {
        @ts = TestSecureStore.new(:content => @file_content, :record_id => @record_id, :alt_rec_id => @alt_rec_id)
      }
      @expected_file_name = "test/fstore/test_secure_stores/#{@record_id}-#{@alt_rec_id}.csv"
    end

    teardown do
      @file_names.each {|f| File.unlink(f)} unless @file_names.nil?
    end

    should "save content to store" do
      assert File.exist?(@expected_file_name)
      assert_equal @expected_file_name, @file_names.first
    end

    should "set attributes" do
      assert_attributes_set(@ts, @file_content, @record_id, @alt_rec_id, @expected_file_name)
    end
  end

  context "Auto-loading from SecureFileStore" do
    setup do
      @record_id       = "1"
      @alt_rec_id   = "2"
      @file_content = "xyz"
      @file_name    = "#{@record_id}#{TestSecureStore::Separator}#{@alt_rec_id}.csv"
      @file_path    = File.join('test', 'fstore', 'test_secure_stores', @file_name)
      FileUtils.mkdir_p(File.dirname(@file_path))
      File.open(@file_path, 'w') {|f| f.write @file_content}
      @file_names   = assert_no_dir_content_difference('test/fstore/test_secure_stores') {
        @ts = TestSecureStore.new(:file_name => @file_name)
      }
      @expected_file_name = "test/fstore/test_secure_stores/#{@record_id}#{TestSecureStore::Separator}#{@alt_rec_id}.csv"
    end

    teardown do
      File.unlink(@file_path)
    end

    should "load content from store" do
      assert_equal App.decrypt(@file_content), @ts.content
    end

    should "set attributes" do
      assert_attributes_set(@ts, App.decrypt(@file_content), @record_id, @alt_rec_id, @expected_file_name)
    end
  end

  protected

  def assert_attributes_set(ts, file_content, record_id, alt_rec_id, expected_file_name)
    super(ts, file_content, record_id, expected_file_name)
    assert_equal alt_rec_id, ts.alt_rec_id, "Should set record ID"
  end
end
