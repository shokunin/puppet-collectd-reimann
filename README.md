puppet-collectd-riemann
=======================

This sets up two Vagrant boxes for the purpose of testing [riemann monitoring system](http://riemann.io)

client
------

Sends collectd stats to the server VM


server
------

Runs the following processes:

	- collectd: 		submits stats to the localhost
	- carbon-c-relay:	takes graphite input and sends a copy to riemann
	- riemann:			runs the riemann monitoring server with a basic configuration
	- nginx:	        client system runs Nginx	
	- logstash:	        takes nginx input and sends events to riemann	

data flow
---------
```
                           +------------+-------------------+
        +----------+       | Riemann Server                 |
        |  Nodes   |       |                                |
        | collectd +-------->carbon-c-relay (port 2003)     |
        |  nginx   |       |            +                   |
        | logstash +---+   |            |                   |
        +----------+   |   |            |                   |
                       |   |            |                   |
                       |   |            v                   |
                       +---->riemann (graphite port 2004)   |
                           |                                |
                           +------------+-------------------+
```

