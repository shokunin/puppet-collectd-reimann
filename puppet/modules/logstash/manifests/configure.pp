class logstash::configure inherits logstash {
  file { '/etc/logstash/logstash_riemann.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/logstash/logstash_forwarder.conf',
    require => Class['logstash::packages'],
    notify  => Class['logstash'],
  }

}
