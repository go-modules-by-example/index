#!/usr/bin/env bash

# **START**

export GOPATH=$HOME
export PATH=$GOPATH/bin:$PATH
echo "machine github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
echo "" >> $HOME/.netrc
echo "machine api.github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
git config --global user.email "$GITHUB_USERNAME@github.com"
git config --global user.name "$GITHUB_USERNAME"
git config --global advice.detachedHead false
git config --global push.default current

apt-get update > /dev/null 2>&1
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common > /dev/null 2>&1
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - > /dev/null 2>&1
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /dev/null 2>&1
apt-get update > /dev/null 2>&1
apt-get install -y docker-ce > /dev/null 2>&1

# block: docker pull
docker pull golang

# block: clone
git clone https://github.com/go-modules-by-example/index
cd index

# block: go install
go install myitcv.io/cmd/{mdreplace,egrunner,githubcli}

egrun="egrunner -df -v=/tmp:/tmp -out std ./000_simple_example/script.sh"

# block: echo egrun
echo "\$ $(echo $egrun | sed -e 's+ -df -v=/tmp:/tmp++')"

# block: egrun
$egrun | head -n -1

# block: mdrun
mdreplace -w -long -online ./000_simple_example/README.md
