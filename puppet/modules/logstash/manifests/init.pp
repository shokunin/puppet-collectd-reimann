class logstash {
  include logstash::packages
  include logstash::configure
  include logstash::services
}
