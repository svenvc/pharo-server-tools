check process _SERVICE_NAME_
    with pidfile "/home/_SERVICE_USER_/pharo/_SERVICE_NAME_/run-_SERVICE_NAME_.pid"
    start program = "/bin/systemctl start _SERVICE_NAME_"
    stop program = "/bin/systemctl stop _SERVICE_NAME_"
    if failed 
	   port _METRICS_PORT_
	   protocol http
	   request "/metrics/system.status"
	   status = 200
	   content = "Status OK"
       timeout 10 seconds retry 3
    then restart
