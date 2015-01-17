# collectd::packages setup
class collectd::packages{

  package { 'collectd':
    ensure  => installed
  }
  
}
