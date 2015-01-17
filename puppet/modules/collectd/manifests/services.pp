# collectd::services setup
class collectd::services{

  service { 'collectd':
    enable    => true,
    ensure    => running,
    hasstatus => true,
  }
  
}
