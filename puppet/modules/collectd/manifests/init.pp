# Init for collectd
class collectd {
  include collectd::packages
  include collectd::configure
  include collectd::services
}
