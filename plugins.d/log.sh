#!/bin/env bash

chapecron::log() {
	[ ${CONFIG['log.path']+isset} ] || \
		utils::fail $EX_CONFIG \
								"Missing configuration: log.path"

	utils::debug "Command's output will be copied to ${CONFIG['log.path']}"
	stack::next | tee --append "${CONFIG['log.path']}"
}
