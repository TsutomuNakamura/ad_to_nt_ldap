# Adap
Adap is a program that synchronize user data on Samba Active Directory (AD) to LDAP.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'adap'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install adap

## Usage

To build this modules, run the command like below.

```
gem build adap.gemspec
```

Then include this module and use it like below.

```ruby
require "adap"

adap = Adap.new({
  :ad_host   => "localhost",                                                # Host name or IP of your Active Directory(AD)
  :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",    # Bind dn of your AD
  :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",                     # Base dn of your AD
  :ad_password => "ad_secret",                                              # Password of your AD's bind dn
  :ldap_host   => "ldap_server",                                            # Host name or IP of your LDAP
  :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com", # Bind dn of your LDAP
  :ldap_basedn => "dc=mysite,dc=example,dc=com",                            # Base dn of your LDAP
  :ldap_password => "ldap_secret"                                           # Password of your LDAP's bind dn
})

# This operation will synchronize a user taro-suzuki to LDAP from AD
adap.sync_user("taro-suzuki")
```

## Requirements and limitations

This program has some requirements and limitations like below.

### Attributes to synchronized

Data synchronized to LDAP from AD are limited such as dn, cn uid and uidNumber etc.
These attributes are enough to authenticate users to login to Unix-like systems that used an LDAP for authenticating users.

### AD must allow 

AD must allow setting `ldap server require strong auth = no` for getting user data.

* smb.conf of your AD
```
ldap server require strong auth = no
```

This program will fail to get user data from AD if you did not allow this setting.

### AD must allow storing password as CryptSHA256 or CryptSHA512 and it's have to same as storing method in LDAP

AD must allow storing password as CryptSHA256 or CryptSHA512 by setting smb.conf like below.

* your AD's smb.conf
```
    password hash userPassword schemes = CryptSHA256 CryptSHA512
```

And LDAP have to be configured to store password as sha256 or sha512.

For example, you use OpneLDAP, you have to set configuration like below when you store password as sha256.

```
$ ldapmodify -Y EXTERNAL -H ldapi:/// << 'EOF'
dn: cn=config
add: olcPasswordHash
olcPasswordHash: {CRYPT}
-
add: olcPasswordCryptSaltFormat
olcPasswordCryptSaltFormat: $5$%.16s
EOF
```

This instruction allows us to save password as sha256 with a salt that length is 16 characters.
Or you can store user's password as sha512 with a salt that length is 16 characters like below.

```
$ ldapmodify -Y EXTERNAL -H ldapi:/// << 'EOF'
dn: cn=config
add: olcPasswordHash
olcPasswordHash: {CRYPT}
-
add: olcPasswordCryptSaltFormat
olcPasswordCryptSaltFormat: $6$%.16s
EOF
```

As I said, this algorithm must be same as an AD's one to synchronize user information.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TsutomuNakamura/adap.
