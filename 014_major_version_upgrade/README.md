# Major Version Upgrade
----

### Introduction

If you have a module that is say `1.2.3` and you want to introduce a breaking change and therefore upgrade to say `v2.0.0`, you will also have to upgrade *all* of your import paths to reflect the `v2` inside your sub directories. For example, `import github.com/google/go-github/github` becomes `import github.com/google/go-github/v2/github` -- Note the `v2` in the import path that sits at the end of the module import path, but before any sub directories. 

This can be a tedious task if you have many sub directories and many files. Take a look at this PR for an example of what that change might look like: https://github.com/google/martian/pull/262/files

We should not be manually rewriting all of those import paths, and so we can write tools to help upgrade our modules.

[github.com/marwan-at-work/mod](https://github.com/marwan-at-work/mod) is an open source command that helps with exactly that.

This is how you install it

`go install github.com/marwan-at-work/mod/cmd/mod` 

Then from inside your own package that you'd like to upgrade just run `mod upgrade` -- or if you want to jump to a specific version run `mod upgrade -v=N` where `N` is the version number you'd like to change to. 

if you have a `go.mod` file that looks like this: 

```
module github.com/hello/there/v3

require (
    github.com/pkg/errors => v0.0.8
)
```

Then the `mod` command will rewrite the file to look like this: 

```
module github.com/hello/there/v4

require (
    github.com/pkg/errors => v0.0.8
)
```

And if you have a sub directory that looks like this: 

```golang
import (
    "github.com/hello/there/v3/subdir"
    "github.com/pkg/errors"
)

// ...
```

Then it will be written to be like this: 

```golang
import (
    "github.com/hello/there/v4/subdir"
    "github.com/pkg/errors"
)

// ...
```

Note, this is for updating your own package as the package owner, and not updating one of your dependencies to use a new major version.