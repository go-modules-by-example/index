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

# block: pinned commits
buffaloCommit=354657dfd81584bb82b8b6dff9bb9f6ab22712a8
depCommit=3e697f6afb332b6e12b8b399365e724e2e8dea7e

# block: buffalo commit
echo $buffaloCommit

# block: dep commit
echo $depCommit

echo "machine github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
echo "" >> $HOME/.netrc
echo "machine api.github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
git config --global user.email "$GITHUB_USERNAME@example.com"
git config --global user.name "$GITHUB_USERNAME"
git config --global advice.detachedHead false

# block: setup
mkdir /tmp/gopath
export GOPATH=/tmp/gopath
export PATH=$GOPATH/bin:$PATH
cd /tmp/gopath

# we intentionally have the vgo install step after
# so vgo is in our temp path

# block: go get vgo
go get -u golang.org/x/vgo
assert "$? -eq 0" $LINENO

# block: install dep
go get -u github.com/golang/dep/cmd/dep
assert "$? -eq 0" $LINENO
cd src/github.com/golang/dep/cmd/dep
git checkout $depCommit
assert "$? -eq 0" $LINENO
go install
assert "$? -eq 0" $LINENO

# block: baseline
cd /tmp/gopath
go get -tags sqlite github.com/gobuffalo/buffalo
assert "$? -eq 0" $LINENO
cd src/github.com/gobuffalo/buffalo
git checkout $buffaloCommit
assert "$? -eq 0" $LINENO
go get .
assert "$? -eq 0" $LINENO
go install -tags sqlite
assert "$? -eq 0" $LINENO
dep ensure
assert "$? -eq 0" $LINENO
go test -tags sqlite ./...
assert "$? -eq 0" $LINENO

# block: vgo build
vgo build -tags sqlite
assert "$? -eq 0" $LINENO

# block: cat go.mod
cat go.mod

# block: vgo test
vgo test -tags sqlite ./...
assert "$? -eq 0" $LINENO

# block: version details
vgo version
echo "vgo commit: $(command cd $(go list -f "{{.Dir}}" golang.org/x/vgo); git rev-parse HEAD)"
