# nginx::services setup
class nginx::services{
  
  service { 'nginx':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

}
