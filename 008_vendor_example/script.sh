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

# **START**

export GOPATH=$HOME
export PATH=$GOPATH/bin:$PATH
echo "machine github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
echo "" >> $HOME/.netrc
echo "machine api.github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
git config --global user.email "$GITHUB_USERNAME@example.com"
git config --global user.name "$GITHUB_USERNAME"
git config --global advice.detachedHead false

# block: setup
mkdir hello
cd hello
cat <<EOD > hello.go
package main

import (
	"fmt"
	"rsc.io/quote"
)

func main() {
   fmt.Println(quote.Hello())
}
EOD
go mod init example.com/hello
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO
cat go.mod


# block: add tools dep
cat <<EOD >> go.mod

require golang.org/x/tools v0.0.0-20180525024113-a5b4c53f6e8b
EOD
go install golang.org/x/tools/cmd/stringer
assert "$? -eq 0" $LINENO

# block: check
cat go.mod
go build
assert "$? -eq 0" $LINENO


# block: vendor
go mod vendor
assert "$? -eq 0" $LINENO
cat vendor/modules.txt
assert "$? -eq 0" $LINENO
find vendor -type d
assert "$? -eq 0" $LINENO

# block: version details
go version
