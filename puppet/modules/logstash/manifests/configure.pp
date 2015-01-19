class logstash::configure inherits logstash {
  
 file { '/etc/logstash/conf.d/01-logstash_riemann.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/logstash/logstash_riemann.conf',
    require => Class['logstash::packages'],
    notify  => Class['logstash'],
  }
  
}
