class riemann::configure inherits riemann {
  file { '/opt/riemann/etc/riemann.config':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/riemann/riemann.config',
    require => Class['riemann::packages'],
    notify  => Class['riemann::services'],
  }


  # This file can be edited by the app, so we just need a base to start from
  exec { 'create_base_dashboard_config':
    command => '/bin/echo "set :bind, \"0.0.0.0\"" > /opt/riemann/etc/dashboard.config ',
    creates => '/opt/riemann/etc/dashboard.config',
    require => Class['riemann::packages'],
    notify  => Class['riemann::services'],
  }

}
