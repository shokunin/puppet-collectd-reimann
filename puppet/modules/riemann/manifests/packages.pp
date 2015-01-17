class riemann::packages inherits riemann {

  package { 'openjdk-7-jre':
    ensure  => installed
  }

  exec { 'download_riemann':
    refreshonly => false,
    command     => '/usr/bin/wget https://aphyr.com/riemann/riemann-0.2.8.tar.bz2',
    cwd         => '/opt',
    creates     => '/opt/riemann-0.2.8.tar.bz2',
    require     => [Class['unix_base::common'],Package['openjdk-7-jre']],
  }

  exec { 'uncompress_riemann':
    command => '/bin/tar xjf riemann-0.2.8.tar.bz2',
    cwd     => '/opt',
    creates => '/opt/riemann-0.2.8',
    require => Exec['download_riemann'],
  }

  file { '/opt/riemann':
    ensure  => link,
    target  => '/opt/riemann-0.2.8',
    require => Exec['uncompress_riemann'],
  }

}
