# fakesiege::packages setup
class fakesiege::packages{

  package { 'siege':
    ensure => installed,
  }
  
}
