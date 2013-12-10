define ldap::user (
  $email,
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

  Exec {
    require => [ File['/root/alkivi-scripts/ldap-helper', '/root/alkivi-scripts/ldap-add-user'], Exec['/etc/ldap/alkivi-conf/olcGroups.ldif'] ],
  }

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
    command  => "/root/alkivi-scripts/ldap-add-user -f ${firstName} -l ${lastName} -m ${email} -u ${uname} -g ${group} ${create_command}",
    unless   => "ldapsearch -x \"objectclass=posixAccount\" uid | grep -v ^dn | grep -v ^$ | sed -e 's/uid: //g' | grep -v \\# | grep -v : | grep ^${uname}$",
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
    require => [ File['/root/alkivi-scripts/ldap-helper', '/usr/sbin/smbldap-useradd', '/root/alkivi-scripts/ldap-add-user'], Exec['populate-ldap'], Alkivi_base::Passwd["ldap-${uname}"] ],
  }



}
