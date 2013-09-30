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

  file { "/root/preseed/slapd.preseed.temp":
    content => template('ldap/preseed.erb'),
    mode    => 600,
    backup  => false,
    require => File['/root/preseed'],
  }

  # Generate root password
  alkivi_base::passwd { 'admin':
    type   => 'ldap',
    before => Exec['/root/preseed/slapd.preseed'],
  }

  exec { "/root/preseed/slapd.preseed":
    command  => "PASSWORD=`cat /root/.passwd/ldap/admin` && sed 's/CHANGEME/'\$PASSWORD'/g' /root/preseed/slapd.preseed.temp > /root/preseed/slapd.preseed && touch /root/preseed/slapd.preseed.ok",
    provider => 'shell',
    creates  => "/root/preseed/slapd.preseed.ok",
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
    require  => File['/root/preseed/slapd.preseed.temp'],
  }

  package { $ldap::params::ldap_package_name:
    ensure       => installed,
    responsefile => "/root/preseed/slapd.preseed",
    require  => Exec["/root/preseed/slapd.preseed"],
  }
}
