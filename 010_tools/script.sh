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
git config --global push.default current

# block: setup
pwd
ls
mkdir go-modules-by-example-tools
assert "$? -eq 0" $LINENO
cd go-modules-by-example-tools
assert "$? -eq 0" $LINENO
go mod init github.com/$GITHUB_USERNAME/go-modules-by-example-tools
assert "$? -eq 0" $LINENO

# block: set bin target
export GOBIN=$PWD/bin

# block: add tool dependency
cat <<EOD > tools.go
// +build tools

package tools

import (
        _ "golang.org/x/tools/cmd/stringer"
)
EOD
go install golang.org/x/tools/cmd/stringer
assert "$? -eq 0" $LINENO

# block: check go.mod
cat go.mod
assert "$? -eq 0" $LINENO
go list -f "{{.Target}}" golang.org/x/tools/cmd/stringer
assert "$? -eq 0" $LINENO
go mod edit -json
assert "$? -eq 0" $LINENO
go mod tidy
assert "$? -eq 0" $LINENO
go mod edit -json
assert "$? -eq 0" $LINENO

# block: version details
go version
