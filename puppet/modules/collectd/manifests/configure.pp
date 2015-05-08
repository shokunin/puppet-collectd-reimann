# collectd::configure setup
class collectd::configure{

  if $::hostname =~ /client/ {
    $application = 'webserver'
  } else {
    $application = 'riemann'
  }

  file { '/etc/collectd/collectd.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => "puppet:///modules/collectd/collectd.conf.${application}",
    require => Class['collectd::packages'],
    notify  => Class['collectd::services'],
  }
  
}
