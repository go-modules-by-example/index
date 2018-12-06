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
git config --global push.default current

mkdir $HOME/scratchpad

now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists $GITHUB_ORG/specialapi specialapi_$now
githubcli repo transfer $GITHUB_ORG/specialapi_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/specialapi

cd $(mktemp -d)
git init
git remote add origin https://github.com/$GITHUB_ORG/specialapi
go mod init github.com/$GITHUB_ORG/specialapi
cat <<EOD > specialapi.go
package specialapi

const Number = 42

const RandomNumber = 4

func Name() string {
	return "Rob Pike"
}
EOD
gofmt -w specialapi.go
git add -A
git commit -am 'v1.0.0'
git push
git tag v1.0.0
git push origin v1.0.0
cat <<EOD > specialapi.go
package specialapi

const Number = "42"

const RandomNumber = 6

func FullName() string {
	return "Rob Pike"
}
EOD
gofmt -w specialapi.go
git add -A
git commit -am 'v2.0.0'
git push
git tag v2.0.0
git push origin v2.0.0

#########################

comment
comment "====================="
comment

# block: apidiff repo
echo https://github.com/$GITHUB_ORG/apidiff

# block: specialapi repo
echo https://github.com/$GITHUB_ORG/specialapi

# block: specialapi package
echo github.com/$GITHUB_ORG/specialapi

# block: setup
cd $HOME/scratchpad
git clone -q --branch v1.0.0 https://github.com/$GITHUB_ORG/specialapi specialapi_v1.0.0
git clone -q --branch v2.0.0 https://github.com/$GITHUB_ORG/specialapi specialapi_v2.0.0

# block: v1.0.0
catfile specialapi_v1.0.0/specialapi.go

# block: v2.0.0
catfile specialapi_v2.0.0/specialapi.go

# block: install apidiff
gobin golang.org/x/exp/cmd/apidiff

# block: changes
apidiff ./specialapi_v1.0.0 ./specialapi_v2.0.0

# block: help
apidiff -help
assert "$? -eq 2" $LINENO

# block: version details
go version
gobin -v golang.org/x/exp/cmd/apidiff
