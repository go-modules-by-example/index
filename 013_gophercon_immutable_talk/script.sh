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

# block: simple example part 1
mkdir /tmp/hello
cd /tmp/hello
go mod init github.com/myitcv/hello
assert "$? -eq 0" $LINENO
ls
cat go.mod
export GOBIN=$PWD/.bin
export PATH=$PWD/.bin:$PATH
export GOPROXY=file:///cache

go install myitcv.io/immutable/cmd/immutableGen
assert "$? -eq 0" $LINENO

mkdir goodprint
pushd goodprint
cat <<EOD > main.go
package main

import "fmt"

// HERE

func PrintMap(m map[string]int) {
  for k, v := range m {
    fmt.Printf("k = %v; v = %v\n", k, v)
  }
}

func main() {
  m := map[string]int{"hello": 5, "world": 10}
  fmt.Printf("map has len %v\n", len(m))
  PrintMap(m)
  fmt.Printf("map has len %v\n", len(m))
}
EOD

gofmt -w main.go

# block: goodprint
cat main.go

# block: run goodprint
go run main.go

popd
mkdir badprint
pushd badprint

cat <<EOD > main.go
package main

import "fmt"

// HERE

func PrintMap(m map[string]int) {
  for k, v := range m {
    fmt.Printf("k = %v; v = %v\n", k, v)
  }
  m["bad"] = 42
}

func main() {
  m := map[string]int{"hello": 5, "world": 10}
  fmt.Printf("map has len %v\n", len(m))
  PrintMap(m)
  fmt.Printf("map has len %v\n", len(m))
}
EOD

gofmt -w main.go

# block: badprint
cat main.go

# block: run badprint
go run main.go

popd

mkdir immprint
pushd immprint

cat <<EOD >> main.go
package main

import "fmt"

// 1
//go:generate immutableGen

type _Imm_myMap map[string]int
// 2
func PrintMap(m *myMap) {
  for k, v := range m.Range() {
    fmt.Printf("k = %v; v = %v\n", k, v)
  }
  m.Set("bad", 42)
}
// 3
func main() {
  m := newMyMap(func(m *myMap) {
m.Set("hello", 5)
m.Set("world", 10)
})
  fmt.Printf("map has len %v\n", m.Len())
  PrintMap(m)
  fmt.Printf("map has len %v\n", m.Len())
}
// 4
EOD
gofmt -w main.go

# block: immprint type
cat main.go

# block: immprint gogenerate
go generate
ls

# block: immprint run
go run *.go
assert "$? -eq 0" $LINENO

popd
