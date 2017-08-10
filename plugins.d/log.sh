#!/bin/env bash

chapecron::log() {
	stack::next | tee "${CONFIG['log.path']}"
}
