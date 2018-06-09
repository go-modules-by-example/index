<!-- __JSON: egrunner script.sh # LONG ONLINE

### Intro

How do you handle the situation where a library you want to use has moved onto a major version >= 2 but is yet to
migrate to vgo? This guide shows you how, by using [`github.com/labstack/echo`](https://github.com/labstack/echo)
as an example.

A further point to note is that, at the time of writing, https://github.com/labstack/echo tagged their releases
differently after v3.2.1. v3.2.1 was tagged as `v3.2.1`, whereas v3.2.2 was tagged as `3.2.2` (note the missing `v`);
and this new pattern was used for all releases up to and including (at the time of writing) v3.3.5 which was tagged as
`3.3.5`. vgo doesn't recognise these tags (e.g. `3.3.5`) as versions, and hence this guide is written against v3.2.1.

### Getting started

As ever, start by ensuring vgo is installed and up to date:

```
{{PrintBlock "go get vgo" -}}
```

### A simple example

We will use a simple example [taken from the package
README](https://github.com/labstack/echo/tree/d36ff729613dd8e825455c504bea0586c43ac03d#example) for this guide. We start
by creating a new directory for our example:

```
{{PrintBlock "step 0" -}}
```

Next we write out the example and create an empty go.mod file to mark this as a vgo module:

```
{{PrintBlock "step 1" -}}
```

Now, we explicitly add `github.com/labstack/echo@v3.2.1` as a requirement:

```
{{PrintBlock "step 2" -}}
```

Notice how this actually resolves to a v0.0.0 pseudo-version.

Now as a final step we build to confirm everything works:

```
{{PrintBlock "step 3" -}}
```

Et voila.

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

### Intro

How do you handle the situation where a library you want to use has moved onto a major version >= 2 but is yet to
migrate to vgo? This guide shows you how, by using [`github.com/labstack/echo`](https://github.com/labstack/echo)
as an example.

A further point to note is that, at the time of writing, https://github.com/labstack/echo tagged their releases
differently after v3.2.1. v3.2.1 was tagged as `v3.2.1`, whereas v3.2.2 was tagged as `3.2.2` (note the missing `v`);
and this new pattern was used for all releases up to and including (at the time of writing) v3.3.5 which was tagged as
`3.3.5`. vgo doesn't recognise these tags (e.g. `3.3.5`) as versions, and hence this guide is written against v3.2.1.

### Getting started

As ever, start by ensuring vgo is installed and up to date:

```
$ go get -u golang.org/x/vgo
```

### A simple example

We will use a simple example [taken from the package
README](https://github.com/labstack/echo/tree/d36ff729613dd8e825455c504bea0586c43ac03d#example) for this guide. We start
by creating a new directory for our example:

```
$ mkdir hello
$ cd hello
```

Next we write out the example and create an empty go.mod file to mark this as a vgo module:

```
$ cat <<EOD >main.go
package main // import "example.com/hello"

import (
	"net/http"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

func main() {
	// Echo instance
	e := echo.New()

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	// Routes
	e.GET("/", hello)

	// Start server
	e.Logger.Fatal(e.Start(":1323"))
}

// Handler
func hello(c echo.Context) error {
	return c.String(http.StatusOK, "Hello, World!")
}
EOD
$ echo >go.mod
```

Now, we explicitly add `github.com/labstack/echo@v3.2.1` as a requirement:

```
$ vgo get github.com/labstack/echo@v3.2.1
vgo: finding github.com/labstack/echo v0.0.0-20170621150743-935a60782cbb
vgo: finding golang.org/x/sys v0.0.0-20170529185110-b90f89a1e7a9
vgo: finding golang.org/x/crypto v0.0.0-20170601173114-e1a4589e7d3e
vgo: finding github.com/valyala/fasttemplate v0.0.0-20170224212429-dcecefd839c4
vgo: finding github.com/valyala/bytebufferpool v0.0.0-20160817181652-e746df99fe4a
vgo: finding github.com/stretchr/testify v1.1.4
vgo: finding github.com/stretchr/objx v0.0.0-20140526180921-cbeaeb16a013
vgo: finding github.com/pmezard/go-difflib v0.0.0-20151028094244-d8ed2627bdf0
vgo: finding github.com/davecgh/go-spew v0.0.0-20160907170601-6d212800a42e
vgo: finding github.com/pmezard/go-difflib v1.0.0
vgo: finding github.com/mattn/go-isatty v0.0.2
vgo: finding github.com/mattn/go-colorable v0.0.7
vgo: finding github.com/labstack/gommon v0.2.1
vgo: finding golang.org/x/sys v0.0.0-20160916181909-8f0908ab3b24
vgo: finding github.com/valyala/fasttemplate v0.0.0-20160315193134-3b874956e03f
vgo: finding github.com/mattn/go-isatty v0.0.0-20160806122752-66b8e73f3f5c
vgo: finding github.com/mattn/go-colorable v0.0.0-20160731235417-ed8eb9e318d7
vgo: finding github.com/dgrijalva/jwt-go v0.0.0-20160616191556-d2709f9f1f31
vgo: finding github.com/davecgh/go-spew v1.1.0
vgo: downloading github.com/labstack/echo v0.0.0-20170621150743-935a60782cbb
vgo: downloading github.com/labstack/gommon v0.2.1
vgo: downloading github.com/mattn/go-colorable v0.0.7
vgo: downloading github.com/mattn/go-isatty v0.0.2
vgo: downloading github.com/valyala/fasttemplate v0.0.0-20170224212429-dcecefd839c4
vgo: downloading github.com/valyala/bytebufferpool v0.0.0-20160817181652-e746df99fe4a
vgo: downloading golang.org/x/crypto v0.0.0-20170601173114-e1a4589e7d3e
vgo: downloading github.com/dgrijalva/jwt-go v0.0.0-20160616191556-d2709f9f1f31
```

Notice how this actually resolves to a v0.0.0 pseudo-version.

Now as a final step we build to confirm everything works:

```
$ vgo build
$ cat go.mod
module example.com/hello

require github.com/labstack/echo v0.0.0-20170621150743-935a60782cbb
```

Et voila.

### Version details

```
go version go1.10.3 linux/amd64 vgo:2018-02-20.1
vgo commit: 203abfb0741bf96c7c5e8dab019f6fe9c89bded3
```

<!-- END -->
