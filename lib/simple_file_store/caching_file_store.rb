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
#

module CachingFileStore

  def initialize(args = {})
    init_root!
    validate!
    args[:content] = generate_content if args[:content].nil? && args[:file_name].nil?
    load_arguments(args)
    load_or_store!
  end

  protected

  def generate_content
    raise NoMethodError, "You must implement the method yourself"
  end

end
