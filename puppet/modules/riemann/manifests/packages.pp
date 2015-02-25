class riemann::packages inherits riemann {

  include java


  exec { 'download_riemann':
    refreshonly => false,
    command     => '/usr/bin/wget https://aphyr.com/riemann/riemann-0.2.8.tar.bz2',
    cwd         => '/opt',
    creates     => '/opt/riemann-0.2.8.tar.bz2',
    require     => Class['unix_base::common', 'java'],
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

  package { 'libxml2-dev':
    ensure  => installed
  }

  package { 'libxslt1-dev':
    ensure  => installed
  }

  package { 'ruby1.9.1':
    ensure => installed,
    require => [ File['/opt/riemann'], Package['libxslt1-dev', 'libxml2-dev'] ]
  }

  package { 'ruby1.9.1-dev':
    ensure  => installed,
    require => Package['ruby1.9.1'],
  }

  $gemlist=['riemann-client', 'riemann-tools', 'riemann-dash']
 
  package { $gemlist:
    ensure   => installed,
    provider => gem,
    require  => Package['ruby1.9.1-dev'],
  }

  file { '/usr/local/bin/send_fake_graphite':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/riemann/send_fake_graphite',
  }
  

}
