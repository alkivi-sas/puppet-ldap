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
  $motd         = true,
  $firewall     = true,

) {


  if($motd)
  {
    motd::register{ 'LDAP Server': }
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

  # If replicator : slave or master ?
  # master

  # synchronisator.ldif
  # apply : root/alkivi-scripts/ldap-helper --command add --method auth --file synchronisator.ldif

}

