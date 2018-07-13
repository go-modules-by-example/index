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
go mod init example.com/hello
cat <<EOD > hello.go
package main

import (
        "net/http"
        "github.com/go-chi/chi"
)

func main() {
        r := chi.NewRouter()
        r.Get("/", func(w http.ResponseWriter, r *http.Request) {
                w.Write([]byte("welcome"))
        })
        http.ListenAndServe(":3000", r)
}
EOD

# block: go get specific version
go get github.com/go-chi/chi@v3.3.2
assert "$? -eq 0" $LINENO

# block: go build
go build
assert "$? -eq 0" $LINENO

# block: check go.mod
cat go.mod

# block: version details
go version
