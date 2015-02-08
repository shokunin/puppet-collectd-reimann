# fakeweb::packages setup
class fakeweb::packages{

  file { '/usr/local/bin/fakeweb':
    ensure => present,
    owner  => root,
    group  => root,
    source => "puppet:///modules/fakeweb/fakeweb",
    mode   => 0755,
  }
  
}
