# logstash::configure setup
class logstash::configure{

  file { '/etc/logstash.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/logstash/logstash.conf',
    require => Class['logstash::packages'],
    notify  => Class['logstash::services'],
  }
  
}
