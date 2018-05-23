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
	"rsc.io/quote"
)

func main() {
	fmt.Println(quote.Hello())
}
EOD

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

# block: no rebuild required
vgo build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# block: vgo list -m demo
vgo list -m
assert "$? -eq 0" $LINENO

# block: french hello
LANG=fr ./hello
assert "$? -eq 0" $LINENO

# block: upgrade
vgo list -m -u
assert "$? -eq 0" $LINENO

# block: upgrade text
vgo get golang.org/x/text
assert "$? -eq 0" $LINENO
cat go.mod

# block: check go.mod
vgo list -m
assert "$? -eq 0" $LINENO

# block: vgo test all
vgo test all
assert "$? -eq 0" $LINENO

# block: vgo test quote
vgo test rsc.io/quote/...
assert "$? -eq 1" $LINENO

# block: upgrade all
vgo get -u
assert "$? -eq 0" $LINENO
cat go.mod

# block: test all again
vgo test all
assert "$? -eq 1" $LINENO

# block: bad output
vgo build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

td=$(mktemp -d)
pushd $td > /dev/null
export GOPATH=$PWD

# block: gopath comparison
go get -d rsc.io/hello
assert "$? -eq 0" $LINENO
go build -o badhello rsc.io/hello
assert "$? -eq 0" $LINENO
./badhello
assert "$? -eq 0" $LINENO

popd > /dev/null
export GOPATH=$HOME

# block: list sampler
vgo list -t rsc.io/sampler
assert "$? -eq 0" $LINENO

# block: specific version
cat go.mod
vgo get rsc.io/sampler@v1.3.1
assert "$? -eq 0" $LINENO
vgo list -m
assert "$? -eq 0" $LINENO
cat go.mod
vgo test all
assert "$? -eq 0" $LINENO

# block: downgrade others
vgo get rsc.io/sampler@v1.2.0
assert "$? -eq 0" $LINENO
vgo list -m
assert "$? -eq 0" $LINENO
cat go.mod

# block: remove dependency
vgo get rsc.io/sampler@none
assert "$? -eq 0" $LINENO
vgo list -m
assert "$? -eq 0" $LINENO
cat go.mod
vgo test all
assert "$? -eq 0" $LINENO

# block: back to latest
vgo get -u
assert "$? -eq 0" $LINENO
vgo list -m
assert "$? -eq 0" $LINENO

exclude="exclude \"rsc.io/sampler\" v1.99.99"

# block: show exclude
echo $exclude

# block: apply exclude
echo $exclude >>go.mod
vgo list -t rsc.io/sampler
assert "$? -eq 0" $LINENO
vgo get -u
assert "$? -eq 0" $LINENO
vgo list -m
assert "$? -eq 0" $LINENO
cat go.mod
vgo test all
assert "$? -eq 0" $LINENO

# block: prepare local quote
git clone https://github.com/rsc/quote ../quote

# block: update quote.go
cd ../quote
echo "<edit quote.go>"

sed -i 's/return sampler.Hello()/return sampler.Glass()/' quote.go

replace="replace \"rsc.io/quote\" v1.5.2 => \"../quote\""

# block: show replace
echo $replace

# block: apply replace
cd ../hello
echo $replace >>go.mod
vgo list -m
assert "$? -eq 0" $LINENO
vgo build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# ensure repo exists and clean up any existing tag
ensure_github_repo "vgo-by-example-quote-fork"
assert "$? -eq 0" $LINENO
pushd ../quote > /dev/null
git push -f https://github.com/$GITHUB_USERNAME/vgo-by-example-quote-fork :v0.0.0-myfork
popd > /dev/null

# block: setup our quote
cd ../quote
git commit -a -m 'my fork'
assert "$? -eq 0" $LINENO
git tag v0.0.0-myfork
assert "$? -eq 0" $LINENO
git push https://github.com/$GITHUB_USERNAME/vgo-by-example-quote-fork v0.0.0-myfork
assert "$? -eq 0" $LINENO

# block: use our quote
cd ../hello
echo "replace \"rsc.io/quote\" v1.5.2 => \"github.com/$GITHUB_USERNAME/vgo-by-example-quote-fork\" v0.0.0-myfork" >>go.mod
vgo list -m
assert "$? -eq 0" $LINENO
vgo build
assert "$? -eq 0" $LINENO
LANG=fr ./hello
assert "$? -eq 0" $LINENO

# block: vgo vendor
vgo vendor
assert "$? -eq 0" $LINENO
mkdir -p $GOPATH/src/github.com/you
cp -a . $GOPATH/src/github.com/you/hello
go build -o vhello github.com/you/hello
assert "$? -eq 0" $LINENO
LANG=es ./vhello
assert "$? -eq 0" $LINENO

# block: nm compare
go tool nm hello | grep sampler.hello
assert "$? -eq 0" $LINENO
go tool nm vhello | grep sampler.hello
assert "$? -eq 0" $LINENO
