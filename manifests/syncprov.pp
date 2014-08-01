class ldap::syncprov(
) {

  if(!defined(Class['ldap']))
  {
    fail('Ldap class must be present')
  }

  $backend = downcase($ldap::backend)

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
  }

  Package {
    ensure => installed,
  }

  # Now add indexes specific to samba
  file { '/etc/ldap/alkivi-conf/olcSyncprov.ldif':
    source  => 'puppet:///modules/ldap/olcSyncprov.ldif',
    require => File['/etc/ldap/alkivi-conf'],
  }

  exec { '/etc/ldap/alkivi-conf/olcSyncprov.ldif':
    command  => "/root/alkivi-scripts/ldap-helper --command add --method ldapi --file /etc/ldap/alkivi-conf/olcSyncprov.ldif && touch /etc/ldap/alkivi-conf/olcSyncprov.ldif.ok",
    provider => 'shell',
    creates  => "/etc/ldap/alkivi-conf/olcSyncprov.ldif.ok",
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
    require  => [ File['/root/alkivi-scripts/ldap-helper', '/etc/ldap/alkivi-conf/olcSyncprov.ldif'], Exec['/etc/ldap/alkivi-conf/olcDbIndex.ldif' ] ],
  }
}
