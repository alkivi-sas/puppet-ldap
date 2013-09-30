class ldap::smbldap(
  $sid                        = '',
  $sambaDomain                = 'ALKIVI',
  $slaveLDAP                  = '127.0.0.1',
  $slavePort                  = 389,
  $masterLDAP                 = '127.0.0.1',
  $masterPort                 = 389,
  $ldapTLS                    = 0,
  $ldapSSL                    = 0,
  $verify                     = 'none',
  $cafile                     = '/etc/smbldap-tools/ca.pem',
  $clientcert                 = '/etc/smbldap-tools/smbldap-tools.example.com.pem',
  $clientkey                  = '/etc/smbldap-tools/smbldap-tools.example.com.key',
  $suffix                     = 'dc=home',
  $usersdn                    = 'people',
  $computersdn                = 'computers',
  $groupsdn                   = 'groups',
  $idmapdn                    = 'idmap',
  $scope                      = 'sub',
  $password_hash              = 'SHA',
  $password_crypt_salt_format = '%s',
  $userLoginShell             = '/bin/false',
  $userHome                   = '/home/users/%U',
  $userHomeDirectoryMode      = '700',
  $userGecos                  = 'System User',
  $defaultUserGid             = '513',
  $defaultComputerGid         = '515',
  $skeletonDir                = '/etc/skel',
  $shadowAccount              = '1',
  $defaultMaxPasswordAge      = undef,
  $userSmbHome                = '',
  $userProfile                = '',
  $userHomeDrive              = 'Z:',
  $userScript                 = 'logon.bat',
  $mailDomain                 = 'alkivi.fr',
  $with_smbpasswd             = '0',
  $smbpasswd                  = '/usr/bin/smbpasswd',
  $with_slappasswd            = '0',
  $slappasswd                 = '/usr/sbin/slappasswd',
  $no_banner                  = False,

  $readbinddn  = 'cn=admin,dc=home',
  $writebinddn = 'cn=admin,dc=home',

) {

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
  }

  Package {
    ensure => installed,
  }

  $package_name = 'smbldap-tools'

  package { $package_name:
    ensure => installed,
  }

  file { '/usr/sbin/smbldap-useradd':
    source  => 'puppet:///modules/ldap/smbldap-useradd',
    mode    => '0755',
    require => Package['smbldap-tools'],
  }


  file { '/etc/smbldap-tools/smbldap.conf':
    content => template('ldap/smbldap.conf.erb')
  }

  file { '/etc/smbldap-tools/smbldap_bind.conf.temp':
    content => template('ldap/smbldap_bind.conf.erb'),
    mode    => '0600',
  }

  exec { 'populate-ldap':
    command => 'PASSWORD=`cat /root/.passwd/root` && /usr/sbin/smbldap-populate -u 1001 2>/dev/null <<EOF
$PASSWORD
$PASSWORD
EOF',
    provider => 'shell',
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
    require  => File['/etc/smbldap-tools/smbldap.conf', '/etc/smbldap-tools/smbldap_bind.conf.temp', '/usr/bin/ldap-helper', '/usr/sbin/smbldap-useradd' ],
    unless   => "ldap-helper --command search --method ldapi --args '-b ${suffix}' | grep -q 'dn: sambaDomainName='",
  }

}

