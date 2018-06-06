#!/usr/bin/env bash

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
	cat <<EOD | curl -s -H "Content-Type: application/json" --request POST -d @- https://api.github.com/user/repos > /dev/null
{
  "name": "$1"
}
EOD

	curl -s -H "Content-Type: application/json" https://api.github.com/repos/$GITHUB_USERNAME/$1 | grep -q '"id"'
}

# **START**

export GOPATH=$HOME
export PATH=$GOPATH/bin:$PATH
echo "machine github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
echo "" >> $HOME/.netrc
echo "machine api.github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
git config --global user.email "$GITHUB_USERNAME@example.com"
git config --global user.name "$GITHUB_USERNAME"
git config --global advice.detachedHead false

# block: go get vgo
go get -u golang.org/x/vgo
assert "$? -eq 0" $LINENO

# block: setup
mkdir hello
cd hello
cat <<EOD > hello.go
package main // import "example.com/hello"

import (
	"fmt"
	"rsc.io/quote"
)

func main() {
   fmt.Println(quote.Hello())
}
EOD
echo > go.mod
vgo build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO
cat go.mod


# block: add tools dep
cat <<EOD >> go.mod

require golang.org/x/tools v0.0.0-20180525024113-a5b4c53f6e8b
EOD
vgo install golang.org/x/tools/cmd/stringer
assert "$? -eq 0" $LINENO

# block: check
cat go.mod
vgo build
assert "$? -eq 0" $LINENO


# block: vendor
vgo vendor
assert "$? -eq 0" $LINENO
cat vendor/vgo.list
find vendor -type d


# block: version details
vgo version
echo "vgo commit: $(command cd $(go list -f "{{.Dir}}" golang.org/x/vgo); git rev-parse HEAD)"
