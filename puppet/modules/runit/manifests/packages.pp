# runit::packages setup
class runit::packages{

  package { 'runit':
    ensure  => installed
  }

  file { '/service':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  
  
}
