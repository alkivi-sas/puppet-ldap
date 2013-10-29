# LDAP Module

This module will install and configure a LDAP server.
Samba utilisation is possible using special parameters

## Usage

### Minimal server configuration

```puppet
class { ldap: 
  uri          => 'ldap.alkivi.fr',
  base         => 'dc=alkivi,dc=fr',
  organization => 'Alkivi SAS',
  commonname   => 'alkivi',
  domain_name  => 'alkivi.fr',
  ssl          => true,
}
```
This will do the typical install, configure and service management.



### More server configuration

```puppet
class { ldap: 
  organization => 'Alkivi SAS',
  commonname   => 'alkivi',
  domain_name  => 'alkivi.fr',
  uri          => 'ldap.alkivi.fr',
  base         => 'dc=alkivi,dc=fr',
  ssl          => true,
  ssldir       => '/etc/ssl/ldap',
  sslcert      => 'alkivi-ldap',
  backend      => 'HDB',
  motd         => true,
  firewall     => true,
}
```

### Samba support

```puppet
class { 'ldap::samba': }
class { 'ldap::smbldap':
  sid         => 'S-1-5-21-4095410810-3205272473-3842645657',
  sambaDomain => 'home',
  readbinddn  => 'cn=admin,dc=home',
  writebinddn => 'cn=admin,dc=home',
  mailDomain  => 'alkivi.fr',
  suffix      => 'dc=home',
  usersdn     => 'people',
  computersdn => 'computers',
  groupsdn    => 'groups',
  idmapdn     => 'idmap',
}
```

This will install smbldap tools and create default configuration, and populate your ldap directory with what is needed for domain control


### PAM and NSS support
```puppet
class { 'ldap::pam':
  base        => 'dc=home',
  base_passwd => 'ou=people',
  base_shadow => 'ou=people',
  base_group  => 'ou=groups',
}

class { 'ldap::nss':
  base        => 'dc=home',
  base_passwd => 'ou=people',
  base_shadow => 'ou=people',
  base_group  => 'ou=groups',
}
```

### Host configuration

You have two type of host, basic one, or samba one according to which classes you want to include. Samba user is added with smbldap-tools while basic user is not.

```puppet
ldap::sambauser{ 'toto':
 email        => 'toto@alkivi.fr',
 uname        => 'toto',
 firstName    => 'Toto',
 lastName     => 'Awesome',
 create_local => false,
}

ldap::user{ 'toto':
 email        => 'toto@alkivi.fr',
 uname        => 'toto',
 firstName    => 'Toto',
 lastName     => 'Awesome',
 create_local => false,
}

## Limitations

* This module has been tested on Debian Wheezy, Squeeze.

## License

All the code is freely distributable under the terms of the LGPLv3 license.

## Contact

Need help ? contact@alkivi.fr

## Support

Please log tickets and issues at our [Github](https://github.com/alkivi-sas/)
