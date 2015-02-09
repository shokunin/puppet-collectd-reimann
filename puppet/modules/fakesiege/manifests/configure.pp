# fakesiege::configure setup
class fakesiege::configure{

  file { '/opt/siege':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    recurse => true,
    source  => 'puppet:///modules/fakesiege/configs',
  }

}
