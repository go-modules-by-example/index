<!-- __JSON: egrunner script.sh # LONG ONLINE

### Intro

[Buffalo](https://gobuffalo.io/en) is a popular Go web development eco-system, "designed to make the
life of a Go web developer easier." Buffalo uses dep for dependency management. This guide looks at
the steps require to migrate from using dep to vgo. This guide is based on [a PR Russ
opened](https://github.com/gobuffalo/buffalo/pull/1074) against the Buffalo project.

### Getting started

As ever, start by ensuring vgo is installed and up to date:

```
{{PrintBlock "go get vgo" -}}
```

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

Now use vgo build (or any other vgo command) to turn dep's Gopkg.lock into a populated go.mod file:

```
{{lineEllipsis (PrintBlock "vgo build") 8 -}}
{{lineEllipsis (PrintBlock "cat go.mod") 8 -}}
```

Run tests to see that baseline behaviour hasn't changed:

```
{{PrintBlock "vgo test" -}}
```

At this point we would now git add go.mod and git commit.

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

### Intro

[Buffalo](https://gobuffalo.io/en) is a popular Go web development eco-system, "designed to make the
life of a Go web developer easier." Buffalo uses dep for dependency management. This guide looks at
the steps require to migrate from using dep to vgo. This guide is based on [a PR Russ
opened](https://github.com/gobuffalo/buffalo/pull/1074) against the Buffalo project.

### Getting started

As ever, start by ensuring vgo is installed and up to date:

```
$ go get -u golang.org/x/vgo
```

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
ok  	github.com/gobuffalo/buffalo	0.220s
ok  	github.com/gobuffalo/buffalo/binding	0.066s
?   	github.com/gobuffalo/buffalo/buffalo	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/build	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/destroy	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/generate	[no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/updater	[no test files]
ok  	github.com/gobuffalo/buffalo/generators	0.026s
ok  	github.com/gobuffalo/buffalo/generators/action	0.049s [no tests to run]
?   	github.com/gobuffalo/buffalo/generators/assets	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/standard	[no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/webpack	[no test files]
?   	github.com/gobuffalo/buffalo/generators/docker	[no test files]
?   	github.com/gobuffalo/buffalo/generators/grift	[no test files]
?   	github.com/gobuffalo/buffalo/generators/mail	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/newapp	0.036s
?   	github.com/gobuffalo/buffalo/generators/refresh	[no test files]
ok  	github.com/gobuffalo/buffalo/generators/resource	0.023s
?   	github.com/gobuffalo/buffalo/generators/soda	[no test files]
?   	github.com/gobuffalo/buffalo/grifts	[no test files]
ok  	github.com/gobuffalo/buffalo/mail	0.076s
?   	github.com/gobuffalo/buffalo/meta	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware	0.163s
ok  	github.com/gobuffalo/buffalo/middleware/basicauth	0.030s
ok  	github.com/gobuffalo/buffalo/middleware/csrf	0.028s
ok  	github.com/gobuffalo/buffalo/middleware/i18n	0.054s
?   	github.com/gobuffalo/buffalo/middleware/ssl	[no test files]
ok  	github.com/gobuffalo/buffalo/middleware/tokenauth	0.060s
?   	github.com/gobuffalo/buffalo/plugins	[no test files]
ok  	github.com/gobuffalo/buffalo/render	0.041s
ok  	github.com/gobuffalo/buffalo/worker	0.014s
```

Now use vgo build (or any other vgo command) to turn dep's Gopkg.lock into a populated go.mod file:

```
$ vgo build -tags sqlite
vgo: creating new go.mod: module github.com/gobuffalo/buffalo
vgo: copying requirements from /tmp/gopath/src/github.com/gobuffalo/buffalo/Gopkg.lock
vgo: finding github.com/gobuffalo/makr v1.1.0
vgo: finding golang.org/x/sys v0.0.0-20180616030259-6c888cc515d3
vgo: finding github.com/dgrijalva/jwt-go v0.0.0-20180308231308-06ea1031745c
vgo: finding google.golang.org/appengine v1.1.0
vgo: finding github.com/monoculum/formam v0.0.0-20170619223434-99ca9dcbaca6
...
$ cat go.mod
module github.com/gobuffalo/buffalo

require (
	github.com/ajg/form v0.0.0-20160802194845-cc2954064ec9
	github.com/dgrijalva/jwt-go v0.0.0-20180308231308-06ea1031745c
	github.com/dustin/go-humanize v0.0.0-20180421182945-02af3965c54e
	github.com/fatih/color v1.7.0
...
```

Run tests to see that baseline behaviour hasn't changed:

```
$ vgo test -tags sqlite ./...
vgo: downloading github.com/markbates/willie v0.0.0-20180320154129-67934945178e
vgo: downloading github.com/ajg/form v0.0.0-20160802194845-cc2954064ec9
vgo: downloading github.com/markbates/hmax v0.0.0-20170213234856-800e180dcd16
vgo: downloading github.com/stretchr/testify v1.2.2
vgo: downloading github.com/davecgh/go-spew v1.1.0
vgo: downloading github.com/pmezard/go-difflib v1.0.0
vgo: downloading github.com/spf13/cobra v0.0.3
vgo: downloading github.com/spf13/pflag v1.0.1
vgo: downloading github.com/markbates/deplist v0.0.0-20170926152145-5ae023fef618
vgo: downloading gopkg.in/mail.v2 v2.0.0-20180301192024-63235f23494b
vgo: downloading github.com/nicksnyder/go-i18n v1.10.0
vgo: downloading github.com/pelletier/go-toml v1.2.0
vgo: downloading github.com/unrolled/secure v0.0.0-20180416205222-a1cf62cc2159
vgo: downloading github.com/dgrijalva/jwt-go v0.0.0-20180308231308-06ea1031745c
ok  	github.com/gobuffalo/buffalo	0.252s
ok  	github.com/gobuffalo/buffalo/binding	0.044s
?   	github.com/gobuffalo/buffalo/buffalo	0.024s [no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd	0.098s [no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/build	0.044s [no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/destroy	0.039s [no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/generate	0.134s [no test files]
?   	github.com/gobuffalo/buffalo/buffalo/cmd/updater	0.040s [no test files]
ok  	github.com/gobuffalo/buffalo/generators	0.076s
ok  	github.com/gobuffalo/buffalo/generators/action	0.066s [no tests to run]
?   	github.com/gobuffalo/buffalo/generators/assets	0.003s [no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/standard	0.049s [no test files]
?   	github.com/gobuffalo/buffalo/generators/assets/webpack	0.069s [no test files]
?   	github.com/gobuffalo/buffalo/generators/docker	0.042s [no test files]
?   	github.com/gobuffalo/buffalo/generators/grift	0.021s [no test files]
?   	github.com/gobuffalo/buffalo/generators/mail	0.042s [no test files]
ok  	github.com/gobuffalo/buffalo/generators/newapp	0.065s
?   	github.com/gobuffalo/buffalo/generators/refresh	0.036s [no test files]
ok  	github.com/gobuffalo/buffalo/generators/resource	0.035s
?   	github.com/gobuffalo/buffalo/generators/soda	0.072s [no test files]
?   	github.com/gobuffalo/buffalo/grifts	0.019s [no test files]
ok  	github.com/gobuffalo/buffalo/mail	0.045s
?   	github.com/gobuffalo/buffalo/meta	0.015s [no test files]
ok  	github.com/gobuffalo/buffalo/middleware	0.150s
ok  	github.com/gobuffalo/buffalo/middleware/basicauth	0.071s
ok  	github.com/gobuffalo/buffalo/middleware/csrf	0.086s
ok  	github.com/gobuffalo/buffalo/middleware/i18n	0.057s
?   	github.com/gobuffalo/buffalo/middleware/ssl	0.064s [no test files]
ok  	github.com/gobuffalo/buffalo/middleware/tokenauth	0.062s
?   	github.com/gobuffalo/buffalo/plugins	0.029s [no test files]
ok  	github.com/gobuffalo/buffalo/render	0.039s
ok  	github.com/gobuffalo/buffalo/worker	0.014s
```

At this point we would now git add go.mod and git commit.

### Version details

```
go version go1.10.3 linux/amd64 vgo:2018-02-20.1
vgo commit: 22e23900224f03be49670113d5781e4d89090f45
```

<!-- END -->
