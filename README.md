# Pharo Server Tools

Tools to deploy and manage headless Pharo servers from the command line.


## Goal

To deploy and manage a Pharo based server application on a Linux system.
More specifically, Pharo 4 on Ubuntu 14.04 LTS server.

The goal is to integrate well within the standard Linux world,

- create an entry in `/etc/init.d` or `/etc/systemd/system/` for automatic start/stop/restart
- create an entry in `/etc/monit/conf.d` for monitoring with automatic restarts whenever the check fails
- setup logging to daily files
- setup secure REPL access to the running application

This document describes the basic manual installation procedure.
There is also an interactive scaffold script that automates most work.


## Installation

Note that we assume that you operate your machine as a normal user.

````bash
echo $USER
````

Check out the project `pharo-server-tools` from github.
You will need to install git first

````bash
sudo apt-get install git-core 
git clone https://github.com/svenvc/pharo-server-tools.git
````

The following directory structure is used

````bash
~/pharo
~/pharo/bin
~/pharo/bin/pharo-vm
~/pharo/build
````

The script `install-pharo.sh` will download a Pharo 4 image + VM
and move things around to create the directory structure.
This has to be done only once. You will need to install unzip.

````bash
sudo apt-get install unzip
~/pharo-server-tools/install-pharo.sh
````

You can use both a 32 or 64 bit Ubuntu distribution.
However, since the Pharo VM is still a 32 bit application, 
you will need to install some extra libraries in that case.

The standard instructions are

````bash
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386
sudo apt-get install libssl1.0.0:i386
sudo apt-get install libfreetype6:i386
````

You can use the script `ubuntu-32bit-support-on-64bit.sh` for this.


## Server Application

It is assumed your whole application is packaged using 
one single Metacello configuration that loads all dependencies.

Note that if you want to use the REPL and HTTP monitoring features described here, you need to include NeoConsole as one of your dependencies.

````
project: 'NeoConsole' with: [
  spec 
    className: 'ConfigurationOfNeoConsole';
    repository: 'http://mc.stfx.eu/Neo' ];
````

Furthermore it is assumed that you have a script that actually
starts up your application. This could be as simple as
`MyApp start` but will probably be a bit more involved.

Each server application will eventually be deployed and run
from its own directory under `~/pharo`. From the operational
standpoint this is the only relevant place.

Next we describe the different steps needed
to set everything up manually.
There is also an interactive script to automate all these steps.

````bash
./pharo-server-tools/scaffold.sh
````

Here is an example usage, installing a Pharo HTTP Server, with NeoConsole as sole dependency.

````bash
$ ./scaffold.sh 
This script will setup a new Pharo service under /home/t3/pharo
Service name: pharo-http-server
Image name (empty for service name): 
User (empty for current user): 
Description: Pharo HTTP Server
Metacello repository: http://mc.stfx.eu/Neo
Metacello name: ConfigurationOfNeoConsole
Metacello user (empty for none): 
Metacello password (empty for none): 
Metacello version (empty for stable): 
Metacello group (empty for default): 
Telnet port (empty for 42001): 
Metrics port (empty for 42002): 
Creating custom build script
This script will build a pharo-http-server image
'Installing ConfigurationOfNeoConsole stable'

Loading 8 of ConfigurationOfNeoConsole...
Fetched -> Neo-Console-Core-SvenVanCaekenberghe.15 --- http://mc.stfx.eu/Neo --- http://mc.stfx.eu/Neo
Loaded -> Neo-Console-Core-SvenVanCaekenberghe.15 --- http://mc.stfx.eu/Neo --- cache
...finished 8
Creating custom run/startup script
Creating custom REPL script
Creating custom init.d script
Creating custom systemd.service script
Creating custom monit service check
Done
To install the init.d script do
sudo cp /home/t3/pharo/pharo-http-server/init.d.script /etc/init.d/pharo-http-server
sudo update-rc.d pharo-http-server defaults
To install the systemd.service script do
sudo cp /home/t3/pharo/pharo-http-server/systemd.service.script /etc/systemd/system/pharo-http-server.service
sudo systemctl daemon-reload
sudo systemctl enable pharo-http-server
To install the monit service check do
sudo cp /home/t3/pharo/pharo-http-server/monit-service-check /etc/monit/conf.d/pharo-http-server
````


## Building

Pharo uses an image to hold all the objects and code needed to run
an application. You need to build your custom image by loading
your code into the standard image. This build from source step is
executed in the `~/pharo/build` directory.

Building will be done incrementally in a scratch image called
`build.image`. This is created once or whenever you want to 
completely start over. In the build directory do

````bash
../bin/pharo Pharo.image save build
````

Now edit the build.sh script to refer to load your configuration.
The default just loads NeoConsole for the REPL tool, a dependency
you should add to your own projects. For the demo/tutorial this
will be enough.

````bash
./build.sh
````

After a successful build, copy the image again. Our demo/tutorial
application will be called `pharo-http-server`.

````bash
../bin/pharo build.image save pharo-http-server
````

When you update your code, you execute the last 2 steps again.


## Deploying

### Preparing the deploy directory

Start by creating your deploy directory

````bash
mkdir ~/pharo/pharo-http-server
````

Now move over the customised image and changes files that were
created in the build step

````bash
mv ~/pharo/build/pharo-http-server.* ~/pharo/pharo-http-server
````

To control our application process itself, to start it in the background,
to figure out whether it is running and its process id, to stop it,
we use a helper script called `pharo-ctl.sh`. Copy it 

````bash
cp ~/pharo-server-tools/pharo-ctl.sh ~/pharo/pharo-http-server
````

Next we need a run or startup script. The template is good for the
demo/tutorial, you will probably have to customise it. Copy it

````bash
cp ~/pharo-server-tools/run.st.template ~/pharo/pharo-http-server/run-pharo-http-server.st
````

Here is the script’s contents:

````smalltalk
(NeoConsoleTranscript onFileNamed: 'server-{1}.log') install.

Transcript
  cr;
  show: 'Starting '; show: (NeoConsoleTelnetServer startOn: 42001); cr;
  show: 'Starting '; show: (NeoConsoleMetricDelegate startOn: 42002); cr;
  flush.

(ZnServer defaultOn: 8080)
  logToTranscript;
  logLevel: 2;
  start.
````

The first expression installs a non-interactive transcript that redirects
all Transcript output to files which are organised by day.

Next, the tools from the NeoConsole project are used to start 2 helper services.
The first is a locally bound Telnet server that allows for REPL access 
to a running image which is very useful for debugging and monitoring purposes.
The second is a locally bound HTTP server that gives access to a number
of metrics, named read-only properties, among which is `system.status`.

Finally we start our application, an HTTP server on port 8080, with logging.

We now have everything set up to manually run our application server.
The `pharo-ctl` script always takes 3 arguments, the name of the 
startup script, the desired operation and the name of the image.
Execute it without arguments for help

````bash
./pharo-ctl.sh 
Executing ./pharo-ctl.sh
Working directory /home/sven/pharo/pharo-http-server
Usage: ./pharo-ctl.sh <script> <command> <image>
    manage a Pharo server
Naming
    script       is used as unique identifier
    script.st    must exist and is the Pharo startup script  
    script.pid   will be used to hold the process id
    image.image  is the Pharo image that will be started
Commands:
    start    start the server in background
    stop     stop the server
    restart  restart the server
    run      run the server in foreground
    pid      print the process id 
````

Note that the extensions `.st` and `.image` are added automatically.

Here is how to start our application

    ./pharo-ctl.sh run-pharo-http-server start pharo-http-server

Note that the image could be started multiple times, like when running N
instances for load balancing, but the startup/run script should be unique,
like `run.0.st`, `run.1.st` and so on. The combination image/script should
be unique on your machine.

To figure out whether it is running and get its process id (PID)

````bash
./pharo-ctl.sh run-pharo-http-server pid pharo-http-server
````

To stop the background process

````bash
./pharo-ctl.sh run-pharo-http-server stop pharo-http-server
````

You can invoke this last command multiple times if you somehow managed 
to start multiple copies.


### Integrating with Linux Init Scripts

You want your application server to be under control of Linux,
so that it will start automatically whenever your machine (re)starts.
System administrators need this so called service entry to learn 
about your application. We will reuse this feature ourselves later on as well.

#### init.d

To do this you have to create a script inside `/etc/init.d`.
Copy the template and update the System V style RC init subsystem:

````bash
sudo cp ~/pharo-server-tools/init.d.template /etc/init.d/pharo-http-server
sudo update-rc.d pharo-http-server defaults
````

Again, the script is more or less ready for our demo/tutorial.
Check the variables at the top, you need to change the `user` in 
the `PHDIR=` and `SU=` lines to the actual user you are using.

If everything is well, Linux can now control your application.

````bash
sudo service pharo-http-server
sudo service pharo-http-server start
sudo service pharo-http-server stop
````

#### systemd

Alternatively, you can use the newer systemd approach.
To do this you have to create a script inside `/etc/systemd/system`.
Copy the template, reload the daemon and enable the service.

````bash
sudo cp ~/pharo-server-tools/systemd.service.template /etc/systemd/system/pharo-http-server.service
sudo systemctl daemon-reload
sudo systemctl enable pharo-http-server
````

Make sure to change the user. Now you can manipulate the service in a standard way.

````bash
sudo systemctl stop pharo-http-server
sudo systemctl start pharo-http-server
sudo systemctl status pharo-http-server
````


### Integrating with monitoring

Your application server might crash or become otherwise unresponsive.
You want automatic monitoring of some external feature of your
application server with the option to restart it should the service check fail.

In our startup script we started a special, locally bound HTTP server just
for this purpose, running on port 42002. The URI `/metrics/system.status` gives
a simple service status indication.

````bash
curl http://localhost:42002/metrics/system.status
````

Which returns a single line of text, like

    Status OK - Clock 2015-08-25T14:21:08.641321+02:00 - Allocated 51,123,436 bytes - 14.63 % free.

We chose to use monit for this purpose.

````bash
sudo apt-get install monit
````

Now copy over the template

````bash
sudo cp ~/pharo-server-tools/monit-service-check.template /etc/monit/conf.d/pharo-http-server
````

Edit the file by replace `user` with your username and restart monit, 
after validating validating the syntax.

````bash
sudo service monit syntax
sudo service monit restart
````

The contents of the service check is pretty simple:

````bash
check process pharo-http-server
    with pidfile "/home/user/pharo/pharo-http-server/run-pharo-http-server.pid"
    start program = "/etc/init.d/pharo-http-server start"
    stop program = "/etc/init.d/pharo-http-server stop"
    if failed url http://localhost:42002/metrics/system.status
       timeout 10 seconds retry 3
       then restart 
````

It says to check the specified URL and restart if there is no successful response to it,
retrying 3 times with a timeout of 10 seconds each time. 

Note how we reuse the init script and the PID file.
When using systemd, you will need to modify the start and stop programs accordingly.

Consult monit’s documentation for more options, like email notifications.


### REPL telnet access to a running image

Although log files are a standard way to learn about a running background process,
it is a very primitive interface. You either log too little or too much. 
Often you would just love to have a look inside your running application.

With NeoConsole’s REPL (read-eval-print-loop) telenet access you can do just that.
In our startup script we started a special, locally bound Telnet server
on port 42001.

````bash
telnet localhost 42001

./repl.sh
````

You can use telnet directly or use the repl.sh script.
Here is a transcript of a session with this tool.

````bash
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Neo Console Pharo4.0 of 18 March 2013 update 40618
> help
help <command>
known commands are:
  describe
  eval DEFAULT
  get
  help
  history
  quit
> get
known metrics:
  system.status - Simple system status
  memory.total - Total allocated memory
  memory.free - Free memory
  system.date - Current date
  system.time - Current time
  system.timestamp - Current timestamp
  process.count - Current process count
  process.list - Current list of processes
  system.version - Image version info
  system.mcversions - Monticello packages version info
> get system.status
  Status OK - Clock 2015-08-25T14:31:07.769294+02:00 - Allocated 55,551,212 bytes - 11.44 % free.
> 123 factorial

12146304367025329675766243241881295855454217088483382315328918161829235892362167668831156960612640202170735835221294047782591091570411651472186029519906261646730733907419814952960000000000000000000000000000
> 0@0 extent: 10@20

(0@0) corner: (10@20)
> =
self: (0@0) corner: (10@20)
class: Rectangle
origin: (0@0)
corner: (10@20)
> quit
Bye!
Connection closed by foreign host.
````

There is an executable script called repl.sh that helps you remember how to connect
to the telnet REPL service.


## Troubleshooting

Carefully read the run/startup script, the init.d script and the service check script.
Path names and port numbers should match.
Double check that the right processes run (`ps auxw | grep pharo`).


## Resources

The following chapter from the 'Enterprise Pharo, a Web prespective' 
treats the same subject: 
[Deploying a Pharo web application in production](http://files.pharo.org/books/enterprisepharo/book/html/DeployForProduction.html)

