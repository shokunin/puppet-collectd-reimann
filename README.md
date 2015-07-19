puppet-collectd-riemann
=======================

This sets up three Vagrant boxes for the purpose of testing [riemann monitoring system](http://riemann.io)

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
 +-------------+        +---------------------------------+                            
 | Client      |        | Riemann Server                  |                            
 | +----+      |        | +------------+                  |                            
 |             |        |                                 |       +-----------------+  
 | collectd +------------->carbon-c-relay (port 2003)     |       |  Workstation    |  
 |             |        |            +                    |       |                 |  
 | nginx       |        |            |                    |       |                 |  
 |   +         |        |            v                    |       |  browser        |  
 |   |         |   +------>riemann (graphite port 2004)   |       |     +           |  
 |   v         |   |    |      ^                          |       +-----------------+  
 | logstash+-------+    |      |                          |             |              
 +-------------+        |      +                          |             |              
                        |  riemann+dashboard (port 4567) <--------------+              
                        +---------------------------------+                            

```

dashboard
---------

To see what is going on in Riemann, view the example [dashboard](http://localhost:4567/).


alerts
------

Several alerts have been set up as examples:

| Alert     | Explanation                                                                                         | How to Trigger                                                                | How to view in Dashboard
|-----------|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
|Web Errors | If in a 10 second window more than 20 requests with an HTTP status code of 400 or more are received | On one of the client boxes run "siege -f /opt/siege/10_percent_error.config"  | http://localhost:4567/#All Alerts
