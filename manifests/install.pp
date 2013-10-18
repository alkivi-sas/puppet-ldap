class ldap::install () {
  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
  }

  if ! defined(File['/root/preseed/'])
  {
    file { '/root/preseed':
      ensure => directory,
      mode   => '0750',
    }
  }

  $password = alkivi_password('admin', 'ldap')

  file { "/root/preseed/slapd.preseed":
    content => template('ldap/preseed.erb'),
    mode    => 600,
    backup  => false,
    require => File['/root/preseed'],
  }

  # Generate root password
  alkivi_base::passwd { 'admin':
    type   => 'ldap',
  }

  package { $ldap::params::ldap_package_name:
    ensure       => installed,
    responsefile => "/root/preseed/slapd.preseed",
    require      => File["/root/preseed/slapd.preseed"],
  }
}
