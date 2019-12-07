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

    @ad_host        = params[:ad_host]
    @ad_port        = (params[:ad_port] ? params[:ad_port] : '389')
    @ad_binddn      = params[:ad_binddn]
    @ad_basedn      = params[:ad_basedn]
    @ad_auth        = (params.has_key?(:ad_password) ? { :method => :simple, :username => @ad_binddn, :password => params[:ad_password] } : nil)
    @ldap_host      = params[:ldap_host]
    @ldap_binddn    = params[:ldap_binddn]
    @ldap_basedn    = params[:basedn]
    @ldap_auth      = (params.has_key?(:ldap_password) ? { :method => :simple, :username => @ldap_binddn, :password => params[:ldap_password] } : nil )

    @ad_conn = Net::LDAP.new(
      :host => @ad_host,
      :port => @ad_port,
      :auth => @ad_auth
    )
    #raise "Failed to connect AD at ldap://#{@ad_host}:#{@ad_port} with bindDn #{@ad_binddn}" if !ad.bind

    @ldap_conn = Net::LDAP.new(
      :host => @ldap_host,
      :port => @ldap_port,
      :auth => @ldap_auth
    )
    #raise "Failed to connect Ldap at ldap://#{@ldap_host}:#{@ldap_port} with bindDn #{@ldap_binddn}" if !ldap.bind
  end

  def sync_user(cn)

    filter = Net::LDAP::Filter.eq("cn",cn)
    target = nil

    @ad_conn.search( :base => "CN=Users," + @ad_basedn, :filter => filter ) do |entry|
      puts "DN: #{entry.dn}"
    end

    p @ad_conn.get_operation_result
  end

  def display
    "Hello world"
  end
end

