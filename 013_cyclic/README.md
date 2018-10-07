<!-- __JSON: egrunner script.sh # LONG ONLINE

## Cyclic module dependencies

Cyclic module dependencies typically come about through test dependencies. This example presents a simple cyclic
dependency between two package, through one's external test package. Those two packages are initially part of the
same module, but then split into two separate modules where the cyclic dependency is created.

The resulting repository state can be seen at {{PrintBlockOut "repo"}}.

### Walkthrough

Create a repository root and add a git remote:

```
{{PrintBlock "setup" -}}
```

Define a root module at the root of the repo; add two subpackages `a` and `b`, with a depdency from `a -> b` and `b_test
-> a`; test, commit and push:

```
{{PrintBlock "define repo root module" -}}
```

Create a submodule from the subpackage `b`. Note at this point, only `{{PrintBlockOut "module"}}` can be resolved over
the internet; `{{PrintBlockOut "moduleb"}}` only exists locally. This will also be the case for any CI run before our
next commit is referenced by `master` on our remote. Hence we temporarily use relative `replace` directives for the
dependencies `a -> b` and `b -> a`. However, because of [#26241](https://github.com/golang/go/issues/26241), we cannot
current use a `replace` directive to satisfy the dependency `a -> b`. So for now this next step is pushed in a "broken"
state; we don't add relative `replace` directives for either dependency. This step will be updated once #26241 is fixed.

```
{{PrintBlock "create submodule from b" -}}
```

Until #26241 is merged, this is where the mutual dependency gets created:

```
{{PrintBlock "create mutual dependency" -}}
```

List the dependencies of `{{PrintBlockOut "module"}}`:

```
{{PrintBlock "list root dependencies" -}}
```

List the dependencies of `{{PrintBlockOut "moduleb"}}`:

```
{{PrintBlock "list b dependencies" -}}
```

Commit the mutual dependency:

```
{{PrintBlock "commit mutual dependency" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Cyclic module dependencies

Cyclic module dependencies typically come about through test dependencies. This example presents a simple cyclic
dependency between two package, through one's external test package. Those two packages are initially part of the
same module, but then split into two separate modules where the cyclic dependency is created.

The resulting repository state can be seen at https://github.com/go-modules-by-example/cyclic
.

### Walkthrough

Create a repository root and add a git remote:

```
$ mkdir cyclic
$ cd cyclic
$ git init -q
$ git remote add origin https://github.com/$GITHUB_ORG/cyclic
```

Define a root module at the root of the repo; add two subpackages `a` and `b`, with a depdency from `a -> b` and `b_test
-> a`; test, commit and push:

```
$ go mod init github.com/$GITHUB_ORG/cyclic
go: creating new go.mod: module github.com/go-modules-by-example/cyclic
$ cat a/a.go
package a

import "github.com/go-modules-by-example/cyclic/b"

const AName = b.BName
$ cat b/b.go
package b

const BName = "B"
$ cat b/b_test.go
package b_test

import (
	"fmt"
	"github.com/go-modules-by-example/cyclic/a"
	"testing"
)

func TestUsingA(t *testing.T) {
	fmt.Printf("Here is A: %v\n", a.AName)
}
$ go test -v ./...
?   	github.com/go-modules-by-example/cyclic/a	[no test files]
=== RUN   TestUsingA
Here is A: B
--- PASS: TestUsingA (0.00s)
PASS
ok  	github.com/go-modules-by-example/cyclic/b	0.001s
$ git add -A
$ git commit -q -am "Commit 1: initial commit of parent module github.com/$GITHUB_ORG/cyclic"
$ git rev-parse HEAD
f1fb7e3a30328b87d4d5838c1d5e5b8a99af2421
$ git push -q
remote: 
remote: Create a pull request for 'master' on GitHub by visiting:        
remote:      https://github.com/go-modules-by-example/cyclic/pull/new/master        
remote: 
```

Create a submodule from the subpackage `b`. Note at this point, only `github.com/go-modules-by-example/cyclic
` can be resolved over
the internet; `github.com/go-modules-by-example/cyclic/b
` only exists locally. This will also be the case for any CI run before our
next commit is referenced by `master` on our remote. Hence we temporarily use relative `replace` directives for the
dependencies `a -> b` and `b -> a`. However, because of [#26241](https://github.com/golang/go/issues/26241), we cannot
current use a `replace` directive to satisfy the dependency `a -> b`. So for now this next step is pushed in a "broken"
state; we don't add relative `replace` directives for either dependency. This step will be updated once #26241 is fixed.

```
$ cd b
$ go mod init github.com/$GITHUB_ORG/cyclic/b
go: creating new go.mod: module github.com/go-modules-by-example/cyclic/b
$ cd ..
$ git add -A
$ git commit -q -am "Commit 2: create github.com/$GITHUB_ORG/cyclic/b"
$ git rev-parse HEAD
8d87c7206de44f963e536cc2e01f199f702d8fe5
$ git push -q
```

Until #26241 is merged, this is where the mutual dependency gets created:

```
$ go test -v ./...
go: finding github.com/go-modules-by-example/cyclic/b latest
go: downloading github.com/go-modules-by-example/cyclic/b v0.0.0-20181007184153-8d87c7206de4
?   	github.com/go-modules-by-example/cyclic/a	[no test files]
$ cd b
$ go test -v ./...
go: finding github.com/go-modules-by-example/cyclic/a latest
go: finding github.com/go-modules-by-example/cyclic latest
go: downloading github.com/go-modules-by-example/cyclic v0.0.0-20181007184153-8d87c7206de4
=== RUN   TestUsingA
Here is A: B
--- PASS: TestUsingA (0.00s)
PASS
ok  	github.com/go-modules-by-example/cyclic/b	(cached)
```

List the dependencies of `github.com/go-modules-by-example/cyclic
`:

```
$ cd ..
$ go list -m all
github.com/go-modules-by-example/cyclic
github.com/go-modules-by-example/cyclic/b v0.0.0-20181007184153-8d87c7206de4
```

List the dependencies of `github.com/go-modules-by-example/cyclic/b
`:

```
$ cd b
$ go list -m all
github.com/go-modules-by-example/cyclic/b
github.com/go-modules-by-example/cyclic v0.0.0-20181007184153-8d87c7206de4
```

Commit the mutual dependency:

```
$ cd ..
$ git add -A
$ git commit -q -am "Commit 3: the mutual dependency"
$ git rev-parse HEAD
82310460c71323dc4f1178a19cc5e7c925d48999
$ git push -q
```

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
