<!-- __JSON: egrunner script.sh # LONG ONLINE

### Introduction

vgo supports nesting of modules, which gives us submodules. This example shows you how.

_Add more detail/intro here_

### Walkthrough

Start by getting `vgo` in the usual way:

```
{{PrintBlock "go get vgo" -}}
```

Initialise a directory as a git repo, and add an appropriate remote:


```
{{PrintBlock "setup" -}}
```

Now define our root module, at the root of the repo, commit and push:

```
{{PrintBlock "define repo root module" -}}
```

Now create a `package b` and test that it builds:

```
{{PrintBlock "create package b" -}}
```

Now commit, tag and push our new package:

```
{{PrintBlock "commit and tag b" -}}
```

Now create a `main` package that will use `b`:

```
{{PrintBlock "create package a" -}}
```

Now let's build and run our package:


```
{{PrintBlock "run package a" -}}
```

See how we resolve to the tagged version of `package b`.


Finally we commit, tag and push our `main` package:


```
{{PrintBlock "commit and tag a" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

### Introduction

vgo supports nesting of modules, which gives us submodules. This example shows you how.

_Add more detail/intro here_

### Walkthrough

Start by getting `vgo` in the usual way:

```
$ go get -u golang.org/x/vgo
```

Initialise a directory as a git repo, and add an appropriate remote:


```
$ mkdir vgo-by-example-submodules
$ cd vgo-by-example-submodules
$ git init
Initialized empty Git repository in /go/vgo-by-example-submodules/.git/
$ git remote add origin https://github.com/$GITHUB_USERNAME/vgo-by-example-submodules
```

Now define our root module, at the root of the repo, commit and push:

```
$ cat <<EOD >go.mod
module github.com/$GITHUB_USERNAME/vgo-by-example-submodules
EOD
$ git add go.mod
$ git commit -am 'Initial commit'
[master (root-commit) 20480d4] Initial commit
 1 file changed, 1 insertion(+)
 create mode 100644 go.mod
$ git push
To https://github.com/myitcv/vgo-by-example-submodules
 * [new branch]      master -> master
```

Now create a `package b` and test that it builds:

```
$ mkdir b
$ cd b
$ cat <<EOD >b.go
package b // import "github.com/$GITHUB_USERNAME/vgo-by-example-submodules/b"

const Name = "Gopher"
EOD
$ echo >go.mod
$ vgo test
testing: warning: no tests to run
PASS
?   	github.com/myitcv/vgo-by-example-submodules/b	0.004s [no test files]
```

Now commit, tag and push our new package:

```
$ cd ..
$ git add b
$ git commit -am 'Add package b'
[master 5ba2583] Add package b
 2 files changed, 4 insertions(+)
 create mode 100644 b/b.go
 create mode 100644 b/go.mod
$ git push
To https://github.com/myitcv/vgo-by-example-submodules
   20480d4..5ba2583  master -> master
$ git tag b/v0.1.1
$ git push origin b/v0.1.1
To https://github.com/myitcv/vgo-by-example-submodules
 * [new tag]         b/v0.1.1 -> b/v0.1.1
```

Now create a `main` package that will use `b`:

```
$ mkdir a
$ cd a
$ cat <<EOD >a.go
package main // import "github.com/$GITHUB_USERNAME/vgo-by-example-submodules/a"

import (
	"github.com/$GITHUB_USERNAME/vgo-by-example-submodules/b"
	"fmt"
)

const Name = b.Name

func main() {
	fmt.Println(Name)
}
EOD
$ echo >go.mod
```

Now let's build and run our package:


```
$ vgo build
vgo: resolving import "github.com/myitcv/vgo-by-example-submodules/b"
vgo: finding github.com/myitcv/vgo-by-example-submodules/b (latest)
vgo: adding github.com/myitcv/vgo-by-example-submodules/b v0.1.1
vgo: finding github.com/myitcv/vgo-by-example-submodules/b v0.1.1
vgo: downloading github.com/myitcv/vgo-by-example-submodules/b v0.1.1
$ ./a
Gopher
$ cat go.mod
module github.com/myitcv/vgo-by-example-submodules/a

require github.com/myitcv/vgo-by-example-submodules/b v0.1.1
```

See how we resolve to the tagged version of `package b`.


Finally we commit, tag and push our `main` package:


```
$ cd ..
$ git add a
$ git commit -am 'Add package a'
[master 4f78f02] Add package a
 3 files changed, 15 insertions(+)
 create mode 100755 a/a
 create mode 100644 a/a.go
 create mode 100644 a/go.mod
$ git push
To https://github.com/myitcv/vgo-by-example-submodules
   5ba2583..4f78f02  master -> master
$ git tag a/v1.0.0
$ git push origin a/v1.0.0
To https://github.com/myitcv/vgo-by-example-submodules
 * [new tag]         a/v1.0.0 -> a/v1.0.0
```

### Version details

```
go version go1.10.3 linux/amd64 vgo:2018-02-20.1
vgo commit: 22e23900224f03be49670113d5781e4d89090f45
```

<!-- END -->
