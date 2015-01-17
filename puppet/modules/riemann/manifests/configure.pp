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
}
