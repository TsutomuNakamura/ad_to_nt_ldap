# For testing
after the container up, you can test connectivity by executing command like below.

```
ldapsearch -x -LLL -o 'ldif-wrap=no' -h ad -w "p@ssword0" \
        -D "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com" \
        -b "CN=Users,DC=mysite,DC=example,DC=com" \
        '(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)'
```

```
samba-tool user getpassword taro-suzuki --attribute virtualCryptSHA512 -H ldap://ad:389 --username Administrator --password p@ssword0
```

