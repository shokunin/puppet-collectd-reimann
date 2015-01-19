# nginx::configure setup
class nginx::configure{

  file { '/etc/nginx/nginx.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/nginx/nginx.conf',
    require => Class['nginx::packages'],
    notify  => Class['nginx::services'],
  }

  file { '/etc/nginx/sites-available/default':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/nginx/default',
    require => Class['nginx::packages'],
    notify  => Class['nginx::services'],
  }
  
}
