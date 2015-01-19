# Init for nginx
class nginx {
  include nginx::packages
  include nginx::configure
  include nginx::services
}
