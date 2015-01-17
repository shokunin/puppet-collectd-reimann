# carbon_c_relay::configure setup
class carbon_c_relay::configure{

  file { '/etc/relay.config':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/carbon_c_relay/relay.config',
    require => Class['carbon_c_relay::packages'],
    notify  => Class['carbon_c_relay::services']
  }
  
  
}
