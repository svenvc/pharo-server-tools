(NeoConsoleTranscript onFileNamed: 'server-{1}.log') install.

Transcript
  cr;
  show: 'Starting '; show: (NeoConsoleTelnetServer startOn: _TELNET_PORT_); cr;
  "show: 'Starting '; show: (NeoConsoleMetricDelegate startOn: _METRICS_PORT_); cr;"
  flush.

"_SERVICE_NAME_ server application script"

Smalltalk logFileName: 'error.log'. "Default is 'PharoDebug.log'"

ZTimezone
  reloadAll ;
  current: (ZTimezone id: 'Europe/Amsterdam').

"Set log level to TRACE and print debug stacks at first install."
OGLog
  level: #TRACE ;
  printDebugStack: true.

"***** Hotfixes start here:"
"Hotfix: Increase timeout for REPL (telnet console)."
NeoConsoleTelnetServer compile: 'timeout
        ^ 5 * 60'.
"End hotfixes *****"

"Start Synthesist web application."
_SERVICE_NAME_Domain default startProductionWithSettings: (ESApplicationSettings new
  webPort: _PROXY_PORT_ ;
  databaseName: '_SERVICE_NAME_' ;
  databaseUser: '_SERVICE_NAME_';
  databasePassword: '_SERVICE_NAME_' ;
  yourself).

_SERVICE_NAME_Domain z_migrate.
