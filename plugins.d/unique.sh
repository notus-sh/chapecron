#!/usr/bin/env bash

chapecron::unique() {
	local pid_file="" pattern=""
	local -i lock_descriptor=0

	pid_file="/tmp/chapecron-$(echo -n "$COMMAND" | sha1sum | awk '{print $1}').pid"
	log::debug "PID file stored at $pid_file"

	lock_descriptor=$(utils::fd)
	log::debug "Lock file descriptor: $lock_descriptor"

	eval "exec $lock_descriptor> $pid_file"

	flock --exclusive --nonblock $lock_descriptor || \
		utils::fail $EX_TEMPFAIL \
								"Another instance of this command already exists"

	eval "echo $$ >&$lock_descriptor"
	stack::next
}
