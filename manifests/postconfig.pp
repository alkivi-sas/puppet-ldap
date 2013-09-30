class ldap::postconfig () {

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  # Dont create user now, it will be done using samba
  #file { '/etc/ldap/alkivi-conf/olcGroups.ldif':
  #  content => template('ldap/olcGroups.ldif.erb'),
  #  require => File['/etc/ldap/alkivi-conf'],
  #}

  #exec { '/etc/ldap/alkivi-conf/olcGroups.ldif':
  #  command  => "/root/alkivi-scripts/ldap-helper --command add --method auth --file /etc/ldap/alkivi-conf/olcGroups.ldif && touch /etc/ldap/alkivi-conf/olcGroups.ldif.ok",
  #  provider => 'shell',
  #  creates  => "/etc/ldap/alkivi-conf/olcGroups.ldif.ok",
  #  path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
  #}
}
