<!-- __JSON: egrunner script.sh # LONG ONLINE

## `** REVIEW REQUIRED **`

This guide is a WIP.

----

### Intro

[Buffalo](https://gobuffalo.io/en) is a popular Go web development eco-system, "designed to make the
life of a Go web developer easier." Buffalo uses dep for dependency management. This guide looks at
the steps require to migrate from using dep to go modules. This guide is based on [a PR Russ
opened](https://github.com/gobuffalo/buffalo/pull/1074) against the Buffalo project.

### Getting started

For this guide we will work known commits of Buffalo and dep so the guide remains reproducible. We
will be using:

```
{{PrintBlock "pinned commits" -}}
```

### The migration

Let's perform this migration in a clean GOPATH:

```
{{PrintBlock "setup" -}}
```

Next, let's install dep and ensure we have our desired commit:

```
{{PrintBlock "install dep" -}}
```

Now, establish baseline buffalo behaviour, by using dep ensure and then running tests.

```
{{PrintBlock "baseline" -}}
```

Now use go build (or any other go command) to turn dep's Gopkg.lock into a populated go.mod file:

```
{{lineEllipsis 8 (PrintBlock "go build") -}}
{{lineEllipsis 8 (PrintBlock "cat go.mod") -}}
```

Run tests to see that baseline behaviour hasn't changed:

```
{{PrintBlock "go test" -}}
```

At this point we would now git add go.mod and git commit.

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## `** REVIEW REQUIRED **`

This guide is a WIP.

----

### Intro

[Buffalo](https://gobuffalo.io/en) is a popular Go web development eco-system, "designed to make the
life of a Go web developer easier." Buffalo uses dep for dependency management. This guide looks at
the steps require to migrate from using dep to go modules. This guide is based on [a PR Russ
opened](https://github.com/gobuffalo/buffalo/pull/1074) against the Buffalo project.

### Getting started

For this guide we will work known commits of Buffalo and dep so the guide remains reproducible. We
will be using:

```
$ buffaloCommit=354657dfd81584bb82b8b6dff9bb9f6ab22712a8
$ depCommit=3e697f6afb332b6e12b8b399365e724e2e8dea7e
```

### The migration

Let's perform this migration in a clean GOPATH:

```
$ mkdir /tmp/gopath
$ export GOPATH=/tmp/gopath
$ export PATH=$GOPATH/bin:$PATH
$ cd /tmp/gopath
```

Next, let's install dep and ensure we have our desired commit:

```
$ go get -u github.com/golang/dep/cmd/dep
$ cd src/github.com/golang/dep/cmd/dep
$ git checkout $depCommit
HEAD is now at 3e697f6a... Merge pull request #1832 from rousan/issue-1749-multiple-dir-in-gopath
$ go install
```

Now, establish baseline buffalo behaviour, by using dep ensure and then running tests.

```
$ cd /tmp/gopath
$ go get -tags sqlite github.com/gobuffalo/buffalo
$ cd src/github.com/gobuffalo/buffalo
$ git checkout $buffaloCommit
HEAD is now at 354657d... Updated SHOULDERS.md
$ go get .
$ go install -tags sqlite
$ dep ensure
$ go test -tags sqlite ./...
ok  	github.com/gobuffalo/buffalo	0.271s
ok  	github.com/gobuffalo/buffalo/binding	0.134s
?   	github.com/gobuffalo/buffalo/buffalo	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/build	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/destroy	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/generate	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/updater	[no test files]
ok  	github.com/gobuffalo/buffalo/generators	0.079s
ok  	github.com/gobuffalo/buffalo/generators/action	0.015s [no tests to run]
?   	github.com/gobuffalo/buffalo/generators/assets	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/standard	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/webpack	[no test files]
?   	github.com/gobuffalo/buffalo/generators/docker	[no test files]
?   	github.com/gobuffalo/buffalo/generators/grift	[no test files]
?   	github.com/gobuffalo/buffalo/generators/mail	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/newapp	0.093s
?   	github.com/gobuffalo/buffalo/generators/refresh	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/resource	0.041s
?   	github.com/gobuffalo/buffalo/generators/soda	[no test files]
?   	github.com/gobuffalo/buffalo/grifts	[no test files]
ok  	github.com/gobuffalo/buffalo/mail	0.035s
?   	github.com/gobuffalo/buffalo/meta	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware	0.167s
ok  	github.com/gobuffalo/buffalo/middleware/basicauth	0.101s
ok  	github.com/gobuffalo/buffalo/middleware/csrf	0.088s
ok  	github.com/gobuffalo/buffalo/middleware/i18n	0.128s
?   	github.com/gobuffalo/buffalo/middleware/ssl	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware/tokenauth	0.074s
?   	github.com/gobuffalo/buffalo/plugins	[no test files]
ok  	github.com/gobuffalo/buffalo/render	0.066s
ok  	github.com/gobuffalo/buffalo/worker	0.014s
```

Now use go build (or any other go command) to turn dep's Gopkg.lock into a populated go.mod file:

```
$ go build -tags sqlite
go: creating new go.mod: module github.com/gobuffalo/buffalo
go: copying requirements from Gopkg.lock
go: finding github.com/gobuffalo/packr v1.13.7
go: finding github.com/gorilla/sessions v1.1.3
go: finding github.com/davecgh/go-spew v1.1.1
go: finding github.com/gobuffalo/pop v4.8.3+incompatible
go: finding github.com/markbates/refresh v1.4.10
...
$ cat go.mod
module github.com/gobuffalo/buffalo

require (
	dmitri.shuralyov.com/text/kebabcase v0.0.0-20180217051803-40e40b42552a
	github.com/ajg/form v0.0.0-20160822230020-523a5da1a92f
	github.com/cockroachdb/cockroach-go v0.0.0-20181001143604-e0a95dfd547c
	github.com/davecgh/go-spew v1.1.1
...
```

Run tests to see that baseline behaviour hasn't changed:

```
$ go test -tags sqlite ./...
go: downloading github.com/spf13/cobra v0.0.3
go: downloading github.com/nicksnyder/go-i18n v1.10.0
go: downloading github.com/unrolled/secure v0.0.0-20181005190816-ff9db2ff917f
go: downloading github.com/markbates/deplist v1.0.5
go: downloading github.com/markbates/willie v1.0.9
go: downloading github.com/dgrijalva/jwt-go v3.2.0+incompatible
go: downloading gopkg.in/mail.v2 v2.0.0-20180731213649-a0242b2233b4
go: downloading golang.org/x/tools v0.0.0-20181010000725-29f11e2b93f4
go: downloading github.com/markbates/hmax v1.0.0
go: downloading github.com/ajg/form v0.0.0-20160822230020-523a5da1a92f
go: downloading github.com/stretchr/testify v1.2.2
go: downloading github.com/pelletier/go-toml v1.2.0
go: downloading github.com/spf13/pflag v1.0.3
go: downloading github.com/pmezard/go-difflib v1.0.0
go: downloading github.com/davecgh/go-spew v1.1.1
ok  	github.com/gobuffalo/buffalo	0.324s
ok  	github.com/gobuffalo/buffalo/binding	0.088s
?   	github.com/gobuffalo/buffalo/buffalo	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/build	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/destroy	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/generate	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/updater	[no test files]
ok  	github.com/gobuffalo/buffalo/generators	0.121s
ok  	github.com/gobuffalo/buffalo/generators/action	0.080s [no tests to run]
?   	github.com/gobuffalo/buffalo/generators/assets	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/standard	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/webpack	[no test files]
?   	github.com/gobuffalo/buffalo/generators/docker	[no test files]
?   	github.com/gobuffalo/buffalo/generators/grift	[no test files]
?   	github.com/gobuffalo/buffalo/generators/mail	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/newapp	0.154s
?   	github.com/gobuffalo/buffalo/generators/refresh	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/resource	0.201s
?   	github.com/gobuffalo/buffalo/generators/soda	[no test files]
?   	github.com/gobuffalo/buffalo/grifts	[no test files]
ok  	github.com/gobuffalo/buffalo/mail	0.062s
?   	github.com/gobuffalo/buffalo/meta	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware	0.248s
ok  	github.com/gobuffalo/buffalo/middleware/basicauth	0.118s
ok  	github.com/gobuffalo/buffalo/middleware/csrf	0.100s
ok  	github.com/gobuffalo/buffalo/middleware/i18n	0.068s
?   	github.com/gobuffalo/buffalo/middleware/ssl	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware/tokenauth	0.091s
?   	github.com/gobuffalo/buffalo/plugins	[no test files]
ok  	github.com/gobuffalo/buffalo/render	0.058s
ok  	github.com/gobuffalo/buffalo/worker	0.019s
```

At this point we would now git add go.mod and git commit.

### Version details

```
go version go1.11.1 linux/amd64
```

<!-- END -->
