# LDAP Module

This module will install and configure a LDAP server.
Samba utilisation is possible using special parameters

## Usage

### Minimal server configuration

```puppet
class { ldap: 
  organization => 'Alkivi SAS',
  commonname   => 'alkivi',
  domain_name  => 'alkivi.fr',
  master       => true,
  samba        => false,
}
```
This will do the typical install, configure and service management.



### More server configuration

```puppet
class { ldap: 
  uri          => 'ldap2.alkivi.fr',
  base         => 'dc=alkivi,dc=fr',
  organization => 'Alkivi SAS',
  commonname   => 'alkivi',
  domain_name  => 'alkivi.fr',
  slave        => true,
  masterNode   => 'ldap.alkivi.fr',
  samba        => false,
}


```


### Host configuration

TODO

## Limitations

* This module has been tested on Debian Wheezy, Squeeze.

## License

All the code is freely distributable under the terms of the LGPLv3 license.

## Contact

Need help ? contact@alkivi.fr

## Support

Please log tickets and issues at our [Github](https://github.com/alkivi-sas/)
