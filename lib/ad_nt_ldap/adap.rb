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

    @ad_host        = params['ad_host']
    @ad_port        = (params['ad_port'] ? params['ad_port'] : '389')
    @ad_binddn      = params['ad_binddn']
    @ad_basedn      = params['ad_basedn']
    @ad_password    = (params['ad_password'] ? params['ad_password'] : nil)
    @ldap_host      = params['ldap_host']
    @ldap_binddn    = params['ldap_binddn']
    @ldap_basedn    = params['basedn']
    @ldap_password  = (params['ldap_password'] ? params['ldap_password'] : nil)

    #@nt_host (params['nt_host'])
    #@nt_port
  end

  def sync

  def display
    "Hello world"
  end
end

