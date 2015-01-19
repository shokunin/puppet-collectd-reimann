class logstash::packages inherits logstash {

  apt::key { "GPG-KEY-elasticsearch":
    key        => "D88E42B4",
    key_source => "http://packages.elasticsearch.org/GPG-KEY-elasticsearch",
  }

  apt::source { 'logstash':
    location     => 'http://packages.elasticsearch.org/logstash/1.4/debian',
    include_src  => false,
    release      => "stable",
    repos        => 'main';
  }

  package { 'logstash':
    ensure  => installed, 
    require => Apt::Source['logstash'],
  }
  
}
