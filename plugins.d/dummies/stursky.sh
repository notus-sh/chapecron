#!/usr/bin/env bash

chapecron::stursky() {
	context::export
	bash -c "chapecron -r"
	return $?
}
