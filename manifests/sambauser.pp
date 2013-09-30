define ldap::sambauser (
  $email        = $title,
  $uname        = $title,
  $firstName    = $title,
  $lastName     = $title,
  $create_local = true,
) {

  Exec {
    require => [ File['/root/alkivi-scripts/ldap-helper', '/usr/sbin/smbldap-useradd', '/root/alkivi-scripts/ldap-add-sambaUser'], Exec['populate-ldap'] ],
  }

  if($createLocal)
  {
    $create_command = '-c'
  }
  else
  {
    $create_command = ''
  }

  exec { "create-user-${uname}":
    command => "/root/alkivi-scripts/ldap-add-sambaUser -f ${firstName} -l ${lastName} -m ${email} -u ${uname} ${create_command}",
    path    => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/', '/usr/sbin'],
    unless  => "slapcat | grep -q 'dn: uid=${uname}'",
  }



}
