<!-- __JSON: egrunner script.sh # LONG ONLINE

### Introduction

How do you handle the situation where a package (project) has a version number `>= 2` but has not yet been converted to
a Go module?

_Add more detail/intro here_

### Walkthrough

Start by getting `vgo` in the usual way:

```
{{PrintBlock "go get vgo" -}}
```

Create a module using the `github.com/go-chi/chi` [example](https://github.com/go-chi/chi/tree/cca4135d8dddff765463feaf1118047a9e506b4a#examples):


```
{{PrintBlock "setup" -}}
```

Mark this as a module by creating a `go.mod`:


```
{{PrintBlock "mark as go module" -}}
```

Now because, at the time of writing, `github.com/go-chi/chi`:

* has a major version `>= 2`
* has not been converted to a Go (vgo) module
* we want to use v3.3.2

we need to `vgo get` that specific version, which will be retrieved as a v0.0.0 psuedo version:


```
{{PrintBlock "vgo get specific version" -}}
```

Now do a build to check all is good:


```
{{PrintBlock "vgo build" -}}
```

And check the contents of `go.mod`:

```
{{PrintBlock "check go.mod" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

### Introduction

How do you handle the situation where a package (project) has a version number `>= 2` but has not yet been converted to
a Go module?

_Add more detail/intro here_

### Walkthrough

Start by getting `vgo` in the usual way:

```
$ go get -u golang.org/x/vgo
```

Create a module using the `github.com/go-chi/chi` [example](https://github.com/go-chi/chi/tree/cca4135d8dddff765463feaf1118047a9e506b4a#examples):


```
$ mkdir hello
$ cd hello
$ cat <<EOD >hello.go
package main // import "example.com/hello"

import (
        "net/http"
        "github.com/go-chi/chi"
)

func main() {
        r := chi.NewRouter()
        r.Get("/", func(w http.ResponseWriter, r *http.Request) {
                w.Write([]byte("welcome"))
        })
        http.ListenAndServe(":3000", r)
}
EOD
```

Mark this as a module by creating a `go.mod`:


```
$ echo >go.mod
```

Now because, at the time of writing, `github.com/go-chi/chi`:

* has a major version `>= 2`
* has not been converted to a Go (vgo) module
* we want to use v3.3.2

we need to `vgo get` that specific version, which will be retrieved as a v0.0.0 psuedo version:


```
$ vgo get github.com/go-chi/chi@v3.3.2
vgo: finding github.com/go-chi/chi v0.0.0-20171222161133-e83ac2304db3
vgo: downloading github.com/go-chi/chi v0.0.0-20171222161133-e83ac2304db3
```

Now do a build to check all is good:


```
$ vgo build
```

And check the contents of `go.mod`:

```
$ cat go.mod
module example.com/hello

require github.com/go-chi/chi v0.0.0-20171222161133-e83ac2304db3
```

### Version details

```
go version go1.10.2 linux/amd64 vgo:2018-02-20.1
vgo commit: 7c0cf33f39ccf5d8e4c59d34a150425ddac7df6a
```

<!-- END -->
