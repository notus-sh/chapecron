# Chapecron

[![Build Status](https://travis-ci.org/notus-sh/chapecron.svg?branch=master)](https://travis-ci.org/notus-sh/chapecron)

`chapecron` is a shell script to help control and monitor cron jobs.

## Why `chapecron`?

Cron automatically emails the output of a cron job to the user, to warn him when a problem occurs.
As usefull as it sounds, cron considers any output as an error and it can be difficult to write cron jobs that output nothing but real errors.
It also ignores command result codes, so a quiet programs can fail without being noticed.

To not be bothered by tons of useless emails, most people do things like this:  
_(or don't configure anything else than the default local mailboxes)_

```
# Chances are it will be too late when you discover this doesn't work
0 1 * * * backup > /dev/null 2>&1
# This way you can have a look from time to time. Or post-mortem…
0 2 * * * /home/username/bin/another_important_script with some arguments > /home/username/logs/backup.log 2>&1
```

The base feature of `chapecron` is to wrap cron jobs so they won't output anything except when an error occured.
Thus, cron will only send you an email when something bad really happened.
(Something bad is defined as any non-trace error output or a non-zero result code.)

That's what `chapecron` will do without any configuration or arguments other than a command to look after.
But honestly, if you only want to do this you'd better use [`cronic`](http://habilis.net/cronic/).

What makes `chapecron` different is an extensible set of pluggable middlewares that can be used to control and monitor your cron jobs' execution.

## Installation

`chapecron` comes with a Makefile to install and uninstall it.

```
git clone https://github.com/notus-sh/chapecron.git chapecron && cd chapecron
make install
```

This will install `chapecron` to its default locations:

* Main script and plugins to `/usr/local/lib/chapecron`
* Sample configuration at `/etc/chapecron/chapecron.conf`
* Main script linked to `/usr/local/bin/chapecron` to be (hopefully) available in your $PATH

The Makefile is aware of the following environment variables:

```
DESTDIR   default:
PREFIX    default: /usr/local
CONFDIR   default: $(DESTDIR)/etc/chapecron
BINDIR    default: $(DESTDIR)$(PREFIX)/bin
LIBDIR    default: $(DESTDIR)$(PREFIX)/lib/chapecron
```


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

As the whole point of `chapecron` is to be a silent supervisor for your cron jobs, verbosity options only exists to ease debugging a configuration.

### Examples

```
chapecron -c ~/chapecron.conf -- backup
chapecron -- /home/username/bin/my_other_backup_script with some arguments
```

## Configuration

`chapecron` configuration files are as simple as a bunch of `key=value`.

```
middlewares=chapecron::timeout chapecron::log
# Log plugin
log.path=/home/username/logs/crons.log
# Timeout plugin
timeout.duration=10s
```

[The file `chapecron.conf`](https://github.com/notus-sh/chapecron/blob/master/chapecron.conf) gives a sample configuration for all currently available plugins.

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
* `chapecron::nice`  
  Run your scripts with a niceness adjustment

### Write your own

Every `.sh` scripts located in `{installation directory}/plugins.d/` will be loaded as a potential plugin.
Every function declared in these scripts is usable as a middleware.

A `chapecron` middleware is just a Bash function so you can easily write your own and add them to the stack.

To be a gentle citizen, a middleware has only two responsability:

* Invoke the lower one in the stack.
* Return its exit status to the upper one, or a meaningfull return code if something wrong happened.

Invoking the next middleware in the stack can be done in two different ways.
The easiest is to call `stack::next` when you need but this will not work if the next middleware is to be called in a subshell.

Monitoring tools as `timeout` or `time`, for example, tend to encapsulate the command they will look after in a subshell.
That means you can't use the `stack::next` function as the newly created shell will know nothing about the context of its parent, except what has been exported.

To work around this, you can call `context::export` in your middleware function and replace the `stack::next` call by `chapecron -r`.
This way, `chapecron` will reinvoke itself and be able to restore the saved context and continue its job.

Have a look at the sources of existing plugins for more examples.  
If you write a usefull plugin, please consider opening a pull request :)

## Alternatives

* [`cronic`](http://habilis.net/cronic/)  
  Simple and lightweight Bash wrapper to keep your cron jobs quiet between two failures.
* [`cronwrap`](https://github.com/Doist/cronwrap)  
  Cron wrapper written in Python. Supports timeout and custom email recipients.
* [`croncape`](https://github.com/sensiocloud/croncape)  
  cronwrap equivalent in Go, with some refinements.
* [`cronutils`](https://github.com/google/cronutils)  
  Collection of small utilities written in C to assist running batch jobs. Supports timeout, unique jobs and some kind of stats.
* [`Cronwrap`](http://www.uow.edu.au/~sah/cronwrap.html)  
  Job wrapper written in C. Supports logging, timeout and custom email formatting.  
	**Does not seem to be maintained anymore.**
* [`shush`](http://web.taranis.org/shush/)
  More complex job wrapper written in C. Supports multiple reports, system logging, timeout, unique jobs and more.  
	**Does not seem to be maintained anymore.**

## Acknowledgment

`chapecron` initiated as a fork of [`cronic`](http://habilis.net/cronic/) by Chuck Houpt (and inherited its license).  
Changes made to the original script can be seen by comparing the `cronic` and `master` branches of this repo.
