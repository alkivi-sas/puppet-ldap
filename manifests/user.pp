define ldap::user (
  $email,
  $uname        = $title,
  $firstName    = $title,
  $lastName     = $title,
  $create_local = true,
) {

  Exec {
    require => [ File['/root/alkivi-scripts/ldap-helper', '/root/alkivi-scripts/ldap-add-user'], Exec['/etc/ldap/alkivi-conf/olcGroups.ldif'] ],
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
    command  => "/root/alkivi-scripts/ldap-add-user -f ${firstName} -l ${lastName} -m ${email} -u ${uname} -g ${group} ${create_command}",
    unless   => "ldapsearch -x \"objectclass=posixAccount\" uid | grep -v ^dn | grep -v ^$ | sed -e 's/uid: //g' | grep -v \\# | grep -v : | grep ^${uname}$",
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
  }



}
