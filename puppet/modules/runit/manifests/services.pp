# runit::services setup
class runit::services{

  define runner(  $runner_command,
                  $runner_log_dir='',
                  $runner_name='',
                  $runner_template='default',
                  $runner_user='root',
                  $runner_rundir='',
                  $runner_ulimit='',
                  $runner_prerun_command='' ) {

    ##############################################################
    # Set some variable being passed around with sensible defaults

    if $runner_name == '' {
      $service_name = $name
    } else {
      $service_name = $runner_name
    }

    if $runner_log_dir == '' {
      $runit_log_dir = "/var/log/${service_name}"
    } else {
      $runit_log_dir = $runner_log_dir
    }

    ##############################################################
    # create all files

    file { $runit_log_dir:
      ensure  => directory,
      owner   => $runner_user,
      group   => $runner_user,
      mode    => '0755',
      require => Class['runit::packages']
    }

    file { "/etc/sv/${service_name}":
      ensure  => directory,
      owner   => root,
      group   => root,
      require => Class['runit::packages']
    }

    file { "/etc/sv/${service_name}/log":
      ensure  => directory,
      owner   => root,
      group   => root,
      require => [File["/etc/sv/${service_name}"], File[$runit_log_dir]],
    }

    file { "/etc/sv/${service_name}/supervise":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0700',
      require => [File["/etc/sv/${service_name}"]],
    }

    file { "/etc/sv/${service_name}/run":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0755',
      content => template("runit/service.${runner_template}.erb"),
      require => File["/etc/sv/${service_name}"],
    }

    file { "/etc/sv/${service_name}/log/run":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0755',
      content => template("runit/log.${runner_template}.erb"),
      require => File["/etc/sv/${service_name}/log"],
    }

    file { "/etc/service/${service_name}":
      ensure => link,
      target => "/etc/sv/${service_name}",
    }

    service { $service_name:
      ensure   => running,
      enable   => true,
      provider => runit,
      path     => '/etc/service',
      require  => [ File["/etc/sv/${service_name}/log/run"],
                    File["/etc/sv/${service_name}/supervise"],
                    File["/etc/service/${service_name}"],
                    Class['runit::packages']],
    }

  } 

  
}
