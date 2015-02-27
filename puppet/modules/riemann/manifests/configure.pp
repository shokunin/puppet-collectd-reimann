class riemann::configure inherits riemann {
  file { '/opt/riemann/etc/riemann.config':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/riemann/riemann.clj',
    require => Class['riemann::packages'],
    notify  => Class['riemann::services'],
  }

  file { '/var/lib/gems/1.9.1/gems/riemann-dash-0.2.10/config':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    require => Class['riemann::packages'],
  }

  # This file can be edited by the app, so we just need a base to start from
  exec { 'create_base_dashboard_config':
    command => '/bin/echo "set :bind, \"0.0.0.0\"" > /opt/riemann/etc/dashboard.config ',
    creates => '/opt/riemann/etc/dashboard.config',
    require => Class['riemann::packages'],
    notify  => Class['riemann::services'],
  }

  file { '/var/lib/gems/1.9.1/gems/riemann-dash-0.2.10/config/config.json':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/riemann/config.json',
    require => [Class['riemann::packages'],File['/var/lib/gems/1.9.1/gems/riemann-dash-0.2.10/config']]
  }
  
}
