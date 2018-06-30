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
mkdir hello
cd hello
vgo mod -init -module example.com/hello
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

# block: vgo get specific version
vgo get github.com/go-chi/chi@v3.3.2
assert "$? -eq 0" $LINENO

# block: vgo build
vgo build
assert "$? -eq 0" $LINENO

# block: check go.mod
cat go.mod

# block: version details
vgo version
echo "vgo commit: $(command cd $(go list -f "{{.Dir}}" golang.org/x/vgo); git rev-parse HEAD)"
