class riemann::services inherits riemann {

  include runit

  runit::services::runner { 'riemann':
    runner_command => 'bin/riemann etc/riemann.config',
    runner_rundir  => '/opt/riemann',
    runner_log_dir => '/var/log/riemann',
    require        => Class['riemann::configure', 'riemann::packages'],
  }

}
