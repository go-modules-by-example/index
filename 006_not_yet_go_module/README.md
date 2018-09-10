<!-- __JSON: egrunner script.sh # LONG ONLINE

## `** REVIEW REQUIRED **`

This guide is a WIP.

----

### Introduction

How do you handle the situation where a package (project) has a version number `>= 2` but has not yet been converted to
a Go module?

_Add more detail/intro here_

### Walkthrough

Create a module using the `github.com/go-chi/chi` [example](https://github.com/go-chi/chi/tree/cca4135d8dddff765463feaf1118047a9e506b4a#examples):

```
{{PrintBlock "setup" -}}
```

Now because, at the time of writing, `github.com/go-chi/chi`:

* has a major version `>= 2`
* has not been converted to a Go module
* we want to use v3.3.2

we need to `go get` that specific version, which will be retrieved as a v0.0.0 psuedo version:


```
{{PrintBlock "go get specific version" -}}
```

Now do a build to check all is good:


```
{{PrintBlock "go build" -}}
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

## `** REVIEW REQUIRED **`

This guide is a WIP.

----

### Introduction

How do you handle the situation where a package (project) has a version number `>= 2` but has not yet been converted to
a Go module?

_Add more detail/intro here_

### Walkthrough

Create a module using the `github.com/go-chi/chi` [example](https://github.com/go-chi/chi/tree/cca4135d8dddff765463feaf1118047a9e506b4a#examples):

```
$ mkdir hello
$ cd hello
$ go mod init example.com/hello
go: creating new go.mod: module example.com/hello
$ cat <<EOD >hello.go
package main

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

Now because, at the time of writing, `github.com/go-chi/chi`:

* has a major version `>= 2`
* has not been converted to a Go module
* we want to use v3.3.2

we need to `go get` that specific version, which will be retrieved as a v0.0.0 psuedo version:


```
$ go get github.com/go-chi/chi@v3.3.2
go: finding github.com/go-chi/chi v3.3.2
go: downloading github.com/go-chi/chi v3.3.2+incompatible
```

Now do a build to check all is good:


```
$ go build
go: finding github.com/go-chi/chi v3.3.2+incompatible
```

And check the contents of `go.mod`:

```
$ cat go.mod
module example.com/hello

require github.com/go-chi/chi v3.3.2+incompatible
```

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
