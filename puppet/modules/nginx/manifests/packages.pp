# nginx::packages setup
class nginx::packages{

  package { 'nginx':
    ensure  => installed
  }
  
}
