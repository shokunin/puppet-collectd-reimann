class riemann::services inherits riemann {

  include runit

  runit::services::runner { 'riemann':
    runner_command => 'bin/riemann etc/riemann.config -Djava.net.preferIPv4Stack=true',
    runner_rundir  => '/opt/riemann',
    runner_log_dir => '/var/log/riemann',
    require        => Class['riemann::configure', 'riemann::packages'],
  }

  runit::services::runner { 'riemann-dash':
    runner_command => '/usr/local/bin/riemann-dash /opt/riemann/etc/dashboard.config',
    runner_rundir  => '/opt/riemann',
    runner_log_dir => '/var/log/riemann-dash',
    require        => Class['riemann::configure', 'riemann::packages'],
  }

}
