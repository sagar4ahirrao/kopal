#== <tt>kopal_config.yml</tt>.
#<tt>kopal_config.yml</tt> contains configuration options for Kopal as a Hash, keys made of +:symbols+.
#[<tt>:authntication_method</tt>]
#  Default is +:builtin+, may have a *string* value containing
#  the name of authentication method of +ApplicationController+ which acts in following ways.
#  If the user is authenticated, this method should return true, otherwise should
#  authenticate the user (may redirect to the authentication page for authentication) and
#  return +false+ or +nil+.
#[<tt>:account_password</tt>] Required if +:authentication_method+ is +:builtin+.
#
#== Themes for Kopal.
# *work in progress, not yet implemented*
#=== Available @page variables.
#[<tt>@page.title</tt>] Title of the page. Goes in +<title></title>+
#[<tt>@page.description</tt>] Description of the page. Goes in +<meta name="Description" />+
#[<tt>@page.stylesheets</tt>] 
#  Path of stylesheets for page.
#  Example Usage - 
#  * +@page.stylesheets = 'home'+
#  * +@page.stylesheets = ['home', 'home2'] #Two stylesheets+
#  * +@page.stylesheets = [{:name => 'home'}, {:name => 'home2', :media => 'print'}]+
#
#=== Available containers
# * +:page_head_meta_content+
# * +:page_bottom_content+
# * +:surface_right_content+

class Kopal
  DISCOVERY_PROTOCOL_REVISION = "0.1.alpha"
  FEED_PROTOCOL_REVISION = "0.1.alpha"
  CONFIG_FILE_ADDRESS = RAILS_ROOT + '/config/kopal.yml'

  def self.create_config_file
    return if File.exists?(CONFIG_FILE_ADDRESS)
    #default data -
    @@config = {
      :authentication_method => :builtin,
      :account_password => 'secret01'
    }
    File.open(CONFIG_FILE_ADDRESS, "w") { |out|
      out << YAML::dump(@@config)
    }
  end

  def self.read_config_file
    #No call to create_config_file from here, an Invalid file error will
    # => make sure that Kopal is not installed.
    @@config = YAML::load_file(CONFIG_FILE_ADDRESS)
  end
  class << self; alias_method :reload_config_file, :read_config_file; end

  def self.config index
    read_config_file unless @@config
    @@config[index]
  end

  def self.[] index
    k = KopalPreference.find_by_preference_name(index)
    return k.preference_text if k
    return nil
  end

  def self.[]= index, value
    k = KopalPreference.find_or_initialize_by_preference_name(index)
    k.preference_text = value
    k.save!
  end
end
