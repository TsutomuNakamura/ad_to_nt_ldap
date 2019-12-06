class Adap
  def initialize()
    puts "no arguments"
  end

  #
  # params {
  #   :ad_host     required                                   IP or hostname of AD.
  #   :ad_port     optional (default:389)                     Port of AD host.
  #   :ad_binddn   required                                   Binddn of AD.
  #   :ad_basedn   required                                   Basedn of AD users.
  #   :ad_password optional (default:(empty))                 Password of AD with :ad_binddn.
  #   :nt_host     required                                   IP or hostname of NT.
  #   :nt_port     optional (default:389)                     Port of NT host.
  #   :nt_binddn   required                                   Binddn of NT.
  #   :nt_basedn   required                                   Basedn of NT users.
  #   :nt_password optional (default:(same as :ad_password))  Password of NT with :nt_binddn
  # }
  #
  def initialize(params)
    raise "Initialize Adap was failed. params must not be nil" if params == nil
    #raise 'Adap requires keys of parameter "ad_host" "ad_binddn" "ad_basedn"' \
    [:ad_host, :ad_binddn, :ad_basedn, :nt_host, :nt_binddn, :nt_basedn].each { |k|
      raise 'Adap requires keys in params ":ad_host", ":ad_binddn", ":ad_basedn", ":nt_host", ":nt_binddn", ":nt_basedn"' if !params.key?(k)
    }

    #@nt_host (params['nt_host'])
    #@nt_port
  end

  def sync

  def display
    "Hello world"
  end
end

