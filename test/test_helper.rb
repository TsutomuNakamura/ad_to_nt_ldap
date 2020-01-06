$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "adap"

require "minitest/autorun"
require 'mocha/minitest'

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

