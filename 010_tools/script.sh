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

# block: go get vgo
go get -u golang.org/x/vgo
assert "$? -eq 0" $LINENO

# switch to custom vgo commit
if [ "$VGO_VERSION" != "" ]
then
	pushd $(go list -f "{{.Dir}}" golang.org/x/vgo) > /dev/null
	assert "$? -eq 0" $LINENO
	git checkout -q -f $VGO_VERSION
	assert "$? -eq 0" $LINENO
	go install
	assert "$? -eq 0" $LINENO
	popd > /dev/null
	assert "$? -eq 0" $LINENO
fi

# block: setup
mkdir vgo-by-example-tools
cd vgo-by-example-tools
assert "$? -eq 0" $LINENO
vgo mod -init -module github.com/$GITHUB_USERNAME/vgo-by-example-tools
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
vgo install golang.org/x/tools/cmd/stringer
assert "$? -eq 0" $LINENO

# block: check go.mod
cat go.mod
assert "$? -eq 0" $LINENO
vgo list -f "{{.Target}}" golang.org/x/tools/cmd/stringer
assert "$? -eq 0" $LINENO
vgo mod -json
assert "$? -eq 0" $LINENO
vgo mod -sync
assert "$? -eq 0" $LINENO
vgo mod -json
assert "$? -eq 0" $LINENO

# block: version details
vgo version
echo "vgo commit: $(command cd $(go list -f "{{.Dir}}" golang.org/x/vgo); git rev-parse HEAD)"
