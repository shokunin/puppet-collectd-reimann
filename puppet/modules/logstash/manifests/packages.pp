class logstash::packages inherits logstash {

  apt::key { "logstash_repo":
  #key        => "0211F6D4",
    key_source => "http://packages.elasticsearch.org/GPG-KEY-elasticsearch",
  }

  apt::source { 'logstash_repo':
    location     => 'http://packages.elasticsearch.org/logstash/1.4/debian',
    include_src  => false,
    release      => "stable",
    repos        => 'main';
  }

  package { 'logstash':
    ensure  => installed, 
    require => Apt::Source['logstash_repo'],
  }
  
  file { '/etc/logstash/conf.d/01-logstash_riemann.conf':
    ensure  => present,
    source  => 'puppet:///modules/logstash_forwarder/logstash_riemann.conf',
    require => Package['logstash'],
  }

}
