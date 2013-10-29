class ldap::samba(
  $motd = true,
) {

  if($motd)
  {
    motd::register{'LDAP samba support': }
  }

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
  }

  Package {
    ensure => installed,
  }

  package { 'samba-doc': }

  exec { 'copy-samba-scheme':
    command => '/bin/zcat /usr/share/doc/samba-doc/examples/LDAP/samba.schema.gz > /etc/ldap/schema/samba.schema',
    creates => '/etc/ldap/schema/samba.schema',
    require => [ Package['samba-doc', 'slapd'] ],
  }

  file { '/etc/ldap/samba-conf':
    ensure => directory,
    mode   => '0750',
  }

  file { '/etc/ldap/samba-conf/samba.conf':
    source  => 'puppet:///modules/ldap/samba.conf',
    require => File['/etc/ldap/samba-conf'],
  }

  file { '/etc/ldap/samba-conf/slapd.d':
    ensure => directory,
    require => File['/etc/ldap/samba-conf'],
  }

  exec { 'generate-samba-scheme':
    command => '/usr/sbin/slaptest -f /etc/ldap/samba-conf/samba.conf -F /etc/ldap/samba-conf/slapd.d',
    creates => '/etc/ldap/samba-conf/slapd.d/cn=config',
    require => [ Package['samba-doc', 'slapd'], File['/etc/ldap/samba-conf/slapd.d', '/etc/ldap/samba-conf/samba.conf'] ],
  }

  exec { 'apply-samba-scheme':
    command => '/bin/cp /etc/ldap/samba-conf/slapd.d/cn=config/cn=schema/cn={4}samba.ldif /etc/ldap/slapd.d/cn=config/cn=schema/ && chown openldap: /etc/ldap/slapd.d/cn=config/cn=schema/cn={4}samba.ldif && /etc/init.d/slapd restart',
    creates => '/etc/ldap/slapd.d/cn=config/cn=schema/cn={4}samba.ldif',
    notify  => Service['slapd'],
    require => Exec['generate-samba-scheme'],
  }

  # Now add indexes specific to samba
  file { '/etc/ldap/alkivi-conf/olcDbSambaIndex.ldif':
    source  => 'puppet:///modules/ldap/olcDbSambaIndex.ldif',
    require => File['/etc/ldap/alkivi-conf'],
  }

  exec { '/etc/ldap/alkivi-conf/olcDbSambaIndex.ldif':
    command  => "/root/alkivi-scripts/ldap-helper --command modify --method ldapi --file /etc/ldap/alkivi-conf/olcDbSambaIndex.ldif && touch /etc/ldap/alkivi-conf/olcDbSambaIndex.ldif.ok",
    provider => 'shell',
    creates  => "/etc/ldap/alkivi-conf/olcDbSambaIndex.ldif.ok",
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
    require  => [ File['/root/alkivi-scripts/ldap-helper', '/etc/ldap/alkivi-conf/olcDbSambaIndex.ldif'], Exec['/etc/ldap/alkivi-conf/olcDbIndex.ldif', 'apply-samba-scheme'], ],
  }

}
