#
# SimpleFileStore implements a micro-framework for mundane file
# operations such as storing or loading a file.
#
# At it's core it does one of two things:
#
#  * auto loads a file (if :file_name => <file_name> is passed)
#  * auto stores a file (if :content => <content> is passed)
#
# To put it simple, if you give it some content, it will store it
# and give you a file name. If you give it a file name it will load
# the file content.
#
# This class is not intended to perform any other work, than just
# this basic one. Any extra functionality will be layered on top
# of it (see for example ScalableFileStore or SecureFileStore).
#
# It also offers a very handy way of composing/deomposing file names:
# you simply indicate the tokens that should compose the filename,
# and it will auto construct the file name (on content auto saving),
# respectiely it will decompose the file name into tokens when auto
# loading date from file.
#

#
# TODO: implement further validations (file name components should 
# not be blank, etc.)
#
require 'pathname'
require 'active_support/inflector'

class SimpleFileStore

  FileStoreRoot = "fstore".freeze
  Separator     = "-".freeze

  attr_accessor :root, :current_file, :content_type, :timestamp, :usec
  attr :content
  attr :file_name

  def self.file_name_tokens(*args)
    unless args.empty?
      @file_name_tokens = args
      @file_name_tokens.each do |token| 
        next if [:timestamp, :usec].include?(token.to_sym)
        instance_eval { attr_accessor token }
      end
    end
    @file_name_tokens
  end

  def initialize(args = {})
    init_root!
    validate!
    load_arguments(args)
    load_or_store!
  end

  def path
    root.join(self.class.name.tableize, file_name)
  end

  def file_name=(new_name)
    if new_name =~ /^(.*)\.(.*?)$/
      @file_name, self.content_type = new_name, $2
      file_name_tokens.zip($1.split(Separator)) {|(k, v)| send("#{k}=", v)}
    else
      raise ArgumentError, "Unrecognized file name: #{new_name}"
    end
  end

  def content=(new_content)
    @content = if new_content.respond_to?(:read) then    new_content.read
               elsif new_content.respond_to?(:to_s) then new_content.to_s
               else                                      new_content
               end
  end

  def open(flag = 'r+', &block)
    self.current_file = path
    current_file.dirname.mkpath
    FileUtils.touch(current_file)
    File.open(current_file, flag, &block)
  end

  protected

  def load_or_store!
    open {|f| content.nil? ? pull(f) : push(f)}
  end

  def pull(f)
    self.content = f.read
  end

  def push(f)
    f.write(content)
  end

  private

  def init_root!
    self.root ||= case
                  when defined?(Rails) then   Rails.root
                  when defined?(AppRoot) then AppRoot.is_a?(Pathname) ? AppRoot : Pathname.new(AppRoot.to_s)
                  else                        Pathname.new(File.dirname(File.dirname(File.dirname(__FILE__))))
                  end.join(FileStoreRoot)
  end

  def validate!
    raise Errno::ENOENT, "Root not found: #{root}!" unless root.exist?
  end

  def load_arguments(args)
    # passed (as-is) args
    args = {:content_type => 'csv'}.merge(args)
    args.each {|(k,v)| send "#{k}=", v}

    # custom (builtin) args
    t = Time.now
    self.timestamp = t.to_i
    self.usec      = t.usec

    # hybrid args (depending on passed+builtin)
    @file_name ||= file_name_tokens.map{|k| send(k)}.join(Separator) << '.' << content_type
  end

  def file_name_tokens
    self.class.file_name_tokens
  end

end
