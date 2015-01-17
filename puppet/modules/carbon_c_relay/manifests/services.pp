# carbon_c_relay::services setup
class carbon_c_relay::services{

  runit::services::runner { 'carbon-c-relay':
    runner_command => '/usr/local/bin/relay -f /etc/relay.config',
    runner_log_dir => '/var/log/carbon-c-relay',
    require        => Class['carbon_c_relay::packages', 'carbon_c_relay::configure'],
  }
  
}
