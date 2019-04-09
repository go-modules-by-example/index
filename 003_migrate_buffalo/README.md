<!-- __JSON: gobin -m -run myitcv.io/cmd/egrunner script.sh # LONG ONLINE

### Intro

[Buffalo](https://gobuffalo.io/en) is a popular Go web development eco-system, "designed to make the life of a Go web
developer easier." Before switching to Go modules, Buffalo used [`dep`](https://github.com/golang/dep) for dependency
management.

This guide looks at the steps that were required to migrate from `dep` to Go modules and is based on [a PR Russ Cox
opened](https://github.com/gobuffalo/buffalo/pull/1074) against the Buffalo project. Note the `go` tool understands a
[number of different dependency management formats](https://golang.org/pkg/cmd/go/internal/modconv/?m=all#pkg-variables)
including Glide and Godeps; the steps for migrating from these will be similar.

The results of this migration can be found at {{PrintOut "repo" -}}.

### Getting started

We will use known commits of Buffalo and `dep` so the guide remains reproducible:

```
{{PrintBlock "pinned commits" -}}
```

### The migration

Let's perform this migration in a clean `GOPATH` (remember, Buffalo is not yet a module for the purposes of this guide).
We also update our `PATH` to make it easier to run `dep`.

```
{{PrintBlock "setup" -}}
```

Get `dep` and ensure we have our desired commit installed:

```
{{PrintBlock "install dep" -}}
```

Get Buffalo at the desired commit:

```
{{PrintBlock "get buffalo" -}}
```

Verify that Buffalo's tests pass by using `dep ensure` and then running tests.

```
{{PrintBlock "baseline" -}}
```

Up until this point we have been working in ["`GOPATH`
mode"](https://golang.org/cmd/go/#hdr-Preliminary_module_support). Because we are working inside `GOPATH` we need to
explicitly switch to "module-aware mode" to perform any module operations:

```
{{PrintBlock "set GO111MODULE" -}}
```

Initialise our module (see the [wiki for more
details](https://github.com/golang/go/wiki/Modules)):

```
{{lineEllipsis 8 (PrintBlock "go mod init") -}}
```

Tidy for good measure:

```
{{lineEllipsis 8 (PrintBlock "go mod tidy") -}}
```

Verify that our `go.mod` has been populated with dependencies:

```
{{lineEllipsis 8 (PrintBlock "cat go.mod") -}}
```

Run tests to confirm that behaviour hasn't changed:

```
{{PrintBlock "go test" -}}
```

Remove the now redundant `vendor` directory and `Gopkg.toml`, commit and push:

```
{{PrintBlock "commit" -}}
```

If you want to retain `vendor`, see ["Using modules to manage
vendor"](../008_vendor_example/README.md) for more details.

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

### Intro

[Buffalo](https://gobuffalo.io/en) is a popular Go web development eco-system, "designed to make the life of a Go web
developer easier." Before switching to Go modules, Buffalo used [`dep`](https://github.com/golang/dep) for dependency
management.

This guide looks at the steps that were required to migrate from `dep` to Go modules and is based on [a PR Russ Cox
opened](https://github.com/gobuffalo/buffalo/pull/1074) against the Buffalo project. Note the `go` tool understands a
[number of different dependency management formats](https://golang.org/pkg/cmd/go/internal/modconv/?m=all#pkg-variables)
including Glide and Godeps; the steps for migrating from these will be similar.

The results of this migration can be found at https://github.com/go-modules-by-example/buffalo.

### Getting started

We will use known commits of Buffalo and `dep` so the guide remains reproducible:

```
$ buffaloCommit=354657dfd81584bb82b8b6dff9bb9f6ab22712a8
$ depCommit=3e697f6afb332b6e12b8b399365e724e2e8dea7e
```

### The migration

Let's perform this migration in a clean `GOPATH` (remember, Buffalo is not yet a module for the purposes of this guide).
We also update our `PATH` to make it easier to run `dep`.

```
$ export GOPATH=$(mktemp -d)
$ export PATH=$GOPATH/bin:$PATH
$ cd $GOPATH
```

Get `dep` and ensure we have our desired commit installed:

```
$ go get -u github.com/golang/dep/cmd/dep
$ cd src/github.com/golang/dep/cmd/dep
$ git checkout $depCommit
HEAD is now at 3e697f6a... Merge pull request #1832 from rousan/issue-1749-multiple-dir-in-gopath
$ go install
```

Get Buffalo at the desired commit:

```
$ cd $GOPATH
$ go get -tags sqlite github.com/gobuffalo/buffalo
$ cd src/github.com/gobuffalo/buffalo
$ git checkout $buffaloCommit
HEAD is now at 354657d... Updated SHOULDERS.md
$ go get .
```

Verify that Buffalo's tests pass by using `dep ensure` and then running tests.

```
$ dep ensure
$ go test -tags sqlite ./...
ok  	github.com/gobuffalo/buffalo	0.110s
ok  	github.com/gobuffalo/buffalo/binding	0.063s
?   	github.com/gobuffalo/buffalo/buffalo	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/build	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/destroy	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/generate	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/updater	[no test files]
ok  	github.com/gobuffalo/buffalo/generators	0.004s
ok  	github.com/gobuffalo/buffalo/generators/action	0.005s [no tests to run]
?   	github.com/gobuffalo/buffalo/generators/assets	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/standard	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/webpack	[no test files]
?   	github.com/gobuffalo/buffalo/generators/docker	[no test files]
?   	github.com/gobuffalo/buffalo/generators/grift	[no test files]
?   	github.com/gobuffalo/buffalo/generators/mail	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/newapp	1.253s
?   	github.com/gobuffalo/buffalo/generators/refresh	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/resource	0.005s
?   	github.com/gobuffalo/buffalo/generators/soda	[no test files]
?   	github.com/gobuffalo/buffalo/grifts	[no test files]
ok  	github.com/gobuffalo/buffalo/mail	0.026s
?   	github.com/gobuffalo/buffalo/meta	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware	0.162s
ok  	github.com/gobuffalo/buffalo/middleware/basicauth	0.021s
ok  	github.com/gobuffalo/buffalo/middleware/csrf	0.031s
ok  	github.com/gobuffalo/buffalo/middleware/i18n	0.030s
?   	github.com/gobuffalo/buffalo/middleware/ssl	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware/tokenauth	0.042s
?   	github.com/gobuffalo/buffalo/plugins	[no test files]
ok  	github.com/gobuffalo/buffalo/render	0.033s
ok  	github.com/gobuffalo/buffalo/worker	0.015s
```

Up until this point we have been working in ["`GOPATH`
mode"](https://golang.org/cmd/go/#hdr-Preliminary_module_support). Because we are working inside `GOPATH` we need to
explicitly switch to "module-aware mode" to perform any module operations:

```
$ export GO111MODULE=on
```

Initialise our module (see the [wiki for more
details](https://github.com/golang/go/wiki/Modules)):

```
$ go mod init
go: creating new go.mod: module github.com/gobuffalo/buffalo
go: copying requirements from Gopkg.lock
```

Tidy for good measure:

```
$ go mod tidy
go: finding github.com/gobuffalo/genny v0.0.0-20190403191548-3ca520ef0d9e
go: finding github.com/pkg/errors v0.8.1
go: finding github.com/gobuffalo/flect v0.1.1
go: finding github.com/gorilla/context v1.1.1
go: finding github.com/gofrs/uuid v3.2.0+incompatible
go: finding github.com/shurcooL/highlight_diff v0.0.0-20181222201841-111da2e7d480
go: finding github.com/rogpeppe/go-internal v1.3.0
...
```

Verify that our `go.mod` has been populated with dependencies:

```
$ cat go.mod
module github.com/gobuffalo/buffalo

go 1.12

require (
	github.com/ajg/form v1.5.1 // indirect
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
...
```

Run tests to confirm that behaviour hasn't changed:

```
$ go test -tags sqlite ./...
ok  	github.com/gobuffalo/buffalo	0.207s
ok  	github.com/gobuffalo/buffalo/binding	0.023s
?   	github.com/gobuffalo/buffalo/buffalo	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/build	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/destroy	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/generate	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/updater	[no test files]
ok  	github.com/gobuffalo/buffalo/generators	0.029s
ok  	github.com/gobuffalo/buffalo/generators/action	0.029s [no tests to run]
?   	github.com/gobuffalo/buffalo/generators/assets	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/standard	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/webpack	[no test files]
?   	github.com/gobuffalo/buffalo/generators/docker	[no test files]
?   	github.com/gobuffalo/buffalo/generators/grift	[no test files]
?   	github.com/gobuffalo/buffalo/generators/mail	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/newapp	1.442s
?   	github.com/gobuffalo/buffalo/generators/refresh	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/resource	0.014s
?   	github.com/gobuffalo/buffalo/generators/soda	[no test files]
?   	github.com/gobuffalo/buffalo/grifts	[no test files]
ok  	github.com/gobuffalo/buffalo/mail	0.039s
?   	github.com/gobuffalo/buffalo/meta	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware	0.178s
ok  	github.com/gobuffalo/buffalo/middleware/basicauth	0.044s
ok  	github.com/gobuffalo/buffalo/middleware/csrf	0.014s
ok  	github.com/gobuffalo/buffalo/middleware/i18n	0.023s
?   	github.com/gobuffalo/buffalo/middleware/ssl	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware/tokenauth	0.034s
?   	github.com/gobuffalo/buffalo/plugins	[no test files]
ok  	github.com/gobuffalo/buffalo/render	0.024s
ok  	github.com/gobuffalo/buffalo/worker	0.015s
```

Remove the now redundant `vendor` directory and `Gopkg.toml`, commit and push:

```
$ rm -rf vendor Gopkg.toml
$ git remote add go-modules-by-example https://github.com/go-modules-by-example/buffalo
$ git checkout -q -b migrate_buffalo
$ git add go.mod go.sum
$ git commit -am 'Convert to a Go module'
[migrate_buffalo 0c29937] Convert to a Go module
 14 files changed, 769 insertions(+), 5648 deletions(-)
 delete mode 100644 Gopkg.toml
 create mode 100644 go.mod
 create mode 100644 go.sum
 delete mode 100644 vendor/github.com/russross/blackfriday/.gitignore
 delete mode 100644 vendor/github.com/russross/blackfriday/.travis.yml
 delete mode 100644 vendor/github.com/russross/blackfriday/LICENSE.txt
 delete mode 100644 vendor/github.com/russross/blackfriday/README.md
 delete mode 100644 vendor/github.com/russross/blackfriday/block.go
 delete mode 100644 vendor/github.com/russross/blackfriday/doc.go
 delete mode 100644 vendor/github.com/russross/blackfriday/html.go
 delete mode 100644 vendor/github.com/russross/blackfriday/inline.go
 delete mode 100644 vendor/github.com/russross/blackfriday/latex.go
 delete mode 100644 vendor/github.com/russross/blackfriday/markdown.go
 delete mode 100644 vendor/github.com/russross/blackfriday/smartypants.go
$ git push -q go-modules-by-example
```

If you want to retain `vendor`, see ["Using modules to manage
vendor"](../008_vendor_example/README.md) for more details.

### Version details

```
go version go1.12.3 linux/amd64
```

<!-- END -->
