class ldap::nss(
  $base         = 'dc=alkivi,dc=fr',
  $uri          = 'ldap://127.0.0.1',
  $ldap_version = 3,
  $pam_password = 'crypt',
  $base_passwd  = 'ou=people',
  $base_shadow  = 'ou=people',
  $base_group   = 'ou=groups',
) {

  $package_name    = 'libnss-ldap'
  $rootbinddn      = "cn=admin,${base}"
  $nss_base_passwd = "${base_passwd},${base}?sub"
  $nss_base_shadow = "${base_shadow},${base}?sub"
  $nss_base_group  = "${base_group},${base}?sub"

  if(is_array($uri)) 
  {
    $real_uri = join($uri, ' ')
  }
  else
  {
    $real_uri = $uri
  }

  File {
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$package_name]
  }

  package { $package_name:
    ensure => installed,
  }


  file { '/etc/libnss-ldap.conf':
    content => template('ldap/libnss-ldap.conf.erb')
  }

  file { '/etc/libnss-ldap.secret':
    content => alkivi_password('admin', 'ldap'),
    mode    => '0600',
  }

  exec { 'update-nsswitch':
    command  => 'sed -i "s/passwd:\(.*\)/passwd:\1 ldap/" /etc/nsswitch.conf && sed -i "s/group:\(.*\)/group:\1 ldap/" /etc/nsswitch.conf && sed -i "s/shadow:\(.*\)/shadow:\1 ldap/" /etc/nsswitch.conf',
    provider => 'shell',
    path     => ['/bin', '/sbin', '/usr/bin'],
    require  => Package[$package_name],
    unless   => 'grep -q ldap /etc/nsswitch.conf',
  }




}

