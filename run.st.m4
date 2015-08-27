(NeoConsoleTranscript onFileNamed: 'server-{1}.log') install.

Transcript
  cr;
  show: 'Starting '; show: (NeoConsoleTelnetServer startOn: _TELNET_PORT_); cr;
  show: 'Starting '; show: (NeoConsoleMetricDelegate startOn: _METRICS_PORT_); cr;
  flush.

"The following expression should be replaced by custom code"

(ZnServer defaultOn: 8080)
  logToTranscript;
  logLevel: 2;
  start.
