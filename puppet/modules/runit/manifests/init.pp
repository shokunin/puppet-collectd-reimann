# Init for runit
class runit {
  include runit::packages
  include runit::configure
  include runit::services
}
