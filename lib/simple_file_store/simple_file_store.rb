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
# not be blank, etc.);
# TODO: make FileStoreRoot and Separator configurable.
#
require 'pathname'
require 'fileutils'
require 'rubygems'
require 'active_support/inflector'

module SimpleFileStore

  class Base < MiniBlankSlate

    KnownFeatures = Dir.glob(File.join(File.dirname(__FILE__), '*_file_store.rb')).map do |f|
      f =~ %r|.*/([a-z]+)_file_store.rb$|
      $1 && $1 != 'simple' ? $1 : nil
    end.compact.freeze
    FileStoreRoot = "fstore".freeze
    Separator     = "-".freeze

    attr_accessor :root, :content_type, :timestamp, :usec
    attr :content
    attr :file_name

    class << self
      def file_name_tokens(*args)
        @file_name_tokens ||= []
        unless args.empty?
          @file_name_tokens.concat(args)
          args.each do |token|
            next if [:timestamp, :usec].include?(token.to_sym)
            instance_eval { attr_accessor token }
          end
        end
        @file_name_tokens
      end

      def features(*args)
        args = args.flatten.compact
        raise ArgumentError, "Unknown feature" unless args.all?{|a| KnownFeatures.include?(a.to_s)}

        args.each do |a|
          instance_eval { include "#{a}_file_store".classify.constantize }
        end
      end
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
      return false if new_name.nil? || new_name.empty?

      if new_name =~ /^(.*)\.(.*?)$/
        @file_name, self.content_type = new_name, $2
        file_name_tokens.zip($1.split(Separator)) {|(k, v)| __send__("#{k}=", v)}
      else
        raise ArgumentError, "Unrecognized file name: #{new_name}"
      end
    end

    def content=(new_content)
      return false if new_content.nil?

      @content = if new_content.respond_to?(:read) then    new_content.read
                 elsif new_content.respond_to?(:to_s) then new_content.to_s
                 else                                      new_content
                 end
    end

    def open(flag = 'r+', &block)
      path.dirname.mkpath
      FileUtils.touch(path)
      File.open(path, flag, &block)
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
                    else                        Pathname.new(FileUtils.pwd)
                    end.join(FileStoreRoot)
    end

    def validate!
      raise Errno::ENOENT, "Root not found: #{root}!" unless root.exist?
    end

    def load_arguments(args)
      # passed (as-is) args
      args = {:content_type => 'csv'}.merge(args)
      args.each {|(k,v)| __send__ "#{k}=", v}

      # custom (builtin) args
      t = Time.now
      self.timestamp = t.to_i
      self.usec      = t.usec

      # hybrid args (depending on passed+builtin)
      @file_name ||= file_name_tokens.map{|k| __send__(k)}.join(Separator) << '.' << content_type
    end

    def file_name_tokens
      self.class.file_name_tokens
    end

  end

end
