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
adap.sync_user("john", "secret")
```

## Attributes to be synched by default
Attributes to be synched by default are like below.

| Name of attribute in AD |         | Name of attribute in LDAP | Note |
| ----------------------- | ------- | ------------------------- | ---- |
| cn                      | &#8594; | cn                        |      |
| sn                      | &#8594; | sn                        |      |
| uid                     | &#8594; | uid                       |      |
| uidNumber               | &#8594; | uidNumber                 |      |
| gidNumber               | &#8594; | gidNumber                 |      |
| displayName             | &#8594; | displayName               |      |
| loginShell              | &#8594; | loginShell                |      |
| gecos                   | &#8594; | gecos                     |      |
| givenName               | &#8594; | givenName                 |      |
| description             | &#8594; | description               |      |
| mail                    | &#8594; | mail                      |      |
| employeeNumber          | &#8594; | employeeNumber            |      |
| unixHomeDirectory       | &#8594; | homeDirectory             | Synched by different names of attributes between AD and LDAP |
| -                       | &#8594; | userPassword              | Password of users also will be synched with some limitations |

Some attributes will be added as synched parameters if you add some options, for example options of phonetics.

## Other options
### Password hash algorithm
There are some supported password hash algorithms like `:md5(MD5)`, `:sha(SHA1)`, `:ssha(SSHA)`, `:virtual_crypt_sha256(virtualCryptSHA256)`, `:virtual_crypt_sha512(virtualCryptSHA512)`.
`:ssha(SSHA)` will be chosen if you didn't specify any method.

```ruby
adap = Adap.new({
  # Abbreviate other necessary attributes...
  :password_hash_algorithm => :sha
})
```

But please be careful, even if you choose any method, you will encounter some limitations.

* [You have to give plain password if you choose password hash algorithm as :md5, :sha or :ssha](https://github.com/TsutomuNakamura/adap/#you-have-to-give-plain-password-if-you-choose-password-hash-algorithm-as-md5-sha-or-ssha)
* [AD must allow CryptSHA256 or CryptSHA512 to store password and they have to be same as a storing method in LDAP if you chose password hash algorithm as :virtual_crypt_sha256 or :virtual_crypt_sha512](https://github.com/TsutomuNakamura/adap/#ad-must-allow-cryptsha256-or-cryptsha512-to-store-password-and-they-have-to-be-same-as-a-storing-method-in-ldap)

### Phonetics
adap can sync phonetics from AD to LDAP if you specify attribute names.

```ruby
adap = Adap.new({
  # Abbreviate other necessary attributes...
  :map_msds_phonetics => {
    # This will sync the value of :'msds-phoneticdisplayname'(msDS-PhoneticDisplayName) in AD to the value of "displayname;lang-ja;phonetic" in LDAP
    :'msds-phoneticdisplayname' => :'displayname;lang-ja;phonetic'
  }
})
```

All supported phonetics in AD are like below.

| Symbol                      | Name of attribute        | General name of attribute in LDAP(ex:ja) |
| --------------------------- | ------------------------ | ---------------------------------------- |
| :'msds-phoneticcompanyname' | msDS-PhoneticCompanyName | companyName;lang-ja;phonetic             |
| :'msds-phoneticdepartment'  | msDS-PhoneticDepartment  | department;lang-ja;phonetic              |
| :'msds-phoneticfirstname'   | msDS-PhoneticFirstName   | firstname;lang-ja;phonetic               |
| :'msds-phoneticlastname'    | msDS-PhoneticLastName    | lastname;lang-ja;phonetic                |
| :'msds-phoneticdisplayname' | msDS-PhoneticDisplayName | displayname;lang-ja;phonetic             |

Ofcourse, you can change the name of attributes that will be synced in LDAP(General name of attribute in LDAP) depends on your environment.

## Requirements and limitations

This program has some requirements and limitations like below.

### Not all attributes are synchronized

Data synchronized to LDAP from AD are limited such as dn, cn uid and uidNumber etc.
These attributes are enough to authenticate users to login to Unix-like systems that used an LDAP for authenticating users.

### AD must be set not to require strong auth

AD must allow setting `ldap server require strong auth = no` for getting user data.

* smb.conf of your AD
```
ldap server require strong auth = no
```

This program will fail to get user data from AD if you did not allow this setting.

### You have to give a plain password of the user that will be synched if you choose password hash algorithm as :md5, :sha or :ssha
AD never be able to have passwords as :md5(MD5), :sha(SHA1) or :ssha(SSHA) that same as LDAP(OpenLDAP).
So this program can not sync user password from only parameters in AD to LDAP.
You have to pass the plain password to sync passwords to LDAP.

```ruby
adap = Adap.new({
  # Abbreviate other necessary attributes...
})

adap.sync_user("john", "secret")    # You have to give a plain password as a second parameter of the sync_user().
```

### AD must allow CryptSHA256 or CryptSHA512 to store password and they have to be same as a storing method in LDAP if you choose password hash algorithm as :virtual_crypt_sha256 or :virtual_crypt_sha512

AD must allow storing password as CryptSHA256 or CryptSHA512 by setting smb.conf like below.

* your AD's smb.conf
```
[global]
    # ......
    password hash userPassword schemes = CryptSHA256 CryptSHA512
```

And LDAP have to be configured to store password as sha256(CryptSHA256) or sha512(CryptSHA512).

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

After you have set them, you can sync a user and password between AD and LDAP like below.

```ruby
adap = Adap.new({
  # Abbreviate other necessary attributes...
  :password_hash_algorithm => :virtual_crypt_sha512
})

adap.sync_user("john")    # You don't have to give a plain password.
```

### This program must be located in AD server if you chose a password hash algorithm as :virtual_crypt_sha256 or :virtual_crypt_sha512

This program must be located in AD server because samba-tool on AD only support getting hashed password only from `ldapi://` or `tdb://`.

### This program only supports syncing user data. Syncing group data does not support yet

Syncing group data might be supported and implemented if some people demand it.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TsutomuNakamura/adap.
