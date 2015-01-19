# logstash::services setup
class logstash::services{

  include runit

  runit::services::runner { 'logstash':
    runner_command => '/opt/logstash/bin/logstash agent -f /etc/logstash.conf',
    runner_rundir  => '/opt/logstash',
    runner_log_dir => '/var/log/logstash',
    require        => Class['logstash::configure', 'logstash::packages'],
  }

  
}
