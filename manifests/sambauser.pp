define ldap::sambauser (
  $email        = $title,
  $uname        = $title,
  $firstName    = $title,
  $lastName     = $title,
  $create_local = false,
) {


  validate_string($email)
  validate_string($uname)
  validate_string($firstName)
  validate_string($lastName)
  validate_bool($create_local)

  if($create_local)
  {
    $create_command = '-c'
  }
  else
  {
    $create_command = ''
  }

  # Store password
  alkivi_base::passwd{ "ldap-${uname}":
    file => $uname,
    type => 'ldap',
  }

  exec { "create-user-${uname}":
    command => "/root/alkivi-scripts/ldap-add-sambaUser -f \"${firstName}\" -l \"${lastName}\" -m ${email} -u \"${uname}\" ${create_command}",
    path    => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/', '/usr/sbin'],
    require => [ File['/root/alkivi-scripts/ldap-helper', '/usr/sbin/smbldap-useradd', '/root/alkivi-scripts/ldap-add-sambaUser'], Exec['populate-ldap'], Alkivi_base::Passwd["ldap-${uname}"] ],
    unless  => "slapcat | grep -q 'dn: uid=${uname},'",
  }



}
