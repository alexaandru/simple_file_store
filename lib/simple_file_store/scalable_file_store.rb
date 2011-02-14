#
# This adds transparent file path scalability (by using
# 4 depth trees hierarchy based on the file name). 
#
# This allows one to have as many files (as the underlying
# filesystem allows) without every having to worry about
# too many files under one folder.
#
class ScalableFileStore < SimpleFileStore

  attr_accessor :inter_tree

  def file_name
    super; scale_path!
    @file_name
  end

  def file_name=(new_name)
    super; scale_path!
    @file_name
  end

  def path
    scale_path!
    root.join(self.class.name.tableize, inter_tree, file_name)
  end

  private

  def scale_path!
    raise ArgumentError, "Cowardly refusing to scale empty filename" if @file_name.nil?

    @inter_tree ||= begin
      h = @file_name.hash.abs.to_s
      File.join(*[h[0,2],h[2,2],h[4,2],h[6,2]].reject{|z| z.nil? || z.empty?})
    end
  end

end
