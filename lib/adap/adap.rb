require 'net-ldap'

class Adap
  def initialize()
    puts "no arguments"
  end

  #
  # params {
  #   :ad_host     required                                     IP or hostname of AD.
  #   :ad_port     optional (default:389)                       Port of AD host.
  #   :ad_binddn   required                                     Binddn of AD.
  #   :ad_basedn   required                                     Basedn of AD users.
  #   :ad_password optional (default:(empty))                   Password of AD with :ad_binddn.
  #   :ldap_host     required                                   IP or hostname of NT.
  #   :ldap_port     optional (default:389)                     Port of NT host.
  #   :ldap_binddn   required                                   Binddn of NT.
  #   :ldap_basedn   required                                   Basedn of NT users.
  #   :ldap_password optional (default:(same as :ad_password))  Password of NT with :ldap_binddn
  # }
  #
  def initialize(params)
    raise "Initialize Adap was failed. params must not be nil" if params == nil
    #raise 'Adap requires keys of parameter "ad_host" "ad_binddn" "ad_basedn"' \
    [:ad_host, :ad_binddn, :ad_basedn, :ldap_host, :ldap_binddn, :ldap_basedn].each { |k|
      raise 'Adap requires keys in params ":ad_host", ":ad_binddn", ":ad_basedn", ":ldap_host", ":ldap_binddn", ":ldap_basedn"' if !params.key?(k)
    }

    @ad_host            = params[:ad_host]
    @ad_port            = (params[:ad_port] ? params[:ad_port] : '389')
    @ad_binddn          = params[:ad_binddn]
    @ad_basedn          = params[:ad_basedn]
    @ad_auth            = (params.has_key?(:ad_password) ? { :method => :simple, :username => @ad_binddn, :password => params[:ad_password] } : nil)
    @ldap_host          = params[:ldap_host]
    @ldap_binddn        = params[:ldap_binddn]
    @ldap_user_basedn   = params[:ldap_user_basedn]
    @ldap_auth          = (params.has_key?(:ldap_password) ? { :method => :simple, :username => @ldap_binddn, :password => params[:ldap_password] } : nil )

    @ad_client = Net::LDAP.new(
      :host => @ad_host,
      :port => @ad_port,
      :auth => @ad_auth
    )
    #raise "Failed to connect AD at ldap://#{@ad_host}:#{@ad_port} with bindDn #{@ad_binddn}" if !ad.bind

    @ldap_client = Net::LDAP.new(
      :host => @ldap_host,
      :port => @ldap_port,
      :auth => @ldap_auth
    )
    #raise "Failed to connect Ldap at ldap://#{@ldap_host}:#{@ldap_port} with bindDn #{@ldap_binddn}" if !ldap.bind
  end

  def get_ad_dn(username)
    "CN=#{username},CN=Users,#{@ad_basedn}"
  end

  def get_ldap_dn(username)
    "uid=#{username},ou=Users,#{@ldap_basedn}"
  end

  def get_attributes(entry)
    attributes {}
    entry.each do |attribute, values|
    end

  end

  def sync_user(username)

    # filter = Net::LDAP::Filter.eq("cn",cn)
    ad_entry = nil
    ldap_entry = nil

    # dn: CN=user-name,CN=Users,DC=mysite,DC=example,DC=com
    @ad_client.search( :base => get_ad_dn(username) ) do |entry|
      ad_entry = entry
    end

    # dn: uid=tsutomu-nakamura,ou=Users,dc=teraintl,dc=co,dc=jp
    @ldap_client.search( :base => get_ldap_dn(username) ) do |entry|
      ldap_entry = entry
    end

    puts "AD DN: " + (ad_entry.nil? ? "(nil)" : ad_entry.dn)
    puts "Ldap DN: " + (ldap_entry.nil? ? "(nil)" : ldap_entry.dn )

    if !ad_entry.nil? and ldap_entry.nil? then
      # Create new user
      puts "Create a new user"
    elsif ad_entry.nil? and !ldap_entry.nil? then
      # Delete a user
      puts "Delete a user"
    elsif !ad_entry.nil? and !ldap_entry.nil? then
      # Update a user
      puts "Update a user"
    end
    # Do nothing if (ad_entry.nil? and ldap_entry.nil?)

  end

  def add_user(username, attributes)
    @ldap_client.add(
      :dn => get_ldap_dn(username),
      :attributes => {
        :objectclass => ["top", "person", "organizationalPerson", "posixAccount", "shadowAccount", "inetOrgPerson"],
        :cn => username,
        :sn => username,
      }
    )
  end

#  def delete_user(username)
#
#  end

  def display
    "Hello world"
  end
end

