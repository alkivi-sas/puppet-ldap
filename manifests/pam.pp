class ldap::pam(
  $base         = 'dc=alkivi,dc=fr',
  $uri          = 'ldap://127.0.0.1',
  $ldap_version = 3,
  $pam_password = 'exop',
  $base_passwd  = 'ou=people',
  $base_shadow  = 'ou=people',
  $base_group   = 'ou=groups',
) {

  $package_name    = 'libpam-ldap'
  $rootbinddn      = "cn=admin,${base}"
  $nss_base_passwd = "${base_passwd},${base}?one"
  $nss_base_shadow = "${base_shadow},${base}?one"
  $nss_base_group  = "${base_group},${base}?one"

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


  file { '/etc/pam_ldap.conf':
    content => template('ldap/pam_ldap.conf.erb')
  }

  file { '/etc/pam_ldap.secret':
    content => alkivi_password('admin', 'ldap'),
    mode    => '0600',
  }
}

