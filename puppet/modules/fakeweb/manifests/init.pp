# Init for fakeweb
class fakeweb {
  include fakeweb::packages
  include fakeweb::configure
  include fakeweb::services
}
