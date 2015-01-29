class java {

  package { 'openjdk-7-jre':
    ensure  => installed,
    require => Class['unix_base'],
  }

}
