class unix_base::cpuburn inherits unix_base {

  if $::osfamily == 'Debian' {

    package { 'cpuburn' :
      ensure  => installed,
      require => Class['unix_base::common'],
    }

  }

}
