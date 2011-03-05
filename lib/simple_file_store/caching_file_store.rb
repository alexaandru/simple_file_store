#
# This adds a transparent file caching layer.
#
# Behavior: when neither file_name nor content are
# provided, the generate_content() method is called
# and the output loaded into file (and thus, the
# file autosaved).
#
# Requirements: a generate_content() method.
#
# TODO: Implement an easy way to select the caching method
# vs. use the current convention.
# TODO: imlpement some hooks in base class, so that redefining
# methods should not be necessary.
#

module CachingFileStore

  protected

  def load_or_store!
    self.content = generate_content unless File.exist?(path)
    open {|f| content.nil? ? pull(f) : push(f)}
  end

  def generate_content
    raise NoMethodError, "You must implement the method yourself"
  end

end
