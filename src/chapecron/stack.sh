#!/bin/bash

# Stack management
declare -a STACK
declare -i STACK_COUNTER=0

stack::add() {
	export STACK+=($@)
}

stack::next() {
	local NEXT_COMMAND=${STACK[$STACK_COUNTER]}
	export STACK_COUNTER+=1
	$NEXT_COMMAND
}

stack::run() {
	export STACK_COUNTER=0
	stack::next
}
