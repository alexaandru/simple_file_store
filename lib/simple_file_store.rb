# Load BlankSlate
require File.join(File.dirname(__FILE__), 'mini_blank_slate')

# Load all SimpleFileStore libs
Dir[File.join(File.dirname(__FILE__), 'simple_file_store', '*.rb')].each do |lib|
  require lib
end
