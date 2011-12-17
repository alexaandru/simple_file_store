require './test/base'

class TestCachingStore < SimpleFileStore::Base
  features :caching

  file_name_tokens :record_id, :alt_rec_id

  def generate_content
    "auto generated content %s/%s" % [record_id, alt_rec_id]
  end
end

class TestBadCachingStore < SimpleFileStore::Base
  include CachingFileStore

  file_name_tokens :res_id, :alt_rec_id
end

class CachingFileStoreTest < SimpleFileStore::TestCase
  context "Auto-saving to CachingFileStore" do
    setup do
      @record_id    = "102"
      @alt_rec_id   = "foobar"
      @file_content = "auto generated content 102/foobar"
      @file_names   = assert_dir_content_difference('test/fstore/test_caching_stores') {
        @ts = TestCachingStore.new(:record_id => @record_id, :alt_rec_id => @alt_rec_id)
      }
      @expected_file_name = "test/fstore/test_caching_stores/#{@record_id}-#{@alt_rec_id}.csv"
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

    should "raise an error if generate_content is not defined" do
      assert_raise NoMethodError do
        TestBadCachingStore.new(:record_id => @record_id, :alt_rec_id => @alt_rec_id)
      end
    end
  end

  context "Auto-loading from CachingFileStore" do
    setup do
      @record_id    = "1"
      @alt_rec_id   = "2"
      @file_content = "xyz"
      @file_name    = "#{@record_id}#{TestCachingStore::Separator}#{@alt_rec_id}.csv"
      @file_path    = File.join('test', 'fstore', 'test_caching_stores', @file_name)
      FileUtils.mkdir_p(File.dirname(@file_path))
      File.open(@file_path, 'w') {|f| f.write @file_content}
      @file_names   = assert_no_dir_content_difference('test/fstore/test_caching_stores') {
        @ts = TestCachingStore.new(:file_name => @file_name)
      }
      @expected_file_name = "test/fstore/test_caching_stores/#{@record_id}#{TestCachingStore::Separator}#{@alt_rec_id}.csv"
    end

    teardown do
      File.unlink(@file_path)
    end

    should "load content from store" do
      assert_equal @file_content, @ts.content
    end

    should "set attributes" do
      assert_attributes_set(@ts, @file_content, @record_id, @alt_rec_id, @expected_file_name)
    end
  end

  protected

  def assert_attributes_set(ts, file_content, record_id, alt_rec_id, expected_file_name)
    super(ts, file_content, record_id, expected_file_name)
    assert_equal alt_rec_id, ts.alt_rec_id, "Should set record ID"
  end
end
