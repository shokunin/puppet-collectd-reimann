class logstash::services inherits logstash {

  include runit

  runit::services::runner { 'logstash':
    runner_command => 'bin/logstash agent -f /etc/logstash/conf.d/01-logstash_riemann.conf',
    runner_rundir  => '/opt/logstash',
    runner_log_dir => '/var/log/logstash',
    require        => Class['logstash::configure', 'logstash::packages'],
  }

}
