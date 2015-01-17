# collectd::configure setup
class collectd::configure{

  file { '/etc/collectd/collectd.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/collectd/collectd.conf',
    require => Class['collectd::packages'],
    notify  => Class['collectd::services'],
  }
  
}
