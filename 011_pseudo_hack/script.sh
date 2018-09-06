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
git config --global push.default current

repoName="go-modules-by-example-pseudo-hack"

# tidy up if we already have the repo
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists $repoName ${repoName}_$now
assert "$? -eq 0" $LINENO
githubcli repo create $repoName
assert "$? -eq 0" $LINENO

# block: setup
mkdir $repoName
cd $repoName
git init -q
assert "$? -eq 0" $LINENO
git remote add origin https://github.com/$GITHUB_USERNAME/$repoName
assert "$? -eq 0" $LINENO

# block: define repo root module
go mod init github.com/$GITHUB_USERNAME/$repoName
assert "$? -eq 0" $LINENO
mkdir pkg
cat <<EOD > pkg/pkg.go
package pkg

const Name = "v1"
EOD
git add *
assert "$? -eq 0" $LINENO
git commit -q -am 'v1 commit'
assert "$? -eq 0" $LINENO
firstcommit="v0.0.0-$(git log -1 --pretty=format:%ad --date=format:%Y%m%d%H%M%S)-$( git log -1 --pretty=format:%H | cut -c1-12)"
git push -q
assert "$? -eq 0" $LINENO

# block: create second commit
cat <<EOD > pkg/pkg.go
package pkg

const Name = "v2"
EOD
assert "$? -eq 0" $LINENO
git add *
assert "$? -eq 0" $LINENO
git commit -q -am 'v2 commit'
assert "$? -eq 0" $LINENO
git push -q
assert "$? -eq 0" $LINENO
git tag $firstcommit
assert "$? -eq 0" $LINENO
git push origin $firstcommit
assert "$? -eq 0" $LINENO

cd $(mktemp -d)
assert "$? -eq 0" $LINENO
go mod init example.com/blah
assert "$? -eq 0" $LINENO
cat <<EOD > main.go
package main

import "fmt"

import "github.com/$GITHUB_USERNAME/$repoName/pkg"

func main () {
	fmt.Println(pkg.Name)
}
EOD
go mod edit -require github.com/$GITHUB_USERNAME/$repoName@$firstcommit
assert "$? -eq 0" $LINENO
cat go.mod
go build
assert "$? -eq 0" $LINENO
./blah
assert "$? -eq 0" $LINENO


# block: version details
go version
