$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "adap"

require "minitest/autorun"
require 'mocha/minitest'

# TODO: Using `objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com` is more accurate than `objectClass=group`.
#DUMMY_LDAP_FILTER_OF_FOO_WITHOUT_GIDNUMBER = "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com))"
DUMMY_LDAP_FILTER_OF_FOO_WITHOUT_GIDNUMBER = "(&(objectClass=group)(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com))"
# TODO: Using `objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com` is more accurate than `objectClass=group`.
#DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513 = "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"
DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513 = "(&(objectClass=group)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"

AD_BASE         = "DC=mysite,DC=example,DC=com"
AD_USER_BASE    = "CN=Users,#{AD_BASE}"
AD_GROUP_BASE    = "CN=Users,#{AD_BASE}"

LDAP_BASE = "dc=mysite,dc=example,dc=com"
LDAP_USER_BASE = "ou=Users,#{LDAP_BASE}"
LDAP_GROUP_BASE = "ou=Groups,#{LDAP_BASE}"

def mock_ad_and_ldap_connections
  ad_client                    = mock()
  ldap_client                  = mock()

  Adap.expects(:get_ad_client_instance)
    .with("localhost", 389, { :method => :simple, :username => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com", :password => "ad_secret" })
    .returns(ad_client)

  Adap.expects(:get_ldap_client_instance)
    .with("ldap_server", 389, { :method => :simple, :username => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com", :password => "ldap_secret" })
    .returns(ldap_client)

  return {:ad_client => ad_client, :ldap_client => ldap_client}
end

def merge_hash(a, b)
  a.merge(b) {|key, oldval, newval|
    if oldval.class == Hash && newval.class == Hash
      newval = merge_hash(oldval, newval)
    end
    newval
  }
end

def get_general_adap_instance(ex_options = nil)
  options = {
    :ad_host            => "localhost",
    :ad_bind_dn         => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
    :ad_user_base_dn    => "CN=Users,DC=mysite,DC=example,DC=com",
    :ad_group_base_dn   => "CN=Users,DC=mysite,DC=example,DC=com",
    :ad_password        => "ad_secret",
    :ldap_host          => "ldap_server",
    :ldap_bind_dn       => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
    :ldap_user_base_dn  => "ou=Users,dc=mysite,dc=example,dc=com",
    :ldap_group_base_dn => "ou=Groups,dc=mysite,dc=example,dc=com",
    :ldap_password      => "ldap_secret"
  }
  if ex_options != nil && ex_options.class == Hash
    options = merge_hash(options, ex_options)
  end

  Adap.new(options)
end

