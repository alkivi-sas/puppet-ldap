class ldap::pam(
  $base         = 'dc=alkivi,dc=fr',
  $uri          = 'ldap://127.0.0.1',
  $ldap_version = 3,
  $pam_password = 'crypt',
  $base_passwd  = 'ou=people',
  $base_shadow  = 'ou=people',
  $base_group   = 'ou=groups',
) {

  $package_name    = 'libpam-ldap'
  $rootbinddn      = "cn=admin,${base}"
  $nss_base_passwd = "${base_passwd},${base}?one"
  $nss_base_shadow = "${base_shadow},${base}?one"
  $nss_base_group  = "${base_group},${base}?one"

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

  exec { 'pam_ldap.secret':
    command  => '/bin/cp /root/.passwd/ldap/admin /etc/pam_ldap.secret && chmod 600 /etc/pam_ldap.secret',
    creates  => '/etc/pam_ldap.secret',
    provider => 'shell',
    path     => ['/bin', '/sbin', '/usr/bin'],
    require  => Package[$package_name],
  }



}

