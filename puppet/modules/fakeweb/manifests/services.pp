# fakeweb::services setup
class fakeweb::services{

  include runit

   runit::services::runner { 'fakeweb':
     runner_command => '/usr/local/bin/fakeweb',
     runner_rundir  => '/tmp/',
     runner_log_dir => '/var/log/fakeweb',
     require        => Class['fakeweb::packages', 'fakeweb::configure']
   }
  
}
