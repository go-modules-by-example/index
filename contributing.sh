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

# block: docker pull
docker pull golang

# block: clone
git clone https://github.com/go-modules-by-example/index
cd index

# behind the scenes we switch to self in order that we
# utilise the current version, not the latest remote commit
cd /self

export egrun="gobin -m -run myitcv.io/cmd/egrunner -df -v=/tmp:/tmp -out std ./000_simple_example/script.sh"

# block: echo egrun
echo "\$ $(echo $egrun | sed -e 's+ -df -v=/tmp:/tmp++')"

# egrunner_envsubst: +egrun

# block: egrun
$egrun | head -n -1

# block: mdrun
gobin -m -run myitcv.io/cmd/mdreplace -w -long -online ./000_simple_example/README.md
