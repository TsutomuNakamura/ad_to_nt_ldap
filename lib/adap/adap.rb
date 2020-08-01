require 'net-ldap'

class Adap

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
  #   :password_hash_algorithm (default:virtualCryptSHA512)     Password hash algorithm. It must be same between AD and LDAP, and only support virtualCryptSHA512 or virtualCryptSHA256 now.
  # }
  #
  def initialize(params)
    raise "Initialize Adap was failed. params must not be nil" if params == nil

    [:ad_host, :ad_binddn, :ad_basedn, :ldap_host, :ldap_binddn, :ldap_basedn].each { |k|
      raise 'Adap requires keys in params ":ad_host", ":ad_binddn", ":ad_basedn", ":ldap_host", ":ldap_binddn", ":ldap_basedn"' if !params.key?(k)
    }

    # List of attributes for user in AD
    @ad_user_required_attributes   = [:cn, :sn, :uid, :uidnumber, :gidnumber, :displayname, :loginshell, :gecos, :givenname, :description, :mail, :unixhomedirectory]
    # List of attributes for user in LDAP
    @ldap_user_required_attributes = [:cn, :sn, :uid, :uidnumber, :gidnumber, :displayname, :loginshell, :gecos, :givenname, :description, :mail, :homedirectory]

    # List of supported hash algorithms keys and string values to operate
    @supported_hash_algorithms_map = {
      :md5                  => "{MD5}",
      :sha                  => "{SHA}",
      :ssha                 => "{SSHA}",
      :virtual_crypt_sha256 => "virtualCryptSHA256",
      :virtual_crypt_sha512 => "virtualCryptSHA512"
    }

    @ad_host                  = params[:ad_host]
    @ad_port                  = (params[:ad_port] ? params[:ad_port] : 389)
    @ad_binddn                = params[:ad_binddn]
    @ad_basedn                = params[:ad_basedn]
    @ad_auth                  = (params.has_key?(:ad_password) ? { :method => :simple, :username => @ad_binddn, :password => params[:ad_password] } : nil)
    @ldap_host                = params[:ldap_host]
    @ldap_port                = (params[:ldap_port] ? params[:ldap_port] : 389)
    @ldap_binddn              = params[:ldap_binddn]
    @ldap_suffix_ou           = (params[:ldap_suffix_ou] ? params[:ldap_suffix_ou] : "ou=Users")
    @ldap_basedn              = params[:ldap_basedn]
    @ldap_user_basedn         = params[:ldap_user_basedn]
    @ldap_auth                = (params.has_key?(:ldap_password) ? { :method => :simple, :username => @ldap_binddn, :password => params[:ldap_password] } : nil )

    # A password-hash algorithm to sync to the LDAP.
    # Popular LDAP products like Open LDAP usually supports md5({MD5}), sha1({SHA}) and ssha({SSHA}) algorithms.
    # If you want to use virtualCryptSHA256 or virtualCryptSHA512, you have to set additional configurations to OpenLDAP.
    @password_hash_algorithm  = (params[:password_hash_algorithm] ? params[:password_hash_algorithm] : :ssha)
    # TODO: Check a hash algorithm is supported or not
    unless @supported_hash_algorithms_map.has_key?(@password_hash_algorithm) then
      raise "This program only supports :md5, :sha, :ssha(default), :virtual_crypt_sha256 and :virtual_crypt_sha512 " \
            + "as :password_hash_algorithm. " \
            + "An algorithm you chose #{@password_hash_algorithm.is_a?(Symbol) ? ":" : ""}#{@password_hash_algorithm} was unsupported."
    end

    # Phonetics are listed in https://lists.samba.org/archive/samba/2017-March/207308.html
    @map_ad_msds_phonetics = {}
    @map_ldap_msds_phonetics = {}
    if params[:map_msds_phonetics] != nil
      p = params[:map_msds_phonetics]
      # msDS-PhoneticCompanyName => companyName;lang-ja;phonetic
      create_map_phonetics(p, :'msds-phoneticcompanyname') if p[:'msds-phoneticcompanyname'] != nil
      # msDS-PhoneticDepartment => department;lang-ja;phonetic
      create_map_phonetics(p, :'msds-phoneticdepartment') if p[:'msds-phoneticdepartment'] != nil
      # msDS-PhoneticFirstName => firstname;lang-ja;phonetic
      create_map_phonetics(p, :'msds-phoneticfirstname') if p[:'msds-phoneticfirstname'] != nil
      # msDS-PhoneticLastName => lastname;lang-ja;phonetic
      create_map_phonetics(p, :'msds-phoneticlastname') if p[:'msds-phoneticlastname'] != nil
      # msDS-PhoneticDisplayName => displayname;lang-ja;phonetic
      create_map_phonetics(p, :'msds-phoneticdisplayname') if p[:'msds-phoneticdisplayname'] != nil
    end

    @ad_client    = Adap::get_ad_client_instance(@ad_host, @ad_port, @ad_auth)
    @ldap_client  = Adap::get_ldap_client_instance(@ldap_host, @ldap_port, @ldap_auth)
  end

  private def create_map_phonetics(p, ad_phonetics)
    @map_ad_msds_phonetics[ad_phonetics] = p[ad_phonetics]
    @map_ldap_msds_phonetics[p[ad_phonetics]] = ad_phonetics
    @ad_user_required_attributes.push(ad_phonetics)
    @ldap_user_required_attributes.push(p[ad_phonetics])
  end

  def self.get_ad_client_instance(ad_host, ad_port, ad_auth)
    Net::LDAP.new(:host => ad_host, :port => ad_port, :auth => ad_auth)
  end

  def self.get_ldap_client_instance(ldap_host, ldap_port, ldap_auth)
    Net::LDAP.new(:host => ldap_host, :port => ldap_port, :auth => ldap_auth)
  end

  def get_ad_dn(username)
    "CN=#{username},CN=Users,#{@ad_basedn}"
  end

  def get_ldap_dn(username)
    "uid=#{username},#{@ldap_suffix_ou},#{@ldap_basedn}"
  end

  def create_ldap_attributes(ad_entry)
    attributes = {
      :objectclass => ["top", "person", "organizationalPerson", "inetOrgPerson", "posixAccount", "shadowAccount"]
    }

   ad_entry.each do |attribute, values|
      # Change string to lower case symbols to compare each attributes correctly
      sym_attribute = attribute.downcase.to_sym

      if @ad_user_required_attributes.include?(sym_attribute) then
        if sym_attribute == :unixhomedirectory then
          attributes[:homedirectory] = values
        elsif @map_ad_msds_phonetics.has_key?(sym_attribute) && ad_entry[attribute].length != 0
          # entry always returns an array that length 0 if the attribute does not existed.
          # So no need to check whether the ad_entry[attribute] is nil or not.
          attributes[@map_ad_msds_phonetics[sym_attribute]] = values
        else
          attributes[sym_attribute] = values
        end
      end
    end

    attributes
  end

  def get_password_hash(username, password)
    case @password_hash_algorithm
    when :md5, :sha, :ssha then
      if password.nil? then
        raise "Password must not be nil when you chose the algorithm of password-hash is :md5 or :sha or :ssha. Pass password of #{username} please."
      end
      result = Net::LDAP::Password.generate(@password_hash_algorithm, password)
    else
      # Expects :virtual_crypt_sha256(virtualCryptSHA256) or :virtual_crypt_sha512(virtualCryptSHA512)
      result = get_raw_password_from_ad(username, @supported_hash_algorithms_map[@password_hash_algorithm])
    end

    if result.nil? or result.empty? then
      raise "Failed to get hashed password with algorithm :#{@password_hash_algorithm} of user #{username}. " +
        "Its result was nil. If you chose hash-algorithm :virtual_crypt_sha256 or :virtual_crypt_sha512, " +
        "did you enabled AD to store passwords as virtualCryptSHA256 and/or virtualCryptSHA512 in your smb.conf? " +
        "This program requires the configuration to get password from AD as virtualCryptSHA256 or virtualCryptSHA512."
    end

    result.chomp
  end

  def get_raw_password_from_ad(username, algo)
    `samba-tool user getpassword #{username} --attribute #{algo} 2> /dev/null | grep -E '^virtualCrypt' -A 1 | tr -d ' \n' | cut -d ':' -f 2`
  end

  def sync_user(uid, password=nil)
    ad_entry    = nil
    ldap_entry  = nil
    ad_dn       = get_ad_dn(uid)
    ldap_dn     = get_ldap_dn(uid)

    # dn: CN=user-name,CN=Users,DC=mysite,DC=example,DC=com
    @ad_client.search(:base => ad_dn) do |entry|
      ad_entry = entry
    end
    ret_code = @ad_client.get_operation_result.code

    # Return 32 means that the object does not exist
    return {
      :code => ret_code,
      :operations => nil,
      :message => "Failed to get a user #{ad_dn} from AD - " + @ad_client.get_operation_result.error_message
    } if ret_code != 0 && ret_code != 32

    @ldap_client.search(:base => ldap_dn) do |entry|
      ldap_entry = entry
    end
    ret_code = @ldap_client.get_operation_result.code

    return {
      :code => ret_code,
      :operations => nil,
      :message => "Failed to get a user #{ldap_dn} from LDAP - " + @ldap_client.get_operation_result.error_message
    } if ret_code != 0 && ret_code != 32

    ret = nil
    if !ad_entry.nil? and ldap_entry.nil? then
      ret = add_user(ldap_dn, ad_entry, get_password_hash(uid, password))
    elsif ad_entry.nil? and !ldap_entry.nil? then
      ret = delete_user(ldap_dn)
    elsif !ad_entry.nil? and !ldap_entry.nil? then
      ret = modify_user(ldap_dn, ad_entry, ldap_entry, get_password_hash(uid, password))
    else
      # ad_entry.nil? and ldap_entry.nil? then
      return {:code => 0, :operations => nil, :message => "There are not any data of #{uid} to sync."}
    end

    return ret if ret[:code] != 0

    # Sync groups belonging the user next if syncing data of the user has succeeded.
    ret_sync_group = sync_group_of_user(uid, get_primary_gidnumber(ad_entry))

    return {
      :code => ret_sync_group[:code],
      :operations => ret[:operations].concat(ret_sync_group[:operations]),
      :message => (
        ret_sync_group[:code] == 0 ?
          nil : "Syncing a user #{uid} has succeeded but syncing its groups have failed. Message: " + ret_sync_group[:message]
      )
    }
  end

  def add_user(ldap_user_dn, ad_entry, password)
    if password == nil || password.empty?
      raise "add_user() requires password. Set a hashed password of the user #{ad_entry[:cn]} please."
    end

    attributes = create_ldap_attributes(ad_entry)

    @ldap_client.add(
      :dn => ldap_user_dn,
      :attributes => attributes
    )
    ret_code = @ldap_client.get_operation_result.code

    return {
      :code => ret_code,
      :operations => [:add_user],
      :message => "Failed to add a user #{ldap_user_dn} in add_user() - " + @ldap_client.get_operation_result.error_message
    } if ret_code != 0

    @ldap_client.modify(
      :dn => ldap_user_dn,
      :operations => [
        [:add, :userPassword, password]
      ]
    )
    ret_code = @ldap_client.get_operation_result.code

    return {
      :code => ret_code,
      :operations => [:add_user],
      :message => "Failed to modify a user #{ldap_user_dn} to add userPassword in add_user() - " + @ldap_client.get_operation_result.error_message
    } if ret_code != 0

    return {:code => ret_code, :operations => [:add_user], :message => nil}
  end

  def modify_user(ldap_user_dn, ad_entry, ldap_entry, password)
    # An attribute objectClass will not be sync because it assumed already added by add_user() function or another method in LDAP.
    operations = create_modify_operations(ad_entry, ldap_entry, password)

    @ldap_client.modify(
      :dn => ldap_user_dn,
      :operations => operations
    )
    ret_code = @ldap_client.get_operation_result.code

    return {
      :code => ret_code,
      :operations => [:modify_user],
      :message => "Failed to modify a user #{ldap_user_dn} in modify_user() - " + @ldap_client.get_operation_result.error_message
    } if ret_code != 0

    return {:code => ret_code, :operations => [:modify_user], :message => nil}
  end

  def create_modify_operations(ad_entry, ldap_entry, password)
    operations = []

    ad_entry.each do |key, value|
      ad_key_sym    = key.downcase.to_sym
      ldap_key = if ad_key_sym == :unixhomedirectory
                   :homedirectory
                 elsif @map_ad_msds_phonetics.has_key?(ad_key_sym)
                   @map_ad_msds_phonetics[ad_key_sym]
                 else
                   ad_key_sym
                 end
      ldap_key_sym  = ldap_key.downcase.to_sym

      # TODO: Can @ad_user_required_attributes.include? be put more early line?
      if @ad_user_required_attributes.include?(ad_key_sym) && value != ldap_entry[ldap_key]
        #next if value == ldap_entry[ldap_key]
        operations.push((ldap_entry[ldap_key] != nil ? [:replace, ldap_key_sym, value] : [:add, ldap_key_sym, value]))
      end
    end

    ldap_entry.each do |key, value|
      ldap_key_sym  = key.downcase.to_sym
      #ad_key        = (ldap_key_sym != :homedirectory ? ldap_key_sym : :unixhomedirectory)
      ad_key        = if ldap_key_sym == :homedirectory
                        :unixhomedirectory
                      elsif @map_ldap_msds_phonetics.has_key?(ldap_key_sym)
                        @map_ldap_msds_phonetics[ldap_key_sym]
                      else
                        ldap_key_sym
                      end

      if @ldap_user_required_attributes.include?(ldap_key_sym) && ad_entry[ad_key] == nil
        operations.push([:delete, ldap_key_sym, nil])
      end
    end

    # AD does not have password as simple ldap attribute.
    # So password will always be updated for this reason.
    if not password.nil? and not password.empty? then
      operations.push([:replace, :userpassword, password])
    end

    operations
  end

  def delete_user(ldap_user_dn)
    @ldap_client.delete(:dn => ldap_user_dn)
    ret_code = @ldap_client.get_operation_result.code

    return {
      :code => ret_code,
      :operations => [:delete_user],
      :message => "Failed to delete a user #{ldap_user_dn} in delete_user() - " + @ldap_client.get_operation_result.error_message
    } if ret_code != 0

    return {:code => ret_code, :operations => [:delete_user], :message => nil}
  end

  def sync_group_of_user(uid, primary_gid_number)
    ad_group_map = {}
    ldap_group_map = {}

    # Creating AD ldapsearch filter

    ad_filter = if primary_gid_number == nil then
      Net::LDAP::Filter.construct(
          "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,#{@ad_basedn})(member=CN=#{uid},CN=Users,#{@ad_basedn}))")
    else
      Net::LDAP::Filter.construct(
          "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,#{@ad_basedn})(|(member=CN=#{uid},CN=Users,#{@ad_basedn})(gidNumber=#{primary_gid_number})))")
    end

    # Get groups from AD
    # entry = {
    #   :gidnumber => xxx,
    # }
    #
    @ad_client.search(:base => @ad_basedn, :filter => ad_filter) do |entry|
      ad_group_map[entry[:name].first] = {:gidnumber => entry[:gidnumber]}
      #ad_group_map[entry[:name]] = nil
    end
    ret_code = @ad_client.get_operation_result.code

    return {
      :code => ret_code,
      :operations => [:search_groups_from_ad],
      :message => "Failed to get groups of a user #{uid} from AD to sync them. " + @ad_client.get_operation_result.error_message
    } if ret_code != 0 && ret_code != 32

    # Create LDAP ldapsearch filter
    ldap_filter = Net::LDAP::Filter.construct("(memberUid=#{uid})")

    # Get groups from LDAP
    @ldap_client.search(:base => "ou=Groups," + @ldap_basedn, :filter => ldap_filter) do |entry|
      # gidnumber is not necessary for LDAP entry
      ldap_group_map[entry[:cn].first] = nil
    end
    ret_code = @ldap_client.get_operation_result.code

    return {
      :code => ret_code,
      :operations => [:search_groups_from_ldap],
      :message => "Failed to get groups of a user #{uid} from LDAP to sync them. " + @ldap_client.get_operation_result.error_message
    } if ret_code != 0

    # Comparing name of AD's entry and cn of LDAP's entry
    operation_pool = create_sync_group_of_user_operation(ad_group_map, ldap_group_map, uid)
    ret = do_sync_group_of_user_operation(operation_pool)

    return {
      :code => ret[:code],
      :operations => [:modify_group_of_user],
      :message => (ret[:code] == 0 ? nil: ret[:message])
    }
  end

  # {
  #   "cn=foo,ou=Groups,dc=mysite,dc=example,dc=com": {
  #     :cn => "foo",
  #     :gidnumber => xxx,
  #     :operations => [[:add, :memberuid, uid]]
  #   }
  #   "cn=bar,ou=Groups,dc=mysite,dc=example,dc=com": {
  #     :cn => "bar",
  #     :gidnumber => yyy,
  #     :operations => [[:delete, :memberuid, uid]]
  #   }
  # }
  def create_sync_group_of_user_operation(ad_group_map, ldap_group_map, uid)
    operation_pool = {}

    ad_group_map.each_key do |key|
      dn = "cn=#{key},ou=Groups,#{@ldap_basedn}"
      # Convert AD entries to LDAP entries to create operation to update LDAP data.
      operation_pool[dn] = {
        :cn => key,
        :gidnumber => ad_group_map[key][:gidnumber],
        :operations => [[:add, :memberuid, uid]]
      } if !ldap_group_map.has_key?(key)
    end

    ldap_group_map.each_key do |key|
      operation_pool["cn=#{key},ou=Groups,#{@ldap_basedn}"] = {
        # :cn and :gidnumber are not necessary
        :operations => [[:delete, :memberuid, uid]]
      } if !ad_group_map.has_key?(key)
    end

    operation_pool
  end

  def do_sync_group_of_user_operation(operation_pool)
    return {
      :code => 0,
      :operations => nil,
      :message => "There are not any groups of user to sync"
    } if operation_pool.length == 0

    # ex)
    #   entry_key = "cn=bar,ou=Groups,dc=mysite,dc=example,dc=com"
    operation_pool.each_key do |entry_key|

      # ex)
      #   entry = {
      #     :cn => "bar",
      #     :gidnumber => 1000,
      #     :operations => [[:add, :memberuid, uid]]  # or [[:delete, :memberuid, uid]]
      #   }
      entry = operation_pool[entry_key]

      if entry[:operations].first.first == :add then
        ret = add_group_if_not_existed(entry_key, entry)
        return ret if ret[:code] != 0
      end
      # The operation will be like...
      # [[:add, :memberuid, "username"]] or [[:delete, :memberuid, "username"]]

      @ldap_client.modify({
        :dn => entry_key,
        :operations => entry[:operations]
      })
      ret_code = @ldap_client.get_operation_result.code

      return {
        :code => ret_code,
        :operations => [:modify_group_of_user],
        :message => "Failed to modify group \"#{entry_key}\" of user #{entry[:cn]}. " + @ldap_client.get_operation_result.error_message
      } if ret_code != 0

      if entry[:operations].first.first == :delete then
        ret = delete_group_if_existed_as_empty(entry_key)
        return ret if ret[:code] != 0
      end
    end

    return {:code => 0, :operations => [:modify_group_of_user], :message => nil}
  end

  def add_group_if_not_existed(group_dn, entry)
    @ldap_client.search(:base => group_dn)
    ret_code = @ldap_client.get_operation_result.code

    # The group already existed
    return {:code => 0, :operations => nil, :message => nil} if ret_code == 0

    # Failed to query ldapsearch for some reason
    return {
      :code => ret_code,
      :operations => nil,
      :message => "Failed to search LDAP in add_group_if_not_existed(). " + @ldap_client.get_operation_result.error_message
    } if ret_code != 32

    attributes = {:objectclass => ["top", "posixGroup"]}
    attributes[:gidnumber] = entry[:gidnumber] if entry[:gidnumber] != nil
    attributes[:cn] = entry[:cn] if entry[:cn] != nil

    @ldap_client.add(
      :dn => group_dn,
      :attributes => attributes
    )
    ret_code = @ldap_client.get_operation_result.code

    return {
      :code => ret_code,
      :operations => [:add_group],
      :message => (ret_code == 0 ? nil : "Failed to add a group in add_group_if_not_existed(). " + @ldap_client.get_operation_result.error_message)
    }
  end

  def delete_group_if_existed_as_empty(group_dn)
    is_no_memberuid = false
    # Check whether the group has memberuid
    @ldap_client.search(:base => group_dn, :filter => "(!(memberUid=*))") do |e|
      is_no_memberuid = true
    end

    ret_code = @ldap_client.get_operation_result.code
    return {:code => 0, :operations => nil, :message => nil} \
      if (ret_code == 0 && is_no_memberuid == false) || ret_code == 32

    return {
      :code => ret_code,
      :operations => nil,
      :message => "Failed to search group in delete_group_if_existed_as_empty(). " + @ldap_client.get_operation_result.error_message
    } if ret_code != 0

    @ldap_client.delete(:dn => group_dn)
    ret_code = @ldap_client.get_operation_result.code

    return {
      :code => ret_code,
      :operations => [:delete_group],
      :message => (ret_code == 0 ? nil: "Failed to delete a group in delete_group_if_existed_as_empty(). " + @ldap_client.get_operation_result.error_message)
    }
  end

  def get_primary_gidnumber(entry)
    return nil if entry == nil

    if entry[:primarygroupid] == nil then
      ad_result = get_primary_gidnumber_from_ad(entry[:uid].first)
      return ad_result
    end

    return entry[:primarygroupid].first
  end

  def get_primary_gidnumber_from_ad(uid)
    return nil if uid ==nil
    primary_gid = nil

    @ad_client.search(:base => "CN=#{uid},CN=Users,#{@ad_basedn}") do |entry|
      primary_gid = entry[:gidnumber].first
    end

    primary_gid
  end

end

