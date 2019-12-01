class AdNtLdap
  def initialize()
    puts "no arguments"
  end

  def initialize(params)
    raise "Initialize AdNtLdap was failed. params must not be nil" if params == nil
    #raise 'AdNtLdap requires keys of parameter "ad_host" "ad_binddn" "ad_basedn"' \
    [:ad_host, :ad_binddn, :ad_basedn].each { |k|
      raise 'AdNtLdap requires keys in params "ad_host", "ad_binddn", "ad_basedn"' if !params.key?(k)
    }

    #@nt_host (params['nt_host'])
    #@nt_port
  end

  def display
    "Hello world"
  end
end

