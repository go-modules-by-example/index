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
cat <<EOD > hello.go
package main // import "example.com/hello"

import (
        "fmt"

        "rsc.io/pdf"
)

func main() {
        fmt.Println(pdf.Point{})
}
EOD
echo > go.mod

# block: go get pdf
go get rsc.io/pdf@v0.1.1
cat go.mod

# block: go build
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# block: replace pdf
git clone https://github.com/rsc/pdf pdf
cd pdf
git checkout v0.1.1
cd ..
cat <<EOD >> go.mod
replace rsc.io/pdf v0.1.1 => ./pdf
EOD
cat go.mod

# block: go build fails
go build
assert "$? -eq 1" $LINENO

# block: create pdf module
cd pdf
cat <<EOD > go.mod
module rsc.io/pdf
EOD
cd ..

# block: go build check
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO


# block: version details
go version
