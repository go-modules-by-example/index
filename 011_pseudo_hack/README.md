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
$ mkdir $repoName
$ cd $repoName
$ git init -q
$ git remote add origin https://github.com/$GITHUB_USERNAME/$repoName
```

Now define our root module, at the root of the repo, commit and push:

```
$ go mod init github.com/$GITHUB_USERNAME/$repoName
go: creating new go.mod: module github.com/myitcv/go-modules-by-example-pseudo-hack
$ mkdir pkg
$ cat <<EOD >pkg/pkg.go
package pkg

const Name = "v1"
EOD
$ git add *
$ git commit -q -am 'v1 commit'
$ firstcommit="v0.0.0-$(git log -1 --pretty=format:%ad --date=format:%Y%m%d%H%M%S)-$(git log -1 --pretty=format:%H | cut -c1-12)"
$ git push -q
```

Now create a `package b` and test that it builds:

```
```

Now commit, tag and push our new package:

```
```

Now create a `main` package that will use `b`:

```
```

Now let's build and run our package:


```
```

See how we resolve to the tagged version of `package b`.


Finally we commit, tag and push our `main` package:


```
```

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
