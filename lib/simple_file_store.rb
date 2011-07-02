# Load BlankSlate
require File.join(File.dirname(__FILE__), 'mini_blank_slate')

# Load all SimpleFileStore libs
%w|simple_file_store scalable_file_store secure_file_store caching_file_store|.each {|lib|
  require File.join(File.dirname(__FILE__), 'simple_file_store', lib)
}
