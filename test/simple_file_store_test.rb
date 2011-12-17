require './test/base'

class TestStore < SimpleFileStore::Base
  file_name_tokens :record_id, :timestamp, :usec
end

class SimpleFileStoreTest < SimpleFileStore::TestCase
  context "Auto-saving to SimpleFileStore" do
    setup do
      @record_id    = "100"
      @file_content = "abc"
      @file_names   = assert_dir_content_difference('test/fstore/test_stores') {
        @ts = TestStore.new(:content => @file_content, :record_id => @record_id)
        @expected_file_name = File.join('test', TestStore::FileStoreRoot, 'test_stores',
          "#{@ts.record_id}#{TestStore::Separator}#{@ts.timestamp}-#{@ts.usec}.#{@ts.content_type}")
      }
    end

    teardown do
      @file_names.each {|f| File.unlink(f)} unless @file_names.nil?
    end

    should "save content to store" do
      assert File.exist?(@expected_file_name), "File '#{@expected_file_name}' should have been created!"
      assert_equal @expected_file_name, @file_names.first
    end

    should "set attributes" do
      assert_attributes_set(@ts, @file_content, @record_id, @expected_file_name)
    end
  end

  context "Auto-loading from SimpleFileStore" do
    setup do
      @record_id    = "101"
      @file_content = "cde"
      @file_name    = "101-#{Time.now.to_i}-1.csv"
      @file_path    = File.join('test', 'fstore', 'test_stores', @file_name)
      File.open(@file_path, 'w') {|f| f.write @file_content}
      @file_names   = assert_no_dir_content_difference('test/fstore/test_stores') {
        @ts = TestStore.new(:file_name => @file_name)
      }
    end

    teardown do
      FileUtils.rm_f(@file_path)
    end

    should "load content from store" do
      assert_equal @file_content, @ts.content
    end

    should "set attributes" do
      assert_attributes_set(@ts, @file_content, @record_id, @file_path)
    end
  end
end
