; Listen on the local interface over TCP (5555), UDP (5555), and websockets
; (5556)
(let [host "0.0.0.0"]
  (tcp-server {:host host})
  (udp-server {:host host})
  (ws-server  {:host host}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; handle escalations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(def pagerd (pagerduty "KEY_GOES_HERE"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run a graphite server
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(def graphite-server-tcp (
   graphite-server :host "0.0.0.0"
                   :port 2004
                   :protocol :tcp
                   :parser-fn
   (fn [{:keys [service] :as event}]
     ; collectd.prod.webserver.client1.memory.memory-free
     ; collectd.prod.webserver.client1.foo.bar.baz.bash
     (let [[source environment application hostname ] (clojure.string/split service #"\." )]
       {
        :host (clojure.string/replace hostname #"_" ".")
        :service (clojure.string/join "." (subvec (clojure.string/split service #"\.") 4))
        :metric (:metric event)
        :tags [source, environment]
        :environment environment
        :application application
        :source source
        :time (:time event)
        :ttl 30}))))
; Expire old events from the index every 60 seconds.
(periodically-expire 60)

(let [index (index)]
  ; All streams go here
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;  Time window example
  ;  Look at the number of HTTP requess in 10 seconds that have
  ;  and HTTP response code of 400 or more
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (streams
    (default { :ttl 60 :severity "major" }
      (where (and (= service "web_hit") (not (expired? event))) 
          (by [:service]
            (fixed-time-window 10
              (smap (fn [events]
              (let [ web_errors (count (filter #(< 399 (:metric %)) events)) ]
                 {:service "Web Errors"
                  :severity "critical"
                  :host "service"
                  :tags ["alert", "sla"]
                  :metric web_errors
                  :ttl 60 
                  :description "Got more than 20 HTTP errors in 10 seconds"
                  :time (get (get (to-array (take-last 1 events )) 0) :time)
                  :state   (condp < web_errors
                             20 "critical"
                                "ok")}))
              reinject
              ))))
      ; Calculate the 95-th percentil of web performance every 10 seconds
      ; creates a new service "web_performance 0.95"
      (where (and (= service "web_performance") (not (expired? event))) 
             (percentiles 10 [ 0.95 ]
                          index
             )))
    )
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;  Go off when a metric hits a certain point and stays above it for a certain
  ;  count, change the state and re-inject it so the pagerduty things below
  ;  can go off
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (streams
    (default {:state "ok" :ttl 60}
      (where (and (service #"^.+cpu\-idle") (not (expired? event)))
        (by [:host :service]
           (fixed-time-window 30
             (smap (fn [events]
               (let [fraction (/ (count (filter #(> 20 (:metric %)) events))
                          (count events))]
                 {:service "CPU_on_fire"
                  :host (get (get events 0) :host)
                  :threshhold fraction
                  :time (get (get (to-array (take-last 1 events )) 0) :time)
                  :severity "major"
                  :state   (condp < fraction
                             0.1 "critical"
                               "ok")}))
               reinject)))
  )))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; collectd based alerts
  (streams
    (default {:ttl 60}
      (tagged-all ["collectd" "prod"]
        index
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          (where (= service "cpu-0.cpu-user")
            (by [:service :application] (coalesce 10
                    ; Measure the CPU usage across all servers and alert if > 40% are over 50%
                    (smap (fn [events]
                      ( let [ percent (/ (* 100 (count (filter #(< 50 (:metric %)) events)))
                                          (count events))]
                        { :service "Environment High CPU Usage"
                          :host (get (get events 0) :application)
                          :metric percent
                          :time (get (get (to-array (take-last 1 events )) 0) :time)
                          :severity "critical"
                          :tags ["alert", "sla"]
                          :state   (condp < percent
                             40 "critical"
                               "ok")
                        }
                    ))
                    reinject
                    index
                  )
                  ; Average together ALL CPU usage 
                  (smap folds/mean
                    (smap (fn [events]
                        { :service "Average CPU Usage"
                          :host (get (get events 0) :application)
                          :time (get (get (to-array (take-last 1 events )) 0) :time)
                          :severity "critical"
                          :tags ["alert", "sla"]
                          :state "ok"
                        }
                            )))
        )))
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; alert on high load
        (where (service #"load.load.midterm")
          (where (>= metric 25.0)
            (where (>= metric 35.0)
               (smap #(assoc % :service "MidTerm Load" :state "critical" :severity "critical" :tags ["alert"]) reinject)
            (else
               (smap #(assoc %  :service "MidTerm Load" :state "critical" :severity "major" :tags ["alert"]) reinject)
            ))
          )
          (where (< metric 25.0 )
             (smap #(assoc %  :service "MidTerm Load" :state "ok" :severity "critical" :tags ["alert"]) reinject)
          )
        )

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; map two events to a third and run over a time period
        (where (or (service #"redis-.+.counter-keyspace_hits") (service #"redis-.+.counter-keyspace_misses"))
               ( by [:host]
                (project [(service "redis-webcache.counter-keyspace_hits")
                          (service "redis-webcache.counter-keyspace_misses")]
                         (fn [[hits misses]]
                           (let [ hit_ratio (/ (* 100 (:metric hits)) (+ (:metric misses) (:metric hits)))]
                           ( reinject {:service "redis cache hit ratio"
                                       :host    (:host hits)
                                       :time    (max (:time hits) (:time misses))
                                       :metric  hit_ratio
                                       :tags  ["redis_hit_ratio", "prod", "collectd"]
                                   })
                           ))
               )))
       (where (= service "redis cache hit ratio")
              (by [:host]
                (fixed-time-window 30
                  (smap (fn [events]
                    (let [fraction (/ (count (filter #(> 25 (:metric %)) events))
                               (count events))]
                      {:service "Cache Hit ratio < 25%"
                       :host (get (get events 0) :host)
                       :metric fraction
                       :last_metric (get (get (to-array (take-last 1 events )) 0) :metric)
                       :time (get (get (to-array (take-last 1 events )) 0) :time)
                       :severity "major"
                       :tags ["alert", "sla"]
                       :state   (condp < fraction
                                  0.9 "critical"
                                    "ok")}))
                        reinject
                  ))))

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  )))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Send pagerduty when severity is major and changes, by setting
  ; the intial state to OK we don't alert on startup but will alert
  ; if the state changes back to OK
  (streams
    (tagged "alert"
    (where ( not ( expired? event ) )
    ; We want to index all of the alerts so we can view them in the dashboard
    index
    ;; This takes all major or critical alerts and creates a stoplight if there's more than 1
    (tagged "sla"
    (where (or (= (:severity event) "critical") (= (:severity event) "major") ) 
    (by [:severity] (coalesce 30
      (smap (fn [events]
         (let [ crit_count (count (filter #(= "critical" (:state %)) events))]
           {:service "SLA STOPLIGHT"
            :host "STOPLIGHT"
            :ttl 60
            :time (get (get (to-array (take-last 1 events )) 0) :time)
            :metric crit_count
            :state   (condp > crit_count
                       1 "ok"
                       2 "warning"
                       "critical")
                       }))
            index
            )))))
    (by [:host :service]
    (default {:state "ok" :ttl 60}
    (changed-state {:init "ok"}

    (where (= (:severity event) "critical")
      ( fn [event] (warn "CRITICAL (PagerDuty) STATE CHANGED: " event) )
      ;(:trigger pager )
           )

    (where (= (:severity event) "major")
      ( fn [event] (warn "MAJOR (Hipchat w/ Mention) STATE CHANGED: " event) )
      ;(with { :description "Database load is critical @all"} hc-hourly)  
           )

    (where (= (:severity event) "minor")
      ( fn [event] (warn "MINOR (Hipchat) STATE CHANGED: " event) )
      ;(with { :description "minor change"} hc-hourly)  
           )
                   
                   ))))))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;  Handle expired events 
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (streams
    (default :ttl 60
      ; Index all events immediately.
      index
      ; Log expired events.
      (expired
        ; we'll always get cpu-0.cpu-idle from any machine running collectd, so it will act as our heartbeat
        (match :service "cpu-0.cpu-idle"
        (fn [event] (info "expired" event)))
        
        )))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
)

