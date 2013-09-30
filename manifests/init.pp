class ldap (
  $organization,
  $commonname,
  $domain_name,
  $uri          = 'ldap.alkivi.fr',
  $base         = 'dc=alkivi,dc=fr',
  $ssl          = true,
  $ssldir       = '/etc/ssl/ldap',
  $sslcert      = 'alkivi-ldap',
  $backend      = 'HDB',

  $phpldapadmin = false,      # Install phpldapadmin (where ?)

  $samba        = true,       # Install samba schema files for ldap
  $ou_users     = 'people',
  $ou_groups    = 'groups',
  $ou_computers = 'computers',
  $ou_idmap     = 'idmap',
  $sid          = undef,
  $sambaDomain  = undef,
  $readbinddn   = undef,
  $writebinddn  = undef,
  $mailDomain   = undef,

  $users        = {},         # Will add users in ldap (according to samba ?)

  $master       = false,      # Install stuff related to replication, provider side

  $slave        = false,      # Install stuff related to replicaiton, consumer side
  $masterNode   = '',

  $pam          = false,      # Install libpam_ldap to ease integration with samba
  $nss          = false,      # Install libnss_ldap to ease integration with samba

  $motd = true,

) {

  if($phpldapadmin)
  {
    class { 'phpldapadmin':
      serverName  => $organization,
      base        => $base,
      domain_name => $domain_name,
    }
  }

  if($samba)
  {

    validate_string($ou_users)
    validate_string($ou_groups)
    validate_string($ou_computers)
    validate_string($sid)
    validate_string($sambaDomain)
    validate_string($readbinddn)
    validate_string($writebinddn)
    validate_string($mailDomain)

    class { 'ldap::samba': }
    class { 'ldap::smbldap':
      sid         => $sid,
      sambaDomain => $sambaDomain,
      readbinddn  => $readbinddn,
      writebinddn => $writebinddn,
      mailDomain  => $mailDomain,
      suffix      => $base,
      usersdn     => $ou_users,
      computersdn => $ou_computers,
      groupsdn    => $ou_groups,
      idmapdn     => $ou_idmap,
    }

    if($pam)
    {
      class { 'ldap::pam':
        base        => $base,
        base_passwd => "ou=${ou_users}",
        base_shadow => "ou=${ou_users}",
        base_group  => "ou=${ou_groups}",
      }
    }

    if($nss)
    {
      class { 'ldap::nss':
        base        => $base,
        base_passwd => "ou=${ou_users}",
        base_shadow => "ou=${ou_users}",
        base_group  => "ou=${ou_groups}",
      }
    }

    if($motd)
    {
      motd::register{ 'LDAP with samba support': }
    }
  }
  else
  {
    if($motd)
    {
      motd::register{ 'LDAP without samba support': }
    }
  }

  if($ssl)
  {
    $port = 636
    $real_uri = "ldaps://${uri}"
  }
  else
  {
    $port = 389
    $real_uri = "ldap://${uri}"
  }





  # declare all parameterized classes
  class { 'ldap::params': }
  class { 'ldap::install': }
  class { 'ldap::config': }
  class { 'ldap::service': }
  class { 'ldap::postconfig': }

  # declare relationships
  Class['ldap::params'] ->
  Class['ldap::install'] ->
  Class['ldap::config'] ->
  Class['ldap::service'] ->
  Class['ldap::postconfig']

  if($samba)
  {
    Class['ldap::config'] -> Class['ldap::samba'] -> Class['ldap::smbldap']
  }

  if($pam)
  {
    Class['ldap::config'] -> Class['ldap::pam']
  }

  if($nss)
  {
    Class['ldap::config'] -> Class['ldap::nss']
  }


  # foreach users create a specific config file
  if($samba)
  {
    create_resources(ldap::sambauser, $users)
  }
  else
  {
    create_resources(ldap::user, $users)
  }


  # If replicator : slave or master ?
  # master

  # synchronisator.ldif
  # apply : root/alkivi-scripts/ldap-helper --command add --method auth --file synchronisator.ldif

}

