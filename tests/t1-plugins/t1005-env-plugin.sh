#!/usr/bin/env bash

test_description="Env plugin"

. ./setup.sh

DESC="Warn if env file does not exist"
test_expect_success "$DESC" '
	cat > config <<-CONFIG
		middlewares=chapecron::env
		env.file=does-not-exist
	CONFIG

	test_expect_code 78 "$CHAPECRON" -c config -- uname
'

DESC="Warn if env file can not be read"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r test_env_file="$test_root/chapecron.env"

	touch "$test_env_file"
	chmod u-r "$test_env_file"

	cat > config <<-CONFIG
		middlewares=chapecron::env
		env.file="$test_env_file"
	CONFIG

	test_expect_code 78 "$CHAPECRON" -c config -- uname
'

DESC="Default to load ~/.bashrc"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r test_home="$test_root/home/$(whoami)"

	echo "alias kernelname=\"uname -s\"" > "$test_home/.bashrc"

	cat > config <<-CONFIG
		middlewares=chapecron::env
	CONFIG

	test_expect_code 78 "$CHAPECRON" -c config -e "kernelname"
'

DESC="Load the configured env file"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r test_env_file="$test_root/env"

	echo "alias kernelname=\"uname -s\"" > "$test_env_file"

	cat > config <<-CONFIG
		middlewares=chapecron::env
		env.file=$test_env_file
	CONFIG

	test_expect_code 78 "$CHAPECRON" -c config -e "kernelname"
'

test_done
