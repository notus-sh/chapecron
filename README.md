# Chapecron

`chapecron` is a shell script to help control and monitor cron jobs.

## Why `chapecron`?

Cron automatically emails the output of a cron job to the user, to warn him when a problem occurs.
As usefull as it sounds, cron consider any output as an error and it can be difficult to write cron jobs that outputs nothing but real errors.
It also ignores command result codes, so a quiet programs can fail without being noticed.

To not be bothered by tons of useless emails, the typical solution is to hide everything and hope scripts will run smoothly.

```
# Chances are it will be too late when you discover this doesn't work
0 1 * * * backup > /dev/null 2>&1
# This way you can have a look from time to time. Or post-mortem…
0 2 * * * /home/username/bin/another_important_script with some arguments > /home/username/logs/backup.log 2>&1
```

The base feature of `chapecron` is to wrap cron jobs so they won't output anything except when an error occured.
Thus, cron will only send you an email when something bad really happened.
(Something bad is defined as any non-trace error output or a non-zero result code.)

That's what `chapecron` will do without any configuration or arguments other than a command to monitor.
But honestly, if you only want to do this you'd better use [`cronic`](http://habilis.net/cronic/).

What makes `chapecron` different is an extensible set of pluggable middlewares that can be used to control and monitor your cron jobs' execution.

## Usage

```
chapecron OPTIONS -- COMMAND
```

Note that the `--` is **required**.

Supported options:

* `-c` or `--config`: Specify a configuration file (See Configuration below)
* `--version`: Display version informations and exit
* `-h` or `--help`: Display usage instructions and exit
* `-v` or `--verbose`: Increase verbosity. Can be used up to two times

### Examples

```
chapecron -c ~/chapecron.conf -- backup
chapecron -c ~/chapecron.conf -- /home/username/bin/my_other_backup_script with some arguments
```

## Configuration

`chapecron` configuration files are as simple as a bunch of `key=value`.
Here is an example of what can be a configuration file to use all currently available plugins:

```
# Core configuration
middlewares=chapecron::timeout chapecron::time chapecron::log

# Log plugin
log.path=/home/username/logs/crons.log

# Time plugin
time.format=Real: %e - Kernel: %S - User: %U - Inputs: %I - Outputs: %O
time.path=/home/username/logs/cron-times.log

# Timeout plugin
timeout.duration=10s
# timeout.signal=9
# timeout.kill=2s
```

When you specify a configuration file as a command line option, only this file will be loaded.
If you don't, `chapecron` will automatically look for configuration files at:

* `/etc/chapecron/chapecron.conf`
* `$XDG_CONFIG_HOME/chapecron/chapecron.conf` (defaults to `~/.config/chapecron/chapecron.conf`)

System-wide configuration can thus be overriden at a user level and you can use command line option `-c` only for really specific settings around a single job.

Middleware lists from system and user configuration files will be merged and deduped at loading.
Only one instance of a each declared middleware will be added to the stack.

## Plugins

### Available plugins

* `chapecron::log`  
  Want to cron a script that output important status informations but neither want to read them every morning nor to feed /dev/null with them? This plugin will copy the standard output of your script to a designated log file.
* `chapecron::time`  
  Keep trace of your scripts' CPU and memory usage or anything that can be mesured by [GNU time](https://www.gnu.org/software/time/)
* `chapecron::timeout`  
  Ensure your scripts will not run forever

### Write your own

Every `.sh` scripts located in `{installation directory}/plugins.d/` will be loaded as a potential plugin.
Every function declared in these scripts is usable as a middleware.

A `chapecron` middleware is just a Bash function so you can easily write your own and add them to the stack.

To be a gentle citizen, a middleware has only two responsability:

* Invoke the lower one in the stack
* Return its exit status to the upper one, or a meaningfull return code if something wrong happened in it

Invoking the next middleware in the stack can be done in two different ways.
The easiest is to call `stack::next` when you need but this will not work if the next middleware is to be called in a subshell.

Monitoring tools as `timeout` or `time`, for example, tend to encapsulate the command they will look after in a subshell.
That means you can't use the `stack::next` function as the newly created shell will know nothing about the context of its parent, except what has been exported.

To workaround this, you can call `context::export` in your middleware function and replace the `stack::next` call by `chapecron -r`.
This way, `chapecron` will reinvoke itself and be able to restaure the saved context and continue its job.

Have a look at the sources of existing plugins for more examples and if you write a usefull plugins, please consider opening a pull request :)

## Acknowledgment

`chapecron` initiated as a fork of [`cronic`](http://habilis.net/cronic/) by Chuck Houpt (and inherited its license).
Changes made to the original script can be seen by comparing the `cronic` and `master` branches of this repo.
