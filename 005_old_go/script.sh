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

# block: use backport
cd /tmp
git clone -q https://github.com/golang/go
cd go/src
git checkout -q 28ae82663a1c57c185312b60a2eae8cf06cc24b4
./make.bash
assert "$? -eq 0" $LINENO
export PATH=/tmp/go/bin:$PATH
which go
go version

# block: go get vgo
go get -u golang.org/x/vgo
assert "$? -eq 0" $LINENO

# block: setup
mkdir /tmp/old-go-compat
cd /tmp/old-go-compat
export GOPATH=$PWD
mkdir -p src/example.com/hello
cd src/example.com/hello
cat <<EOD > hello.go
package main // import "example.com/hello"

import (
	"fmt"
	"github.com/myitcv/vgo_example_compat/v2"
	"github.com/myitcv/vgo_example_compat/v2/sub"
)

func main() {
	fmt.Println(vgo_example_compat.X, sub.Y)
}
EOD
echo > go.mod
vgo build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# block: failed go get v2
go get github.com/myitcv/vgo_example_compat/v2
assert "$? -eq 1" $LINENO

# block: successful go get
go get github.com/myitcv/vgo_example_compat
assert "$? -eq 0" $LINENO

# block: successful go build
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# block: failed go list v2
go list github.com/myitcv/vgo_example_compat/v2
assert "$? -eq 1" $LINENO

# block: successful go list
go list github.com/myitcv/vgo_example_compat
assert "$? -eq 0" $LINENO

# block: setup go/build test
cat <<EOD > run.go
// +build ignore

package main

import (
	"fmt"
	"os"
	"go/build"
)

func main() {
	bpkg, err := build.Import(os.Args[1], ".", 0)
	if err != nil {
		panic(err)
	}
	fmt.Printf("%v\n", bpkg.Dir)
}
EOD

# block: failed go run v2
go run run.go github.com/myitcv/vgo_example_compat/v2
assert "$? -eq 1" $LINENO

# block: successful go run
go run run.go github.com/myitcv/vgo_example_compat
assert "$? -eq 0" $LINENO

