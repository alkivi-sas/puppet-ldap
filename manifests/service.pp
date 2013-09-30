class ldap::service () {
	service { $ldap::params::ldap_service_name:
		ensure     => running,
		hasstatus  => true,
		hasrestart => true,
		enable     => true,
	}
}

