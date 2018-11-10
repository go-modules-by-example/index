<!-- __JSON: gobin -m -run myitcv.io/cmd/egrunner script.sh # LONG ONLINE

## Semantic import versioning by example

Semantic import versioning is a key concept for Go modules. Russ' [Semantic Import Versioning
post](https://research.swtch.com/vgo-import) goes into this in great detail, as [does the
wiki](https://github.com/golang/go/wiki/Modules#semantic-import-versioning).

In this example we introduce the concept of semantic import versioning by example from the ground up, including making a
breaking change to force a major version change.

### Overview

This example creates two modules:

* Module `{{PrintOut "gi mod"}}` contains two packages that give us information about the Go programming
  language:
  * Package `{{PrintOut "gi mod"}}/contributors` gives detail about contributors to the language
  * Package `{{PrintOut "gi mod"}}/designers` gives the names of those who designed the language. It
    imports `contributors` to create a trivial intra-module dependency
* Module `{{PrintOut "pp mod"}}` uses `{{PrintOut "gi mod"}}` to print some interesting information to standard out

Each module is committed to its own repository. The results of this example can be seen at {{PrintOut "gi repo"}} and
{{PrintOut "pp repo"}} respectively.

### Walk-through

Prepare the `{{PrintOut "gi mod"}}` module:

```
{{PrintBlock "setup gi structure" -}}
```

Create the `contributors` package:

```go
{{PrintBlockOut "create contributors" -}}
```

Create the `designers` package:

```go
{{PrintBlockOut "create designers" -}}
```

Prepare the `{{PrintOut "pp mod"}}` module:

```
{{PrintBlock "setup pp structure" -}}
```

Create a single `main` package in `{{PrintOut "pp mod"}}`.

```go
{{PrintBlockOut "peopleprinter" -}}
```

We have not yet published a commit or version of `{{PrintOut "gi mod"}}`. Hence for now we use a `replace` directive to
use the `{{PrintOut "gi mod"}}` defined locally:

```
{{PrintBlock "pp initial replace" -}}
```

We see the effect in the `go.mod` file:

```
{{PrintBlockOut "pp replace go.mod" -}}
```

Run the `main` package as a "test":

```
{{PrintBlock "run peopleprinter" -}}
```

Commit, push and tag to release version `v1.0.0` of `{{PrintOut "gi mod"}}`:

```
{{PrintBlock "publish goinfo" -}}
```

Use version `v1.0.0` of `{{PrintOut "gi mod"}}` in `{{PrintOut "pp mod"}}`:

```
{{PrintBlock "use published goinfo v1.0.0" -}}
```

Confirm the effect in `go.mod`:

```
{{PrintBlockOut "pp go.mod v2" -}}
```

Re-run our "test":

```
{{PrintBlock "pp run v2" -}}
```

Commit, push and tag version `v1.0.0` of `{{PrintOut "pp mod"}}`:

```
{{PrintBlock "public pp v1.0.0" -}}
```

At this point, let's assume we want to make a breaking change to `{{PrintOut "gi mod"}}`. This will require us to
release a new major version of `{{PrintOut "gi mod"}}`. According to semantic import versioning, this new major version
will be imported as `{{PrintOut "gi mod"}}/v2`.

Before we make the breaking change, we need to decide what git repository structure we want going forward. This is
largely determined by whether we want to maintain support for the `v1` series any longer. This particular question is
covered in more detail [in the wiki](https://github.com/golang/go/wiki/Modules#releasing-modules-v2-or-higher). For this
example we use the major branch strategy so that we can easily make changes and releases to both the `v1`
and `v2` series.

We create a `v1` branch and push:

```
{{PrintBlock "tag v1 branch of gi" -}}
```

Now we make the breaking change to `designers`:

```go
{{PrintBlockOut "breaking designers" -}}
```

Now we need to prepare `{{PrintOut "gi mod"}}` to become a `v2` module. This will involve fixing our `go.mod` and any
intra-module import paths. We will use [`github.com/marwan-at-work/mod`](https://github.com/marwan-at-work/mod) to
do this.

Install `mod`:

```
{{PrintBlock "install mod" | lineEllipsis 6 -}}
```

Verify `mod` is working:

```
{{PrintBlock "ensure mod working" | lineEllipsis 7 -}}
```

Prepare our module for `v2` (the next major version):

```
{{PrintBlock "mod upgrade" -}}
```

Commit, push and tag a new major version of `{{PrintOut "gi mod"}}`, which we now refer to as `{{PrintOut "gi mod"}}/v2`:

```
{{PrintBlock "breaking commit of gi" -}}
```

[Review the diff between `v1.0.0` and `v2.0.0`]({{PrintOut "v1 v2 diffs" -}}).

Adapt `peopleprinter` to use both `{{PrintOut "gi mod"}}` and `{{PrintOut "gi mod"}}/v2`:

```go
{{PrintBlockOut "pp v2" -}}
```

Check the new behaviour via a run "test":

```
{{PrintBlock "run v2" -}}
```

Review all the dependencies of `peopleprinter`:

```
{{PrintBlock "pp v2 deps" -}}
```

Commit, push and tag a new version of `peopleprinter`:

```
{{PrintBlock "commit pp v2" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Semantic import versioning by example

Semantic import versioning is a key concept for Go modules. Russ' [Semantic Import Versioning
post](https://research.swtch.com/vgo-import) goes into this in great detail, as [does the
wiki](https://github.com/golang/go/wiki/Modules#semantic-import-versioning).

In this example we introduce the concept of semantic import versioning by example from the ground up, including making a
breaking change to force a major version change.

### Overview

This example creates two modules:

* Module `github.com/go-modules-by-example/goinfo` contains two packages that give us information about the Go programming
  language:
  * Package `github.com/go-modules-by-example/goinfo/contributors` gives detail about contributors to the language
  * Package `github.com/go-modules-by-example/goinfo/designers` gives the names of those who designed the language. It
    imports `contributors` to create a trivial intra-module dependency
* Module `github.com/go-modules-by-example/peopleprinter` uses `github.com/go-modules-by-example/goinfo` to print some interesting information to standard out

Each module is committed to its own repository. The results of this example can be seen at https://github.com/go-modules-by-example/goinfo and
https://github.com/go-modules-by-example/peopleprinter respectively.

### Walk-through

Prepare the `github.com/go-modules-by-example/goinfo` module:

```
$ mkdir -p /home/gopher/scratchpad/goinfo
$ cd /home/gopher/scratchpad/goinfo
$ git init -q
$ git remote add origin https://github.com/go-modules-by-example/goinfo
$ go mod init
go: creating new go.mod: module github.com/go-modules-by-example/goinfo
$ mkdir contributors designers
```

Create the `contributors` package:

```go
$ cat contributors/contributors.go
package contributors

type Person struct {
	FullName string
}

var all = [...]Person{
	Person{FullName: "Robert Griesemer"},
	Person{FullName: "Rob Pike"},
	Person{FullName: "Ken Thompson"},
	Person{FullName: "Russ Cox"},
	Person{FullName: "Ian Lance Taylor"},
}

func Details() []Person {
	res := all
	return res[:]
}
```

Create the `designers` package:

```go
$ cat designers/designers.go
package designers

import "github.com/go-modules-by-example/goinfo/contributors"

func Names() []string {
	var res []string
	for _, p := range contributors.Details() {
		switch p.FullName {
		case "Rob Pike", "Ken Thompson", "Robert Griesemer":
			res = append(res, p.FullName)
		}
	}
	return res
}
```

Prepare the `github.com/go-modules-by-example/peopleprinter` module:

```
$ cd /home/gopher/scratchpad
$ mkdir peopleprinter
$ cd peopleprinter
$ git init -q
$ git remote add origin https://github.com/go-modules-by-example/peopleprinter
$ go mod init
go: creating new go.mod: module github.com/go-modules-by-example/peopleprinter
```

Create a single `main` package in `github.com/go-modules-by-example/peopleprinter`.

```go
$ cat main.go
package main

import (
	"fmt"
	"github.com/go-modules-by-example/goinfo/designers"
	"strings"
)

func main() {
	fmt.Printf("The designers of Go: %v\n", strings.Join(designers.Names(), ", "))
}
```

We have not yet published a commit or version of `github.com/go-modules-by-example/goinfo`. Hence for now we use a `replace` directive to
use the `github.com/go-modules-by-example/goinfo` defined locally:

```
$ go mod edit -require=github.com/go-modules-by-example/goinfo@v0.0.0 -replace=github.com/go-modules-by-example/goinfo=/home/gopher/scratchpad/goinfo
```

We see the effect in the `go.mod` file:

```
$ cat go.mod
module github.com/go-modules-by-example/peopleprinter

require github.com/go-modules-by-example/goinfo v0.0.0

replace github.com/go-modules-by-example/goinfo => /home/gopher/scratchpad/goinfo
```

Run the `main` package as a "test":

```
$ go run .
go: finding github.com/go-modules-by-example/goinfo v0.0.0
The designers of Go: Robert Griesemer, Rob Pike, Ken Thompson
```

Commit, push and tag to release version `v1.0.0` of `github.com/go-modules-by-example/goinfo`:

```
$ cd /home/gopher/scratchpad/goinfo
$ git add -A
$ git commit -q -am 'Initial commit of goinfo'
$ git push -q origin
remote: 
remote: Create a pull request for 'master' on GitHub by visiting:        
remote:      https://github.com/go-modules-by-example/goinfo/pull/new/master        
remote: 
$ git tag v1.0.0
$ git push -q origin v1.0.0
```

Use version `v1.0.0` of `github.com/go-modules-by-example/goinfo` in `github.com/go-modules-by-example/peopleprinter`:

```
$ cd /home/gopher/scratchpad/peopleprinter
$ go mod edit -require=github.com/go-modules-by-example/goinfo@v1.0.0 -dropreplace=github.com/go-modules-by-example/goinfo
```

Confirm the effect in `go.mod`:

```
$ cat go.mod
module github.com/go-modules-by-example/peopleprinter

require github.com/go-modules-by-example/goinfo v1.0.0
```

Re-run our "test":

```
$ go run .
go: finding github.com/go-modules-by-example/goinfo v1.0.0
go: downloading github.com/go-modules-by-example/goinfo v1.0.0
The designers of Go: Robert Griesemer, Rob Pike, Ken Thompson
```

Commit, push and tag version `v1.0.0` of `github.com/go-modules-by-example/peopleprinter`:

```
$ git add -A
$ git commit -q -am 'Initial commit of peopleprinter'
$ git push -q origin
remote: 
remote: Create a pull request for 'master' on GitHub by visiting:        
remote:      https://github.com/go-modules-by-example/peopleprinter/pull/new/master        
remote: 
$ git tag v1.0.0
$ git push -q origin v1.0.0
```

At this point, let's assume we want to make a breaking change to `github.com/go-modules-by-example/goinfo`. This will require us to
release a new major version of `github.com/go-modules-by-example/goinfo`. According to semantic import versioning, this new major version
will be imported as `github.com/go-modules-by-example/goinfo/v2`.

Before we make the breaking change, we need to decide what git repository structure we want going forward. This is
largely determined by whether we want to maintain support for the `v1` series any longer. This particular question is
covered in more detail [in the wiki](https://github.com/golang/go/wiki/Modules#releasing-modules-v2-or-higher). For this
example we use the major branch strategy so that we can easily make changes and releases to both the `v1`
and `v2` series.

We create a `v1` branch and push:

```
$ cd /home/gopher/scratchpad/goinfo
$ git branch master.v1
$ git push -q origin master.v1
remote: 
remote: Create a pull request for 'master.v1' on GitHub by visiting:        
remote:      https://github.com/go-modules-by-example/goinfo/pull/new/master.v1        
remote: 
```

Now we make the breaking change to `designers`:

```go
$ cat designers/designers.go
package designers

import "github.com/go-modules-by-example/goinfo/contributors"

func FullNames() []string {
	var res []string
	for _, p := range contributors.Details() {
		switch p.FullName {
		case "Rob Pike", "Ken Thompson", "Robert Griesemer":
			res = append(res, p.FullName)
		}
	}
	return res
}
```

Now we need to prepare `github.com/go-modules-by-example/goinfo` to become a `v2` module. This will involve fixing our `go.mod` and any
intra-module import paths. We will use [`github.com/marwan-at-work/mod`](https://github.com/marwan-at-work/mod) to
do this.

Install `mod`:

```
$ cd $(mktemp -d)
$ go mod init mod
go: creating new go.mod: module mod
$ go get -m github.com/marwan-at-work/mod
go: finding github.com/marwan-at-work/mod v0.1.0
go: finding github.com/PuerkitoBio/goquery v1.4.1
...
```

Verify `mod` is working:

```
$ mod -help
NAME:
   mod - upgrade/downgrade semantic import versioning

USAGE:
   mod [global options] command [command options] [arguments...]

...
```

Prepare our module for `v2` (the next major version):

```
$ cd /home/gopher/scratchpad/goinfo
$ mod upgrade
```

Commit, push and tag a new major version of `github.com/go-modules-by-example/goinfo`, which we now refer to as `github.com/go-modules-by-example/goinfo/v2`:

```
$ git add -A
$ git commit -q -am 'Breaking commit of goinfo'
$ git push -q origin
$ git tag v2.0.0
$ git push -q origin v2.0.0
```

[Review the diff between `v1.0.0` and `v2.0.0`](https://github.com/go-modules-by-example/goinfo/compare/v1.0.0...v2.0.0).

Adapt `peopleprinter` to use both `github.com/go-modules-by-example/goinfo` and `github.com/go-modules-by-example/goinfo/v2`:

```go
$ cat main.go
package main

import (
	"fmt"
	"github.com/go-modules-by-example/goinfo/designers"
	v2designers "github.com/go-modules-by-example/goinfo/v2/designers"
	"strings"
)

func main() {
	fmt.Printf("The designers of Go: %v\n", strings.Join(designers.Names(), ", "))
	fmt.Printf("The designers of Go: %v\n", strings.Join(v2designers.FullNames(), ", "))
}
```

Check the new behaviour via a run "test":

```
$ cd /home/gopher/scratchpad/peopleprinter
$ go run .
go: finding github.com/go-modules-by-example/goinfo/v2/designers latest
go: finding github.com/go-modules-by-example/goinfo/v2 v2.0.0
go: downloading github.com/go-modules-by-example/goinfo/v2 v2.0.0
The designers of Go: Robert Griesemer, Rob Pike, Ken Thompson
The designers of Go: Robert Griesemer, Rob Pike, Ken Thompson
```

Review all the dependencies of `peopleprinter`:

```
$ go list -m all
github.com/go-modules-by-example/peopleprinter
github.com/go-modules-by-example/goinfo v1.0.0
github.com/go-modules-by-example/goinfo/v2 v2.0.0
```

Commit, push and tag a new version of `peopleprinter`:

```
$ git add -A
$ git commit -q -am 'Use goinfo v2 in peopleprinter'
$ git push -q origin
$ git tag v1.1.0
$ git push -q origin v1.1.0
```

### Version details

```
go version go1.11.2 linux/amd64
github.com/marwan-at-work/mod v0.1.0
```

<!-- END -->
