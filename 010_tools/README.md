<!-- __JSON: egrunner script.sh # LONG ONLINE

### Introduction

vgo supports tools as dependencies. This example shows you how.

_Add more detail/intro here_

### Walkthrough

Start by getting `vgo` in the usual way:

```
{{PrintBlock "go get vgo" -}}
```

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

vgo supports tools as dependencies. This example shows you how.

_Add more detail/intro here_

### Walkthrough

Start by getting `vgo` in the usual way:

```
$ go get -u golang.org/x/vgo
```

Create ourselves a directory:


```
$ mkdir vgo-by-example-tools
$ cd vgo-by-example-tools
$ vgo mod -init -module github.com/$GITHUB_USERNAME/vgo-by-example-tools
vgo: creating new go.mod: module github.com/myitcv/vgo-by-example-tools
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
$ vgo install golang.org/x/tools/cmd/stringer
vgo: resolving import "golang.org/x/tools/cmd/stringer"
vgo: finding golang.org/x/tools/cmd/stringer latest
vgo: finding golang.org/x/tools/cmd latest
vgo: finding golang.org/x/tools latest
vgo: finding golang.org/x/tools (latest)
vgo: adding golang.org/x/tools v0.0.0-20180628163957-1c99e1239a0c
vgo: downloading golang.org/x/tools v0.0.0-20180628163957-1c99e1239a0c
```

Check our `go.mod` now reflects the new module requirement:


```
$ cat go.mod
module github.com/myitcv/vgo-by-example-tools

require golang.org/x/tools v0.0.0-20180628163957-1c99e1239a0c
$ vgo list -f "{{.Target}}" golang.org/x/tools/cmd/stringer
/go/vgo-by-example-tools/bin/stringer
$ vgo mod -json
{
	"Module": {
		"Path": "github.com/myitcv/vgo-by-example-tools",
		"Version": ""
	},
	"Require": [
		{
			"Path": "golang.org/x/tools",
			"Version": "v0.0.0-20180628163957-1c99e1239a0c"
		}
	],
	"Exclude": null,
	"Replace": null
}
$ vgo mod -sync
warning: "ALL" matched no packages
$ vgo mod -json
{
	"Module": {
		"Path": "github.com/myitcv/vgo-by-example-tools",
		"Version": ""
	},
	"Require": null,
	"Exclude": null,
	"Replace": null
}
```

### Version details

```
go version go1.10.3 linux/amd64 vgo:2018-02-20.1
vgo commit: 97ff4ad34612eed56f1dc6c6aaee19617e45e2be
```

<!-- END -->
