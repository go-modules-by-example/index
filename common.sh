#!/usr/bin/env bash

# this is a useful pre-amble to put in a script to help with testing via docker
# run directly

set -u
set -x

assert()
{
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99

  if [ -z "$2" ]
  then
    exit $E_PARAM_ERR
  fi

  lineno=$2

  if [ ! $1 ]
  then
    echo "Assertion failed:  \"$1\""
    echo "File \"$0\", line $lineno"
    exit $E_ASSERT_FAILED
  fi
}

ensure_github_repo()
{
	# TODO improve this
	cat <<EOD | curl -s -H "Content-Type: application/json" -u $GITHUB_USERNAME:$GITHUB_PAT --request POST -d @- https://api.github.com/user/repos > /dev/null
{
  "name": "$1"
}
EOD

	curl -s -H "Content-Type: application/json" -u $GITHUB_USERNAME:$GITHUB_PAT https://api.github.com/repos/$GITHUB_USERNAME/$1 | grep -q '"id"'
}

# START
