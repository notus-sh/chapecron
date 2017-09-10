#!/usr/bin/env bash

chapecron::env() {
	local env_file="$(utils::home)/.bashrc"
	[ ${CONFIG['env.file']+isset} ] && env_file="${CONFIG['env.file']}"

	[ -z "$env_file" ] || \
		utils::fail $EX_CONFIG \
								"Missing configuration: env.file"

	[ ! -f "$env_file" ] || \
		utils::fail $EX_CONFIG \
								"Wrong configuration: specified env.file does not exist"

	[ ! -r "$env_file" ] || \
		utils::fail $EX_CONFIG \
								"Wrong configuration: specified env.file can not be read"

	source $env_file >/dev/null 2>&1
	stack::next
}
