require 'net-ldap'

class Adap

  REQUIRED_ATTRIBUTES = [:cn, :sn, :uid, :uidnumber, :gidnumber, :homedirectory, :displayname, :unixhomedirectory, :loginshell, :gecos, :givenname]
  #REQUIRED_ATTRIBUTES = ['cn', 'sn', 'uid', 'uidNumber', 'gidNumber', 'homeDirectory', 'loginShell', 'gecos', 'givenName']

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

    @ad_host                  = params[:ad_host]
    @ad_port                  = (params[:ad_port] ? params[:ad_port] : 389)
    @ad_binddn                = params[:ad_binddn]
    @ad_basedn                = params[:ad_basedn]
    @ad_auth                  = (params.has_key?(:ad_password) ? { :method => :simple, :username => @ad_binddn, :password => params[:ad_password] } : nil)
    @ldap_host                = params[:ldap_host]
    @ldap_port                = (params[:ldap_port] ? params[:ldap_port] : 389)
    @ldap_binddn              = params[:ldap_binddn]
    @ldap_basedn              = params[:ldap_basedn]
    @ldap_user_basedn         = params[:ldap_user_basedn]
    @ldap_auth                = (params.has_key?(:ldap_password) ? { :method => :simple, :username => @ldap_binddn, :password => params[:ldap_password] } : nil )
    @password_hash_algorithm  = (params[:password_hash_algorithm] ? params[:password_hash_algorithm] : 'virtualCryptSHA512')

    @ad_client    = Adap::get_ad_client_instance(@ad_host, @ad_port, @ad_auth)
    @ldap_client  = Adap::get_ldap_client_instance(@ldap_host, @ldap_port, @ldap_auth)
  end

  def self.get_ad_client_instance(ad_host, ad_port, ad_auth)
    ad_client = Net::LDAP.new(:host => ad_host, :port => ad_port, :auth => ad_auth)
  end

  def self.get_ldap_client_instance(ldap_host, ldap_port, ldap_auth)
    ldap_client = Net::LDAP.new(:host => ldap_host, :port => ldap_port, :auth => ldap_auth)
  end

  def get_ad_dn(username)
    "CN=#{username},CN=Users,#{@ad_basedn}"
  end

  def get_ldap_dn(username)
    "uid=#{username},ou=Users,#{@ldap_basedn}"
  end

  def create_ldap_attributes(entry)
    attributes = {}
    attributes = {
      :objectclass => ["top", "person", "organizationalPerson", "inetOrgPerson", "posixAccount", "shadowAccount"]
    }
    entry.each do |attribute, values|
      #puts "#{attribute} --- #{values}" if REQUIRED_ATTRIBUTES.include?(attribute)
      if REQUIRED_ATTRIBUTES.include?(attribute) then
        if attribute == :unixhomedirectory then
          attributes[:homedirectory] = values
        else
          attributes[attribute] = values
        end
      end
    end

    attributes
  end

  def get_password(username)
    password = get_raw_password(username, @password_hash_algorithm)

    if password == nil || password.empty?
      raise "Failed to get password of #{username} from AD. Did you enabled AD password option virtualCryptSHA512 and/or virtualCryptSHA256?"
    end
    password = password.chomp

    password
  end

  def get_raw_password(username, algo)
    output = `samba-tool user getpassword #{username} --attribute #{algo} 2> /dev/null | grep -E '^virtualCrypt' -A 1 | tr -d ' \n' | cut -d ':' -f 2`
  end

  def sync_user(username)
    ad_entry    = nil
    ldap_entry  = nil
    ad_dn       = get_ad_dn(username)
    ldap_dn     = get_ldap_dn(username)

    # dn: CN=user-name,CN=Users,DC=mysite,DC=example,DC=com
    @ad_client.search(:base => ad_dn) do |entry|
      ad_entry = entry
    end
    ret_code = @ad_client.get_operation_result.code

    return {
      :code => ret_code,
      :message => "Failed to get a user #{ad_dn} from AD - " + @ad_client.get_operation_result.error_message
    } if ret_code != 0 && ret_code != 32

    # dn: uid=tsutomu-nakamura,ou=Users,dc=teraintl,dc=co,dc=jp
    @ldap_client.search(:base => ldap_dn) do |entry|
      ldap_entry = entry
    end
    ret_code = @ldap_client.get_operation_result.code

    return {
      :code => ret_code,
      :message => "Failed to get a user #{ldap_dn} from LDAP - " + @ldap_client.get_operation_result.error_message
    } if ret_code != 0 && ret_code != 32

    ret = nil

    if !ad_entry.nil? and ldap_entry.nil? then
      ret = add_user(ldap_dn, ad_entry, get_password(username))
    elsif ad_entry.nil? and !ldap_entry.nil? then
      ret = delete_user(ldap_dn)
    elsif !ad_entry.nil? and !ldap_entry.nil? then
      ret = modify_user(ldap_dn, ad_entry, ldap_entry, get_password(username))
    end
    # Do nothing if (ad_entry.nil? and ldap_entry.nil?)

    return (ret != nil ? ret : {:code => 1, :message => "There are no any data of #{username} to sync."})
  end

  def add_user(ldap_user_dn, ad_entry, password)
    attributes = create_ldap_attributes(ad_entry)

    @ldap_client.add(
      :dn => ldap_user_dn,
      :attributes => attributes
    )

    return {
      :code => @ldap_client.get_operation_result.code,
      :message => "Failed to add a user #{ldap_user_dn} in add_user() - " + @ldap_client.get_operation_result.error_message
    } if @ldap_client.get_operation_result.code != 0

    @ldap_client.modify(
      :dn => ldap_user_dn,
      :operations => [
        [:add, :userPassword, password]
      ]
    )

    return {
      :code => @ldap_client.get_operation_result.code,
      :message => "Failed to modify a user #{ldap_user_dn} in add_user() - " + @ldap_client.get_operation_result.error_message
    } if @ldap_client.get_operation_result.code != 0

    return {:code => @ldap_client.get_operation_result.code, :message => nil}
  end

  def modify_user(ldap_user_dn, ad_entry, ldap_entry, password)
    # An attribute objectClass will not be sync because it assumed already added by add_user() function or another method in LDAP.
    operations = create_modify_operations(ad_entry, ldap_entry, password)

    @ldap_client.modify(
      :dn => ldap_user_dn,
      :operations => operations
    )

    return {
      :code => @ldap_client.get_operation_result.code,
      :message => "Failed to modify a user #{ldap_user_dn} in modify_user() - " + @ldap_client.get_operation_result.error_message
    } if @ldap_client.get_operation_result.code != 0

    return {:code => @ldap_client.get_operation_result.code, :message => nil}
  end

  def create_modify_operations(ad_entry, ldap_entry, password)
    operations = []

    ad_entry.each do |key, value|
      if REQUIRED_ATTRIBUTES.include?(key)
        next if value == ldap_entry[key]
        operations.push((ldap_entry.key?(key) ? [:replace, key, value] : [:add, key, value]))
      end
    end

    ldap_entry.each_key do |key|
      if REQUIRED_ATTRIBUTES.include?(key)
        operations.push([:delete, key, nil]) if !ad_entry.key?(key)
      end
    end

    # AD does not have password as simple ldap attribute.
    # So password will always be updated for the reason.
    operations.push([:replace, :userpassword, password])

    operations
  end

  def delete_user(ldap_user_dn)
    @ldap_client.delete(:dn => ldap_user_dn)

    return {
      :code => @ldap_client.get_operation_result.code,
      :message => "Failed to delete a user #{ldap_user_dn} in delete_user() - " + @ldap_client.get_operation_result.error_message
    } if @ldap_client.get_operation_result.code != 0

    return {:code => @ldap_client.get_operation_result.code, :message => nil}
  end

  def display
    "Hello world"
  end
end

