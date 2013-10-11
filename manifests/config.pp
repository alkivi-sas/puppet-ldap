class ldap::config () {

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service[$ldap::params::ldap_service_name],
  }

  file { '/etc/iptables.d/22-ldap.rules':
    content => template('ldap/iptable.conf.erb'),
    notify  => Service['alkivi-iptables'],
    require => Package['alkivi-iptables'],
  }

  file { '/etc/ldap/ldap.conf':
    content => template('ldap/ldap.conf.erb'),
  }

  if($ldap::ssl)
  {
    # Generate certificate
    file { $ldap::ssldir:
      ensure => directory,
      mode   => '0755',
    }

    openssl::certificate::x509 { $ldap::sslcert:
      country      => 'FR',
      state        => 'Nord',
      locality     => 'Lille',
      organization => $ldap::organization,
      unit         => 'Alkivi Customer',
      commonname   => $ldap::commonname,
      days         => 3456,
      base_dir     => $ldap::ssldir,
      owner        => 'openldap',
      email        => 'admin@alkivi.fr',
      require      => File[$ldap::ssldir],
    }

    # Touch ldiff file that will do the magic
    file { '/etc/ldap/alkivi-conf/olcSsl.ldif':
      content => template('ldap/olcSsl.ldif.erb'),
      require => File['/etc/ldap/alkivi-conf'],
    }

    # add before   => Exec['/etc/ldap/alkivi-conf/olcGroups.ldif'], ?
    exec { '/etc/ldap/alkivi-conf/olcSsl.ldif':
      command  => '/root/alkivi-scripts/ldap-helper --command modify --method ldapi --file /etc/ldap/alkivi-conf/olcSsl.ldif && touch /etc/ldap/alkivi-conf/olcSsl.ldif.ok',
      provider => 'shell',
      creates  => '/etc/ldap/alkivi-conf/olcSsl.ldif.ok',
      path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
      require  => File['/root/alkivi-scripts/ldap-helper', '/etc/ldap/alkivi-conf/olcSsl.ldif'],
    }

    $default_source = 'puppet:///modules/ldap/slapd.default.ssl'
  }
  else
  {
    $default_source = 'puppet:///modules/ldap/slapd.default'
  }

  file { '/etc/default/slapd':
    source => $default_source,
  }

  # now perform basic stuff
  file { '/etc/ldap/alkivi-conf':
    ensure => directory,
    mode   => '0750',
  }

  file { '/etc/ldap/alkivi-conf/olcDbIndex.ldif':
    source  => 'puppet:///modules/ldap/olcDbIndex.ldif',
    require => File['/etc/ldap/alkivi-conf'],
  }

  exec { '/etc/ldap/alkivi-conf/olcDbIndex.ldif':
    command  => '/root/alkivi-scripts/ldap-helper --command modify --method ldapi --file /etc/ldap/alkivi-conf/olcDbIndex.ldif && touch /etc/ldap/alkivi-conf/olcDbIndex.ldif.ok',
    provider => 'shell',
    creates  => '/etc/ldap/alkivi-conf/olcDbIndex.ldif.ok',
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
    require  => File['/root/alkivi-scripts/ldap-helper', '/etc/ldap/alkivi-conf/olcDbIndex.ldif'],
  }

  file { '/etc/ldap/alkivi-conf/olcAccess.ldif':
    content => template('ldap/olcAccess.ldif.erb'),
    require => File['/etc/ldap/alkivi-conf'],
  }

  exec { '/etc/ldap/alkivi-conf/olcAccess.ldif':
    command  => '/root/alkivi-scripts/ldap-helper --command modify --method ldapi --file /etc/ldap/alkivi-conf/olcAccess.ldif && touch /etc/ldap/alkivi-conf/olcAccess.ldif.ok',
    provider => 'shell',
    creates  => '/etc/ldap/alkivi-conf/olcAccess.ldif.ok',
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
    require  => File['/root/alkivi-scripts/ldap-helper', '/etc/ldap/alkivi-conf/olcAccess.ldif'],
  }

  file { '/root/alkivi-scripts/ldap-helper':
    source  => 'puppet:///modules/ldap/ldap-helper',
    mode    => '0700',
    require => File['/root/alkivi-scripts/'],
  }

  file { '/usr/bin/ldap-helper':
    ensure  => link,
    target  => '/root/alkivi-scripts/ldap-helper',
    require => File['/root/alkivi-scripts/ldap-helper'],
  }

  file { '/root/alkivi-scripts/ldap-add-user':
    source  => 'puppet:///modules/ldap/ldap-add-user',
    mode    => '0700',
    require => File['/root/alkivi-scripts/'],
  }

  file { '/usr/bin/ldap-add-user':
    ensure  => link,
    target  => '/root/alkivi-scripts/ldap-add-user',
    require => File['/root/alkivi-scripts/ldap-add-user'],
  }

  file { '/root/alkivi-scripts/ldap-add-sambaUser':
    source  => 'puppet:///modules/ldap/ldap-add-sambaUser',
    mode    => '0700',
    require => File['/root/alkivi-scripts/'],
  }

  file { '/usr/bin/ldap-add-sambaUser':
    ensure  => link,
    target  => '/root/alkivi-scripts/ldap-add-sambaUser',
    require => File['/root/alkivi-scripts/ldap-add-sambaUser'],
  }


  # TODO : sync special stuff ...
  if($ldap::master)
  {
    file { '/etc/ldap/alkivi-conf/synchronisator.ldif':
      content => template('ldap/synchronisator.ldif.erb'),
      require => File['/etc/ldap/alkivi-conf'],
    }

    file { '/etc/ldap/alkivi-conf/provider.ldif':
      content => template('ldap/provider.ldif.erb'),
      require => File['/etc/ldap/alkivi-conf'],
    }

    file { '/var/lib/ldap/accesslog':
      ensure => directory,
      owner  => 'openldap',
      group  => 'openldap',
    }

    exec { 'copy_DB_CONFIG':
      command  => 'cp /var/lib/ldap/DB_CONFIG /var/lib/ldap/accesslog',
      provider => 'shell',
      path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
      creates  => '/var/lib/ldap/accesslog/DB_CONFIG',
    }
  }

  if($ldap::slave)
  {
    validate_string($ldap::masterNode)

    file { '/etc/ldap/alkivi-conf/consumer.ldif':
      content => template('ldap/consumer.ldif.erb'),
      require => File['/etc/ldap/alkivi-conf'],
    }
  }

  if defined(Class['rsyslog'])
  {
    concat::fragment{'rsyslog.ldap':
      target  => $rsyslog::params::rsyslog_config_name,
      content => "# LDAP\nlocal4.*                        /var/log/ldap.log\n",
      order   => 02,
    }
  }

    
}
