<!-- __JSON: egrunner script.sh # LONG ONLINE

### Introduction

Go modules supports nesting of modules, which gives us submodules. This example shows you how.

_Add more detail/intro here_

### Walkthrough

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

Go modules supports nesting of modules, which gives us submodules. This example shows you how.

_Add more detail/intro here_

### Walkthrough

Initialise a directory as a git repo, and add an appropriate remote:


```
$ mkdir go-modules-by-example-submodules
$ cd go-modules-by-example-submodules
$ git init -q
$ git remote add origin https://github.com/$GITHUB_USERNAME/go-modules-by-example-submodules
```

Now define our root module, at the root of the repo, commit and push:

```
$ go mod init github.com/$GITHUB_USERNAME/go-modules-by-example-submodules
go: creating new go.mod: module github.com/myitcv/go-modules-by-example-submodules
$ git add go.mod
$ git commit -q -am 'Initial commit'
$ git push -q
```

Now create a `package b` and test that it builds:

```
$ mkdir b
$ cd b
$ cat <<EOD >b.go
package b

const Name = "Gopher"
EOD
$ go mod init github.com/$GITHUB_USERNAME/go-modules-by-example-submodules/b
go: creating new go.mod: module github.com/myitcv/go-modules-by-example-submodules/b
$ go test
?   	github.com/myitcv/go-modules-by-example-submodules/b	[no test files]
```

Now commit, tag and push our new package:

```
$ cd ..
$ git add b
$ git commit -q -am 'Add package b'
$ git push -q
$ git tag b/v0.1.1
$ git push -q origin b/v0.1.1
```

Now create a `main` package that will use `b`:

```
$ mkdir a
$ cd a
$ cat <<EOD >.gitignore
/a
EOD
$ cat <<EOD >a.go
package main

import (
	"github.com/$GITHUB_USERNAME/go-modules-by-example-submodules/b"
	"fmt"
)

const Name = b.Name

func main() {
	fmt.Println(Name)
}
EOD
$ go mod init github.com/$GITHUB_USERNAME/go-modules-by-example-submodules/a
go: creating new go.mod: module github.com/myitcv/go-modules-by-example-submodules/a
```

Now let's build and run our package:


```
$ go build
go: finding github.com/myitcv/go-modules-by-example-submodules/b v0.1.1
go: downloading github.com/myitcv/go-modules-by-example-submodules/b v0.1.1
$ ./a
Gopher
$ cat go.mod
module github.com/myitcv/go-modules-by-example-submodules/a

require github.com/myitcv/go-modules-by-example-submodules/b v0.1.1
```

See how we resolve to the tagged version of `package b`.


Finally we commit, tag and push our `main` package:


```
$ cd ..
$ git add a
$ git commit -q -am 'Add package a'
$ git push -q
$ git tag a/v1.0.0
$ git push -q origin a/v1.0.0
```

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
