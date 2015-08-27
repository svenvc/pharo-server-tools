check process _SERVICE_NAME_
    with pidfile "/home/_SERVICE_USER_/pharo/_SERVICE_NAME_/run-_SERVICE_NAME_.pid"
    start program = "/etc/init.d/_SERVICE_NAME_ start"
    stop program = "/etc/init.d/_SERVICE_NAME_ stop"
    if failed url http://localhost:_METRICS_PORT_/metrics/system.status
       timeout 10 seconds retry 3
       then restart 
