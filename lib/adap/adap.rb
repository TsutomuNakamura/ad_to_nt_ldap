require 'net-ldap'

class Adap

  # :unixhomedirectory and :homedirectory are the attributes that has same meaning between AD and LDAP.
  USER_REQUIRED_ATTRIBUTES = [:cn, :sn, :uid, :uidnumber, :gidnumber, :displayname, :loginshell, :gecos, :givenname, :unixhomedirectory, :homedirectory]
  #USER_REQUIRED_ATTRIBUTES = ['cn', 'sn', 'uid', 'uidNumber', 'gidNumber', 'homeDirectory', 'loginShell', 'gecos', 'givenName']
  GROUP_OF_USER_REQUIRED_ATTRIBUTES = [:objectclass, :gidnumber, :cn, :description, :memberuid]

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
  #   :password_hash_algorithm (default:virtualCryptSHA512)     Password hash algorithm. It must be same between AD and LDAP, and only support virtualCryptSHA512 or virtualCryptSHA256 now.
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
    Net::LDAP.new(:host => ad_host, :port => ad_port, :auth => ad_auth)
  end

  def self.get_ldap_client_instance(ldap_host, ldap_port, ldap_auth)
    Net::LDAP.new(:host => ldap_host, :port => ldap_port, :auth => ldap_auth)
  end

  def get_ad_dn(username)
    "CN=#{username},CN=Users,#{@ad_basedn}"
  end

  def get_ldap_dn(username)
    "uid=#{username},ou=Users,#{@ldap_basedn}"
  end

  def create_ldap_attributes(entry)
    attributes = {
      :objectclass => ["top", "person", "organizationalPerson", "inetOrgPerson", "posixAccount", "shadowAccount"]
    }

   entry.each do |attribute, values|
      # Change string to lower case symbols to compare each attributes correctly
      attribute = attribute.downcase.to_sym

      if USER_REQUIRED_ATTRIBUTES.include?(attribute) then
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
    `samba-tool user getpassword #{username} --attribute #{algo} 2> /dev/null | grep -E '^virtualCrypt' -A 1 | tr -d ' \n' | cut -d ':' -f 2`
  end

  def sync_user(uid)
    ad_entry    = nil
    ldap_entry  = nil
    ad_dn       = get_ad_dn(uid)
    ldap_dn     = get_ldap_dn(uid)

    # dn: CN=user-name,CN=Users,DC=mysite,DC=example,DC=com
    @ad_client.search(:base => ad_dn) do |entry|
      ad_entry = entry
    end
    ret_code = @ad_client.get_operation_result.code

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
      ret = add_user(ldap_dn, ad_entry, get_password(uid))
    elsif ad_entry.nil? and !ldap_entry.nil? then
      ret = delete_user(ldap_dn)
    elsif !ad_entry.nil? and !ldap_entry.nil? then
      ret = modify_user(ldap_dn, ad_entry, ldap_entry, get_password(uid))
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
      :message => "Failed to modify a user #{ldap_user_dn} in add_user() - " + @ldap_client.get_operation_result.error_message
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
      ldap_key      = (key != "unixHomeDirectory" ? key : "homeDirectory")
      ldap_key_sym  = ldap_key.downcase.to_sym

      if USER_REQUIRED_ATTRIBUTES.include?(ad_key_sym)
        next if value == ldap_entry[ldap_key]
        operations.push((ldap_entry[ldap_key] != nil ? [:replace, ldap_key_sym, value] : [:add, ldap_key_sym, value]))
      end
    end

    ldap_entry.each do |key, value|
      ldap_key_sym  = key.downcase.to_sym
      ad_key        = (key != "homeDirectory" ? key : "unixHomeDirectory")

      if USER_REQUIRED_ATTRIBUTES.include?(ldap_key_sym)
        operations.push([:delete, ldap_key_sym, nil]) if ad_entry[ad_key] == nil
      end
    end

    # AD does not have password as simple ldap attribute.
    # So password will always be updated for this reason.
    operations.push([:replace, :userpassword, password])

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
        :operations => entry
      })
      ret_code = @ldap_client.get_operation_result.code

      return {
        :code => ret_code,
        :operations => [:modify_group_of_user],
        :message => "Failed to modify group \"#{entry_key}\" of user #{entry[:cn]}. " + @ldap_client.get_operation_result.error_message
      } if ret_code != 0

      if entry[:operations].first.first == :delete then
        ret = delete_group_if_existed_as_empty(entry_key, entry)
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

    @ad_client.search(:base => "CN=#{uid},CN=Users,#{@ad_basedn}") do |entry|
      primary_gid = entry[:gidnumber].first
    end

    return primary_gid
  end

end

