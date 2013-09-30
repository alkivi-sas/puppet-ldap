class ldap::params () {
	case $operatingsystem {
		/(Ubuntu|Debian)/: {
			$ldap_service_name   = 'slapd'
			$ldap_package_name   = ['slapd', 'ldapscripts']
		}
		default: {
			fail("Module ${module_name} is not supported on ${operatingsystem}")
		}
	}
}

