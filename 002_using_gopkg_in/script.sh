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

# block: version details
vgo version
echo "vgo commit: $(command cd $(go list -f "{{.Dir}}" golang.org/x/vgo); git rev-parse HEAD)"
