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
ok  	github.com/gobuffalo/buffalo	0.303s
ok  	github.com/gobuffalo/buffalo/binding	0.108s
?   	github.com/gobuffalo/buffalo/buffalo	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/build	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/destroy	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/generate	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/updater	[no test files]
ok  	github.com/gobuffalo/buffalo/generators	0.049s
ok  	github.com/gobuffalo/buffalo/generators/action	0.048s [no tests to run]
?   	github.com/gobuffalo/buffalo/generators/assets	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/standard	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/webpack	[no test files]
?   	github.com/gobuffalo/buffalo/generators/docker	[no test files]
?   	github.com/gobuffalo/buffalo/generators/grift	[no test files]
?   	github.com/gobuffalo/buffalo/generators/mail	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/newapp	0.086s
?   	github.com/gobuffalo/buffalo/generators/refresh	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/resource	0.081s
?   	github.com/gobuffalo/buffalo/generators/soda	[no test files]
?   	github.com/gobuffalo/buffalo/grifts	[no test files]
ok  	github.com/gobuffalo/buffalo/mail	0.085s
?   	github.com/gobuffalo/buffalo/meta	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware	0.306s
ok  	github.com/gobuffalo/buffalo/middleware/basicauth	0.105s
ok  	github.com/gobuffalo/buffalo/middleware/csrf	0.085s
ok  	github.com/gobuffalo/buffalo/middleware/i18n	0.092s
?   	github.com/gobuffalo/buffalo/middleware/ssl	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware/tokenauth	0.086s
?   	github.com/gobuffalo/buffalo/plugins	[no test files]
ok  	github.com/gobuffalo/buffalo/render	0.065s
ok  	github.com/gobuffalo/buffalo/worker	0.015s
```

Now use go build (or any other go command) to turn dep's Gopkg.lock into a populated go.mod file:

```
$ go build -tags sqlite
go: creating new go.mod: module github.com/gobuffalo/buffalo
go: copying requirements from Gopkg.lock
go: finding github.com/sergi/go-diff v1.0.0
go: finding github.com/gobuffalo/fizz v1.0.11
go: finding github.com/davecgh/go-spew v1.1.1
go: finding github.com/gorilla/sessions v1.1.2
go: finding github.com/shurcooL/go-goon v0.0.0-20170922171312-37c2f522c041
...
$ cat go.mod
module github.com/gobuffalo/buffalo

require (
	dmitri.shuralyov.com/text/kebabcase v0.0.0-20180217051803-40e40b42552a
	github.com/ajg/form v0.0.0-20160822230020-523a5da1a92f
	github.com/cockroachdb/cockroach-go v0.0.0-20180212155653-59c0560478b7
	github.com/davecgh/go-spew v1.1.1
...
```

Run tests to see that baseline behaviour hasn't changed:

```
$ go test -tags sqlite ./...
go: downloading github.com/spf13/cobra v0.0.3
go: downloading github.com/unrolled/secure v0.0.0-20180918153822-f340ee86eb8b
go: downloading github.com/markbates/deplist v1.0.3
go: downloading gopkg.in/mail.v2 v2.0.0-20180301192024-63235f23494b
go: downloading github.com/dgrijalva/jwt-go v3.2.0+incompatible
go: downloading github.com/nicksnyder/go-i18n v1.10.0
go: downloading github.com/markbates/willie v1.0.7
go: downloading github.com/stretchr/testify v1.2.2
go: downloading github.com/ajg/form v0.0.0-20160822230020-523a5da1a92f
go: downloading github.com/markbates/hmax v1.0.0
go: downloading github.com/spf13/pflag v1.0.2
go: downloading github.com/pelletier/go-toml v1.2.0
go: downloading github.com/davecgh/go-spew v1.1.1
go: downloading github.com/pmezard/go-difflib v1.0.0
ok  	github.com/gobuffalo/buffalo	0.216s
ok  	github.com/gobuffalo/buffalo/binding	0.131s
?   	github.com/gobuffalo/buffalo/buffalo	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/build	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/destroy	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/generate	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/updater	[no test files]
ok  	github.com/gobuffalo/buffalo/generators	0.110s
ok  	github.com/gobuffalo/buffalo/generators/action	0.096s [no tests to run]
?   	github.com/gobuffalo/buffalo/generators/assets	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/standard	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/webpack	[no test files]
?   	github.com/gobuffalo/buffalo/generators/docker	[no test files]
?   	github.com/gobuffalo/buffalo/generators/grift	[no test files]
?   	github.com/gobuffalo/buffalo/generators/mail	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/newapp	0.105s
?   	github.com/gobuffalo/buffalo/generators/refresh	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/resource	0.072s
?   	github.com/gobuffalo/buffalo/generators/soda	[no test files]
?   	github.com/gobuffalo/buffalo/grifts	[no test files]
ok  	github.com/gobuffalo/buffalo/mail	0.052s
?   	github.com/gobuffalo/buffalo/meta	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware	0.339s
ok  	github.com/gobuffalo/buffalo/middleware/basicauth	0.129s
ok  	github.com/gobuffalo/buffalo/middleware/csrf	0.108s
ok  	github.com/gobuffalo/buffalo/middleware/i18n	0.061s
?   	github.com/gobuffalo/buffalo/middleware/ssl	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware/tokenauth	0.106s
?   	github.com/gobuffalo/buffalo/plugins	[no test files]
ok  	github.com/gobuffalo/buffalo/render	0.068s
ok  	github.com/gobuffalo/buffalo/worker	0.015s
```

At this point we would now git add go.mod and git commit.

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
