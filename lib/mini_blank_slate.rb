#
# Credit goes to Jim Weirich for the BlankSlate technique,
# adapted from his example at: http://onestepback.org/index.cgi/Tech/Ruby/BlankSlate.rdoc
#
class MiniBlankSlate

  BlankMethods = /^__|^instance_|object_id$|class$|inspect$|respond_to\?$/.freeze

  instance_methods.each do |m|
    m =~ BlankMethods or undef_method(m)
  end

end
