# logstash::packages setup
class logstash::packages{

  $ls_version = '1.4.2'

  include java

  exec { 'fetch_logstash':
    refreshonly => false,
    command     => "/usr/bin/wget https://download.elasticsearch.org/logstash/logstash/logstash-${ls_version}.tar.gz",
    cwd         => '/opt',
    creates     => "/opt/logstash-${ls_version}.tar.gz",
    require     => Class['java'],
  }

  exec { 'unzip_logstash':
    refreshonly => false,
    command     => "/bin/tar -xzf /opt/logstash-${ls_version}.tar.gz",
    creates     => "/opt/logstash-${ls_version}",
    cwd         => '/opt',
    require     => Exec['fetch_logstash'],
  }

  exec { 'install_contrib':
    refreshonly => false,
    command     => '/opt/logstash/bin/plugin install contrib',
    cwd         => '/opt/logstash',
    creates     => '/opt/logstash/vendor/logstash/logstash-contrib-1.4.2',
    require     => File['/opt/logstash'],
  }


  file { '/opt/logstash':
    ensure  => link,
    target  => "/opt/logstash-${ls_version}",
    require => Exec['unzip_logstash'],
  }
  
}
