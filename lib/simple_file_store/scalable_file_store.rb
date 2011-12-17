#
# This adds transparent file path scalability (by using
# 4 depth trees hierarchy based on the file name). 
#
# This allows one to have as many files (as the underlying
# filesystem allows) without every having to worry about
# too many files under one folder.
#

require 'digest'
module ScalableFileStore

  def path
    scale_path
    root.join(self.class.name.tableize, @inter_tree, file_name)
  end

  private

  def scale_path
    raise ArgumentError, "Cowardly refusing to scale empty filename" if file_name.nil?

    @inter_tree ||= begin
      h = Digest::SHA256.hexdigest(file_name)
      File.join(*[h[0,2],h[2,2],h[4,2],h[6,2]].reject{|z| z.nil? || z.empty?})
    end
  end

end
