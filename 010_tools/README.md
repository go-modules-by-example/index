<!-- __JSON: egrunner script.sh # LONG ONLINE

### Introduction

Go supports tools as dependencies of modules. This example shows you how.

_Add more detail/intro here_

### Walkthrough

Create ourselves a directory:

```
{{PrintBlock "setup" -}}
```

Define where we want our tool dependencies to be installed:


```
{{PrintBlock "set bin target" -}}
```

Add our tool dependency and install it:


```
{{PrintBlock "add tool dependency" -}}
```

Check our `go.mod` now reflects the new module requirement:


```
{{PrintBlock "check go.mod" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

### Introduction

Go supports tools as dependencies of modules. This example shows you how.

_Add more detail/intro here_

### Walkthrough

Create ourselves a directory:

```
$ pwd
/root
$ ls
$ mkdir go-modules-by-example-tools
$ cd go-modules-by-example-tools
$ go mod init github.com/$GITHUB_USERNAME/go-modules-by-example-tools
go: creating new go.mod: module github.com/myitcv/go-modules-by-example-tools
```

Define where we want our tool dependencies to be installed:


```
$ export GOBIN=$PWD/bin
```

Add our tool dependency and install it:


```
$ cat <<EOD >tools.go
// +build tools

package tools

import (
        _ "golang.org/x/tools/cmd/stringer"
)
EOD
$ go install golang.org/x/tools/cmd/stringer
go: finding golang.org/x/tools/cmd/stringer latest
go: finding golang.org/x/tools/cmd latest
go: finding golang.org/x/tools latest
go: downloading golang.org/x/tools v0.0.0-20180904205237-0aa4b8830f48
```

Check our `go.mod` now reflects the new module requirement:


```
$ cat go.mod
module github.com/myitcv/go-modules-by-example-tools

require golang.org/x/tools v0.0.0-20180904205237-0aa4b8830f48 // indirect
$ go list -f "{{.Target}}" golang.org/x/tools/cmd/stringer
/root/go-modules-by-example-tools/bin/stringer
$ go mod edit -json
{
	"Module": {
		"Path": "github.com/myitcv/go-modules-by-example-tools"
	},
	"Require": [
		{
			"Path": "golang.org/x/tools",
			"Version": "v0.0.0-20180904205237-0aa4b8830f48",
			"Indirect": true
		}
	],
	"Exclude": null,
	"Replace": null
}
$ go mod tidy
$ go mod edit -json
{
	"Module": {
		"Path": "github.com/myitcv/go-modules-by-example-tools"
	},
	"Require": [
		{
			"Path": "golang.org/x/tools",
			"Version": "v0.0.0-20180904205237-0aa4b8830f48"
		}
	],
	"Exclude": null,
	"Replace": null
}
```

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
