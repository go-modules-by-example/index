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

# tidy up if we already have the repo
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists vgo-by-example-submodules vgo-by-example-submodules_$now
assert "$? -eq 0" $LINENO
githubcli repo create vgo-by-example-submodules
assert "$? -eq 0" $LINENO

# block: setup
mkdir vgo-by-example-submodules
cd vgo-by-example-submodules
git init
assert "$? -eq 0" $LINENO
git remote add origin https://github.com/$GITHUB_USERNAME/vgo-by-example-submodules
assert "$? -eq 0" $LINENO

# block: define repo root module
cat <<EOD > go.mod
module github.com/$GITHUB_USERNAME/vgo-by-example-submodules
EOD
git add go.mod
assert "$? -eq 0" $LINENO
git commit -am 'Initial commit'
assert "$? -eq 0" $LINENO
git push
assert "$? -eq 0" $LINENO

# block: create package b
mkdir b
cd b
cat <<EOD > b.go
package b // import "github.com/$GITHUB_USERNAME/vgo-by-example-submodules/b"

const Name = "Gopher"
EOD
echo >go.mod
vgo test
assert "$? -eq 0" $LINENO

# block: commit and tag b
cd ..
git add b
assert "$? -eq 0" $LINENO
git commit -am 'Add package b'
assert "$? -eq 0" $LINENO
git push
assert "$? -eq 0" $LINENO
git tag b/v0.1.1
assert "$? -eq 0" $LINENO
git push origin b/v0.1.1
assert "$? -eq 0" $LINENO

# block: create package a
mkdir a
cd a
cat <<EOD > .gitignore
/a
EOD
cat <<EOD > a.go
package main // import "github.com/$GITHUB_USERNAME/vgo-by-example-submodules/a"

import (
	"github.com/$GITHUB_USERNAME/vgo-by-example-submodules/b"
	"fmt"
)

const Name = b.Name

func main() {
	fmt.Println(Name)
}
EOD
echo >go.mod

# block: run package a
vgo build
assert "$? -eq 0" $LINENO
./a
cat go.mod

# block: commit and tag a
cd ..
git add a
assert "$? -eq 0" $LINENO
git commit -am 'Add package a'
assert "$? -eq 0" $LINENO
git push
assert "$? -eq 0" $LINENO
git tag a/v1.0.0
assert "$? -eq 0" $LINENO
git push origin a/v1.0.0
assert "$? -eq 0" $LINENO

# block: version details
vgo version
echo "vgo commit: $(command cd $(go list -f "{{.Dir}}" golang.org/x/vgo); git rev-parse HEAD)"
