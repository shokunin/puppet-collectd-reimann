# runit::packages setup
class runit::packages{

  package { 'runit':
    ensure  => installed
  }
  
}
