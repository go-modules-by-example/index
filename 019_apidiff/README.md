<!-- __JSON: gobin -m -run myitcv.io/cmd/egrunner script.sh # LONG ONLINE

## Using `apidiff` to determine API compatibility

Very often when working on a library we make changes and are faced with the question: what has changed between two
versions of a package (or module of packages)? Have we only made backwards compatible changes?

This guide makes use of the [`apidiff` command](https://godoc.org/golang.org/x/exp/cmd/apidiff), a light wrapper around
[the `apidiff` package](https://godoc.org/golang.org/x/exp/apidiff), to analyse the changes between two versions of the
[`{{PrintOut "specialapi package"}}`]({{PrintOut "specialapi repo"}}) package.

Ultimately this guide will be entirely replaced by a guide that covers `go release`, where it is expected `apidiff` (the
library) will principally be used.

### Walk-through

Setup ready to analyse the differences between the two versions of `{{PrintOut "specialapi package"}}`:

```
{{PrintBlock "setup" -}}
```

`v1.0.0` look like:

```go
{{PrintBlockOut "v1.0.0" -}}
```

`v2.0.0` look like:

```go
{{PrintBlockOut "v2.0.0" -}}
```

Use `apidiff` to summarise the changes:

```
{{PrintBlock "changes" -}}
```

See the usage for more information:

```
{{PrintBlock "help" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Using `apidiff` to determine API compatibility

Very often when working on a library we make changes and are faced with the question: what has changed between two
versions of a package (or module of packages)? Have we only made backwards compatible changes?

This guide makes use of the [`apidiff` command](https://godoc.org/golang.org/x/exp/cmd/apidiff), a light wrapper around
[the `apidiff` package](https://godoc.org/golang.org/x/exp/apidiff), to analyse the changes between two versions of the
[`github.com/go-modules-by-example/specialapi`](https://github.com/go-modules-by-example/specialapi) package.

Ultimately this guide will be entirely replaced by a guide that covers `go release`, where it is expected `apidiff` (the
library) will principally be used.

### Walk-through

Setup ready to analyse the differences between the two versions of `github.com/go-modules-by-example/specialapi`:

```
$ cd /home/gopher/scratchpad
$ git clone -q --branch v1.0.0 https://github.com/go-modules-by-example/specialapi specialapi_v1.0.0
$ git clone -q --branch v2.0.0 https://github.com/go-modules-by-example/specialapi specialapi_v2.0.0
```

`v1.0.0` look like:

```go
$ cat specialapi_v1.0.0/specialapi.go
package specialapi

const Number = 42

const RandomNumber = 4

func Name() string {
	return "Rob Pike"
}
```

`v2.0.0` look like:

```go
$ cat specialapi_v2.0.0/specialapi.go
package specialapi

const Number = "42"

const RandomNumber = 6

func FullName() string {
	return "Rob Pike"
}
```

Use `apidiff` to summarise the changes:

```
$ apidiff ./specialapi_v1.0.0 ./specialapi_v2.0.0
Incompatible changes:
- Name: removed
- Number: changed from untyped int to untyped string
- RandomNumber: value changed from 4 to 6
Compatible changes:
- FullName: added
```

See the usage for more information:

```
$ apidiff -help
usage:
apidiff OLD NEW
   compares OLD and NEW package APIs
   where OLD and NEW are either import paths or files of export data
apidiff -w FILE IMPORT_PATH
   writes export data of the package at IMPORT_PATH to FILE
   NOTE: In a GOPATH-less environment, this option consults the
   module cache by default, unless used in the directory that
   contains the go.mod module definition that IMPORT_PATH belongs
   to. In most cases users want the latter behavior, so be sure
   to cd to the exact directory which contains the module
   definition of IMPORT_PATH.
  -incompatible
    	display only incompatible changes
  -w string
    	file for export data
```

### Version details

```
go version go1.12.5 linux/amd64
golang.org/x/exp v0.0.0-20190510132918-efd6b22b2522
```

<!-- END -->
