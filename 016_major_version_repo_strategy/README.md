<!-- __JSON: gobin -m -run myitcv.io/cmd/egrunner script.sh # LONG ONLINE

## Options for repository structure with multiple major versions

In ["Semantic import versioning by
example"](../015_semantic_import_versioning/README.md) we
briefly touched on the fact that there are options when it comes to deciding how to structure your git repository to
support breaking changes, i.e. multiple major versions.  In this guide we explore the two main options.

### Overview

This example creates two modules that have the same package structure as the `github.com/go-modules-by-example/goinfo`
package in the ["Semantic import versioning by
example"](../015_semantic_import_versioning/README.md) guide,
but each uses a different strategy when it comes to repository structure:

* [`{{PrintOut "maj-branch mod"}}`]({{PrintOut "maj-branch repo"}}) uses the major branch strategy (the strategy we
  used in ["Semantic import versioning by
example"](../015_semantic_import_versioning/README.md))
* [`{{PrintOut "maj-subdir mod"}}`]({{PrintOut "maj-subdir repo"}}) uses the major subdirectory strategy

For each strategy, we pick things up at the point where we are about to make the breaking change. We highlight the
strategy-specific steps and any relevant points/differences.

We then make the breaking change in each module and use [`mod`](https://github.com/marwan-at-work/mod) to "upgrade" to
the next major version. The results are committed, pushed and tagged.

Finally, we create [`{{PrintOut "multi pp mod"}}`]({{PrintOut "multi pp repo"}}) which contains a `main` package that
uses all major versions of the two modules to "test" that each strategy "behaves" in the same way.

### Major branch strategy

Steps:

* Create a new branch for the current major version; code for the next major version will be pushed to `master`
* Make the breaking change
* Run `mod` in the repository root
* Commit the breaking change to `master` and push
* Tag to release

```
{{PrintBlock "major branch changes" -}}
```

Points to note:

* There are now [two branches]({{PrintOut "maj-branch repo"}}/branches/all) in this repo
* `v1` changes would be submitted as [PRs that merge into the `v1` branch]({{PrintOut "maj-branch repo"}}/compare/v1...)
* The [tag for `v2.0.0`]({{PrintOut "maj-branch repo"}}/releases/tag/v2.0.0) points to a commit that is only referenced
  by the [`master` branch]({{PrintOut "maj-branch repo"}})
* The [tag for `v1.0.0`]({{PrintOut "maj-branch repo"}}/releases/tag/v1.0.0) points to a commit that is referenced by
  both branches

### Major subdirectory strategy

Steps:

* Create a subdirectory at the top level of the repo for the next major version (`v2` in this case)
* Copy the code for the current major version into this subdirectory
* Make the breaking change in the subdirectory
* Run `mod` in the subdirectory
* Commit the breaking change to `master` and push
* Tag to release

```
{{PrintBlock "major subdir changes" -}}
```
Points to note:

* We only have [one branch]({{PrintOut "maj-subdir repo"}}/branches/all) in this repo; `master`
* All changes to all major versions are submitted as PRs that merge into `master`
* All tags for all versions point to commits that are referenced by `master`

### Creating `{{PrintOut "multi pp package"}}`

Prepare the `{{PrintOut "multi pp mod"}}` module:

```
{{PrintBlock "use all major versions" -}}
```

Define the `main` package:

```go
{{PrintBlockOut "multi main" -}}
```

Run this as a "test":

```
{{PrintBlock "run multi main" -}}
```

Commit, push and tag an initial release of `{{PrintOut "multi pp mod"}}`:

```
{{PrintBlock "commit multi main" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Options for repository structure with multiple major versions

In ["Semantic import versioning by
example"](../015_semantic_import_versioning/README.md) we
briefly touched on the fact that there are options when it comes to deciding how to structure your git repository to
support breaking changes, i.e. multiple major versions.  In this guide we explore the two main options.

### Overview

This example creates two modules that have the same package structure as the `github.com/go-modules-by-example/goinfo`
package in the ["Semantic import versioning by
example"](../015_semantic_import_versioning/README.md) guide,
but each uses a different strategy when it comes to repository structure:

* [`github.com/go-modules-by-example/goinfo-maj-branch`](https://github.com/go-modules-by-example/goinfo-maj-branch) uses the major branch strategy (the strategy we
  used in ["Semantic import versioning by
example"](../015_semantic_import_versioning/README.md))
* [`github.com/go-modules-by-example/goinfo-maj-subdir`](https://github.com/go-modules-by-example/goinfo-maj-subdir) uses the major subdirectory strategy

For each strategy, we pick things up at the point where we are about to make the breaking change. We highlight the
strategy-specific steps and any relevant points/differences.

We then make the breaking change in each module and use [`mod`](https://github.com/marwan-at-work/mod) to "upgrade" to
the next major version. The results are committed, pushed and tagged.

Finally, we create [`github.com/go-modules-by-example/multi-peopleprinter`](https://github.com/go-modules-by-example/multi-peopleprinter) which contains a `main` package that
uses all major versions of the two modules to "test" that each strategy "behaves" in the same way.

### Major branch strategy

Steps:

* Create a new branch for the current major version; code for the next major version will be pushed to `master`
* Make the breaking change
* Run `mod` in the repository root
* Commit the breaking change to `master` and push
* Tag to release

```
$ git log --decorate -1
commit 9fb3586d1bd5212807f4d4d11b6e5163dd95da47 (HEAD -> master, tag: v1.0.0, origin/master)
Author: myitcv <myitcv@example.com>
Date:   Tue Apr 9 15:00:22 2019 +0000

    Initial commit of goinfo-maj-branch
$ git branch master.v1
$ git push -q origin master.v1
remote: 
remote: Create a pull request for 'master.v1' on GitHub by visiting:        
remote:      https://github.com/go-modules-by-example/goinfo-maj-branch/pull/new/master.v1        
remote: 
```

Points to note:

* There are now [two branches](https://github.com/go-modules-by-example/goinfo-maj-branch/branches/all) in this repo
* `v1` changes would be submitted as [PRs that merge into the `v1` branch](https://github.com/go-modules-by-example/goinfo-maj-branch/compare/v1...)
* The [tag for `v2.0.0`](https://github.com/go-modules-by-example/goinfo-maj-branch/releases/tag/v2.0.0) points to a commit that is only referenced
  by the [`master` branch](https://github.com/go-modules-by-example/goinfo-maj-branch)
* The [tag for `v1.0.0`](https://github.com/go-modules-by-example/goinfo-maj-branch/releases/tag/v1.0.0) points to a commit that is referenced by
  both branches

### Major subdirectory strategy

Steps:

* Create a subdirectory at the top level of the repo for the next major version (`v2` in this case)
* Copy the code for the current major version into this subdirectory
* Make the breaking change in the subdirectory
* Run `mod` in the subdirectory
* Commit the breaking change to `master` and push
* Tag to release

```
$ git log --decorate -1
commit 4f1119d34bdf01647c77434b3287d39c633e96a4 (HEAD -> master, tag: v1.0.0, origin/master)
Author: myitcv <myitcv@example.com>
Date:   Tue Apr 9 15:00:11 2019 +0000

    Initial commit of goinfo-maj-subdir
$ mkdir v2
$ cp -rp $(git ls-tree --name-only HEAD) v2
```
Points to note:

* We only have [one branch](https://github.com/go-modules-by-example/goinfo-maj-subdir/branches/all) in this repo; `master`
* All changes to all major versions are submitted as PRs that merge into `master`
* All tags for all versions point to commits that are referenced by `master`

### Creating `multi-peopleprinter`

Prepare the `github.com/go-modules-by-example/multi-peopleprinter` module:

```
$ mkdir -p /home/gopher/scratchpad/$r
$ cd /home/gopher/scratchpad/$r
$ git init -q
$ git remote add origin https://github.com/go-modules-by-example/${r}
$ go mod init
go: creating new go.mod: module github.com/go-modules-by-example/multi-peopleprinter
```

Define the `main` package:

```go
// /home/gopher/scratchpad/multi-peopleprinter/main.go

package main

import (
	"fmt"
	"os"
	"text/tabwriter"

	majBranch "github.com/go-modules-by-example/goinfo-maj-branch/designers"
	majBranch2 "github.com/go-modules-by-example/goinfo-maj-branch/v2/designers"

	majSubdir "github.com/go-modules-by-example/goinfo-maj-subdir/designers"
	majSubdir2 "github.com/go-modules-by-example/goinfo-maj-subdir/v2/designers"
)

func main() {
	tw := tabwriter.NewWriter(os.Stdout, 0, 0, 3, ' ', 0)
	w := func(format string, args ...interface{}) {
		fmt.Fprintf(tw, format, args...)
	}

	w(".../goinfo-maj-branch/designers.Names():\t%v\n", majBranch.Names())
	w(".../goinfo-maj-branch/v2/designers.FullNames():\t%v\n", majBranch2.FullNames())

	w(".../goinfo-maj-subdir/designers.Names():\t%v\n", majSubdir.Names())
	w(".../goinfo-maj-subdir/v2/designers.FullNames():\t%v\n", majSubdir2.FullNames())

	tw.Flush()
}
```

Run this as a "test":

```
$ go run .
go: finding github.com/go-modules-by-example/goinfo-maj-branch/designers latest
go: finding github.com/go-modules-by-example/goinfo-maj-branch/v2/designers latest
go: finding github.com/go-modules-by-example/goinfo-maj-subdir/v2/designers latest
go: finding github.com/go-modules-by-example/goinfo-maj-subdir/designers latest
go: finding github.com/go-modules-by-example/goinfo-maj-branch v1.0.0
go: finding github.com/go-modules-by-example/goinfo-maj-branch/v2 v2.0.0
go: downloading github.com/go-modules-by-example/goinfo-maj-branch v1.0.0
go: downloading github.com/go-modules-by-example/goinfo-maj-branch/v2 v2.0.0
go: finding github.com/go-modules-by-example/goinfo-maj-subdir/v2 v2.0.0
go: finding github.com/go-modules-by-example/goinfo-maj-subdir v1.0.0
go: extracting github.com/go-modules-by-example/goinfo-maj-branch/v2 v2.0.0
go: extracting github.com/go-modules-by-example/goinfo-maj-branch v1.0.0
go: downloading github.com/go-modules-by-example/goinfo-maj-subdir/v2 v2.0.0
go: downloading github.com/go-modules-by-example/goinfo-maj-subdir v1.0.0
go: extracting github.com/go-modules-by-example/goinfo-maj-subdir/v2 v2.0.0
go: extracting github.com/go-modules-by-example/goinfo-maj-subdir v1.0.0
go: finding github.com/go-modules-by-example/goinfo/contributors latest
go: finding github.com/go-modules-by-example/goinfo v1.0.0
go: downloading github.com/go-modules-by-example/goinfo v1.0.0
go: extracting github.com/go-modules-by-example/goinfo v1.0.0
.../goinfo-maj-branch/designers.Names():          [Robert Griesemer Rob Pike Ken Thompson]
.../goinfo-maj-branch/v2/designers.FullNames():   [Robert Griesemer Rob Pike Ken Thompson]
.../goinfo-maj-subdir/designers.Names():          [Robert Griesemer Rob Pike Ken Thompson]
.../goinfo-maj-subdir/v2/designers.FullNames():   [Robert Griesemer Rob Pike Ken Thompson]
```

Commit, push and tag an initial release of `github.com/go-modules-by-example/multi-peopleprinter`:

```
$ git add -A
$ git commit -q -am "Initial commit of $r"
$ git push -q origin
$ git tag v1.0.0
$ git push -q origin v1.0.0
```

### Version details

```
go version go1.12.3 linux/amd64
github.com/marwan-at-work/mod v0.1.0
```

<!-- END -->
