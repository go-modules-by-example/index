<!-- __JSON: egrunner script.sh # LONG ONLINE

### Intro

How do you handle the situation where a library you want to use has moved onto a major version >= 2 but is yet to
migrate to vgo? This guide shows you how, by using [`github.com/labstack/echo`](https://github.com/labstack/echo)
as an example.

A further point to note is that, at the time of writing, https://github.com/labstack/echo tagged their releases
differently after v3.2.1. v3.2.1 was tagged as `v3.2.1`, whereas v3.2.2 was tagged as `3.2.2` (note the missing `v`);
and this new pattern was used for all releases up to and including (at the time of writing) v3.3.5 which was tagged as
`3.3.5`. vgo doesn't recognise these tags (e.g. `3.3.5`) as versions, and hence this guide is written against v3.2.1.

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
$ go get github.com/labstack/echo@v3.2.1
go: finding github.com/labstack/echo v3.2.1
go: downloading github.com/labstack/echo v3.2.1+incompatible
go: finding github.com/labstack/gommon/color latest
go: finding github.com/labstack/gommon/log latest
go: finding github.com/labstack/gommon v0.2.1
go: downloading github.com/labstack/gommon v0.2.1
go: finding golang.org/x/crypto/acme/autocert latest
go: finding golang.org/x/crypto/acme latest
go: finding golang.org/x/crypto latest
go: downloading golang.org/x/crypto v0.0.0-20180904163835-0709b304e793
go: finding github.com/valyala/fasttemplate latest
go: finding github.com/mattn/go-isatty v0.0.4
go: finding github.com/mattn/go-colorable v0.0.9
go: downloading github.com/mattn/go-isatty v0.0.4
go: downloading github.com/mattn/go-colorable v0.0.9
go: downloading github.com/valyala/fasttemplate v0.0.0-20170224212429-dcecefd839c4
go: finding github.com/valyala/bytebufferpool v1.0.0
go: downloading github.com/valyala/bytebufferpool v1.0.0
```

Notice how this actually resolves to a v0.0.0 pseudo-version.

Now as a final step we build to confirm everything works:

```
$ go build
go: finding github.com/dgrijalva/jwt-go v3.2.0+incompatible
go: downloading github.com/dgrijalva/jwt-go v3.2.0+incompatible
go: finding github.com/labstack/echo v3.2.1+incompatible
$ cat go.mod
module example.com/hello

require (
	github.com/dgrijalva/jwt-go v3.2.0+incompatible // indirect
	github.com/labstack/echo v3.2.1+incompatible
	github.com/labstack/gommon v0.2.1 // indirect
	github.com/mattn/go-colorable v0.0.9 // indirect
	github.com/mattn/go-isatty v0.0.4 // indirect
	github.com/valyala/bytebufferpool v1.0.0 // indirect
	github.com/valyala/fasttemplate v0.0.0-20170224212429-dcecefd839c4 // indirect
	golang.org/x/crypto v0.0.0-20180904163835-0709b304e793 // indirect
)
```

Et voila.

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
