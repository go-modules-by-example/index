#!/usr/bin/env bash

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
cd $(mktemp -d)
mkdir hello
cd hello
go mod init github.com/you/hello

cat <<EOD > hello.go
package main

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

# block: cat hello.go
cat hello.go

# block: initial go build
go build
./hello

# block: cat go.mod initial
cat go.mod

cat <<EOD > hello.go
package main

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

# block: cat hello.go v2
cat hello.go

# block: go build v2
go build
./hello

# block: cat go.mod v2
cat go.mod

# block: version details
go version
