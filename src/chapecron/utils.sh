#!/bin/bash

utils::fail() {
	if [ $# -eq 2 ]; then
		echo $2 > 2
	fi
	exit $1
}

utils::check_getopt() {
  local _return
  
  set +e
  getopt --test > /dev/null
  _return=$?
  set -e
  
  if [[ $_return -ne 4 ]]
  then
    return 1
  fi
  return 0
}

