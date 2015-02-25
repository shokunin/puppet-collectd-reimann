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
     ; collectd.prod.client1.memory.memory-free
     ; collectd.prod.client1.foo.bar.baz.bash
     (let [[source environment hostname ] (clojure.string/split service #"\." )]
       {
        :host (clojure.string/replace hostname #"_" ".")
        :service (clojure.string/join "." (subvec (clojure.string/split service #"\.") 3))
        :metric (:metric event)
        :tags [source, environment]
        :time (:time event)
        :ttl 30}))))
; Expire old events from the index every 60 seconds.
(periodically-expire 60)

(let [index (index)]
  ; All streams go here
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;  Time window example
  ;  if there are no events then the causes an NPE
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (streams
    (default { :ttl 60 :severity "major" }
      (where (and (service #"web_hit_404$") (not (expired? event))) 
        (fixed-time-window 10
          (combine riemann.folds/sum
            (where (> metric 5.0)
               (smap #(assoc % :service "404's.critical" :state "critical" :tags ["alert"]) reinject)
            (else
               (smap #(assoc % :service "404's.critical" :state "ok" :tags ["alert"]) reinject)
              )))
  ))))
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
               ;prn
               reinject)))
  )))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; collectd debugging
  (streams
    (default :ttl 60
      (tagged-all ["collectd" "debug"]
                  prn
                  )))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; collectd based alerts
  (streams
    (default {:ttl 60}
      (tagged-all ["collectd" "prod"]
        index
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; alert on high load
        (where (service #"load.load.midterm")
          (where (>= metric 25.0)
            (where (>= metric 35.0)
               (smap #(assoc % :service "load.critical" :state "critical" :severity "critical" :tags ["alert"]) reinject)
            (else
               (smap #(assoc %  :service "load.major" :state "critical" :severity "major" :tags ["alert"]) reinject)
            ))
          )
          (where (< metric 25.0 )
             (smap #(assoc %  :service "load.critical" :state "ok" :severity "critical" :tags ["alert"]) reinject)
             (smap #(assoc %  :service "load.major" :state "ok" :severity "major" :tags ["alert"]) reinject)
             (smap #(assoc %  :service "load.minor" :state "ok" :severity "minor" :tags ["alert"]) reinject)
          )
        )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  )))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Send pagerduty when severity is major and changes, by setting
  ; the intial state to OK we don't alert on startup but will alert
  ; if the state changes back to OK
  (streams
    (tagged "alert"
    (where ( not ( expired? event ) )
    index
    (by [:host :service]
    (default {:state "ok" :ttl 60}
    (changed-state {:init "ok"}

    (where (service #".+.critical")
      ( fn [event] (warn "CRITICAL (PagerDuty) STATE CHANGED: " event) )
      ;(:trigger pager )
           )

    (where (service #".+.major")
      ( fn [event] (warn "MAJOR (Hipchat w/ Mention) STATE CHANGED: " event) )
      ;(with { :description "Database load is critical @all"} hc-hourly)  
           )

    (where (service #".+.minor")
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

