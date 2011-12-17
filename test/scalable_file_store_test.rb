require './test/base'

class TestScalableStore < SimpleFileStore::Base
  features :scalable

  file_name_tokens :record_id, :alt_rec_id
end

class ScalableFileStoreTest < SimpleFileStore::TestCase
  context "Auto-saving to ScalableFileStore" do
    setup do
      @record_id    = "101"
      @alt_rec_id   = "2345678"
      @file_content = "xyz"
      @file_names   = assert_dir_content_difference('test/fstore/test_scalable_stores', %w|* * * * **|) {
        @ts = TestScalableStore.new(:content => @file_content, :record_id => @record_id, :alt_rec_id => @alt_rec_id)
      }
      @expected_file_name = "test/fstore/test_scalable_stores/bb/37/22/88/#{@record_id}-#{@alt_rec_id}.csv"
    end

    teardown do
      @file_names.each do |f|
        path = File.dirname(File.dirname(File.dirname(File.dirname(f))))
        raise ArgumentError, "You may be 'rm -rf'-ing the wrong path: '#{path}'. Aborting!" unless \
          path =~ %r|test/fstore/test_scalable_stores/.*|
        FileUtils.rm_rf(path)
      end if @file_names
    end

    should "save content to store" do
      assert File.exist?(@expected_file_name)
      assert_equal @expected_file_name, @file_names.first
    end

    should "set attributes" do
      assert_attributes_set(@ts, @file_content, @record_id, @alt_rec_id, @expected_file_name)
    end
  end

  context "Auto-loading from ScalableFileStore" do
    setup do
      @record_id    = "1"
      @alt_rec_id   = "2"
      @file_content = "xyz"
      @file_name    = "#{@record_id}#{TestScalableStore::Separator}#{@alt_rec_id}.csv"
      @file_path    = File.join('test', 'fstore', 'test_scalable_stores', '96', 'c2', 'c5', 'c0', @file_name)
      FileUtils.mkdir_p(File.dirname(@file_path))
      File.open(@file_path, 'w') {|f| f.write @file_content}
      @file_names   = assert_no_dir_content_difference('test/fstore/test_scalable_stores', %w|* * * * **|) {
        @ts = TestScalableStore.new(:file_name => @file_name)
      }
      @expected_file_name = "test/fstore/test_scalable_stores/96/c2/c5/c0/#{@record_id}#{TestScalableStore::Separator}#{@alt_rec_id}.csv"
    end

    teardown do
      path = File.dirname(File.dirname(File.dirname(File.dirname(@file_path))))
      raise ArgumentError, "You may be 'rm -rf'-ing the wrong path: '#{path}'. Aborting!" unless \
        path =~ %r|test/fstore/test_scalable_stores/.*|
      FileUtils.rm_rf(path)
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
