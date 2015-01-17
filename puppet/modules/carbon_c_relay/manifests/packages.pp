# carbon_c_relay::packages setup
class carbon_c_relay::packages{

  exec { 'download_source':
    command => '/usr/bin/git clone https://github.com/grobian/carbon-c-relay.git',
    cwd     => '/var/tmp',
    creates => '/var/tmp/carbon-c-relay',
    require => Class['unix_base::common'],
  }

  exec { 'make_install':
    command => '/usr/bin/make',
    cwd     => '/var/tmp/carbon-c-relay',
    creates => '/var/tmp/carbon-c-relay/relay',
    require => Exec['download_source'],
  }

  exec { 'install_relay':
    command => '/bin/cp /var/tmp/carbon-c-relay/relay /usr/local/bin/relay',
    creates => '/usr/local/bin/relay',
    require => Exec['make_install'],
  }
  
}
