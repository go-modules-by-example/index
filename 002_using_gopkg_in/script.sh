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

# block: go get vgo
go get -u golang.org/x/vgo
assert "$? -eq 0" $LINENO

# block: setup
cd $HOME
mkdir hello
cd hello

cat <<EOD > hello.go
package main // import "github.com/you/hello"

import (
	"fmt"
	"log"
	"gopkg.in/yaml.v1"
)

type T struct {
    F int "a,omitempty"
    B int
}

func main() {
	t := &T{F: 1}
	out, err := yaml.Marshal(t)
	if err != nil {
		log.Fatalf("cannot marshal %#v: %v", t, err)
	}
	fmt.Printf("we got %q\n", out)
}
EOD
gofmt -w hello.go
assert "$? -eq 0" $LINENO

# block: cat hello.go
cat hello.go

# block: initial vgo build
echo >go.mod
vgo build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# block: cat go.mod initial
cat go.mod

cat <<EOD > hello.go
package main // import "github.com/you/hello"

import (
	"fmt"
	"log"
	"gopkg.in/yaml.v2"
)

type T struct {
    F int "a,omitempty"
    B int
}

func main() {
	t := &T{F: 1}
	out, err := yaml.Marshal(t)
	if err != nil {
		log.Fatalf("cannot marshal %#v: %v", t, err)
	}
	fmt.Printf("we got %q\n", out)
}
EOD
gofmt -w hello.go
assert "$? -eq 0" $LINENO

# block: cat hello.go v2
cat hello.go

# block: vgo build v2
vgo build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# block: cat go.mod v2
cat go.mod
