<!-- __JSON: egrunner script.sh # LONG ONLINE

## Using `gobin` to install/run tools

In the context of [`golang/go/issues/24250`](https://github.com/golang/go/issues/24250) and
[`golang/go/issues/27653`](https://github.com/golang/go/issues/27653), [`gobin`](https://github.com/myitcv/gobin) is a
work-in-progress experiment that combines aspects of `go get`, `go install` and `go run`.

This guide presents a short introduction to `gobin`.

### Walk-through

Install `gobin`:

```
{{PrintBlock "get" -}}
```

Update your `PATH` and verify we can find `gobin` in our new `PATH`:

```
{{PrintBlock "fix path" -}}
```

We are now ready to use `gobin`.

Globally install `gohack`:

```
{{PrintBlock "gohack" -}}
```

Install a specific version of `gohack`:

```
{{PrintBlock "gohack v1.0.0-alpha.2" -}}
```

Print the `gobin` cache location of a specific `gohack` version:

```
{{PrintBlock "gohack print" -}}
```

Run a specific `gohack` version:

```
{{PrintBlock "gohack run" -}}
```

`gobin`'s help gives more detail on flags and usage:

```
{{PrintBlock "help" | lineEllipsis 10 -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Using `gobin` to install/run tools

In the context of [`golang/go/issues/24250`](https://github.com/golang/go/issues/24250) and
[`golang/go/issues/27653`](https://github.com/golang/go/issues/27653), [`gobin`](https://github.com/myitcv/gobin) is a
work-in-progress experiment that combines aspects of `go get`, `go install` and `go run`.

This guide presents a short introduction to `gobin`.

### Walk-through

Install `gobin`:

```
$ GO111MODULE=off go get -u github.com/myitcv/gobin
```

Update your `PATH` and verify we can find `gobin` in our new `PATH`:

```
$ export PATH=$(go env GOPATH)/bin:$PATH
$ which gobin
/home/gopher/bin/gobin
```

We are now ready to use `gobin`.

Globally install `gohack`:

```
$ gobin github.com/rogpeppe/gohack
Installed github.com/rogpeppe/gohack@v0.0.1 to /home/gopher/bin/gohack
```

Install a specific version of `gohack`:

```
$ gobin github.com/rogpeppe/gohack@v1.0.0-alpha.2
Installed github.com/rogpeppe/gohack@v1.0.0-alpha.2 to /home/gopher/bin/gohack
```

Print the `gobin` cache location of a specific `gohack` version:

```
$ gobin -p github.com/rogpeppe/gohack@v1.0.0-alpha.2
/home/gopher/.cache/gobin/github.com/rogpeppe/gohack/@v/v1.0.0-alpha.2/github.com/rogpeppe/gohack/gohack
```

Run a specific `gohack` version:

```
$ gobin -r github.com/rogpeppe/gohack@v1.0.0-alpha.2 -help
The gohack command checks out Go module dependencies
into a directory where they can be edited, and adjusts
the go.mod file appropriately.

Usage:

	gohack <command> [arguments]

The commands are:

	get         start hacking a module
	undo        stop hacking a module
	status      print the current hack status of a module

Use "gohack help <command>" for more information about a command.
```

`gobin`'s help gives more detail on flags and usage:

```
$ gobin -help
The gobin command installs/runs main packages.

Usage:
	gobin [-m] [-r|-p] [-n|-g] packages [run arguments...]

The packages argument to gobin is similar to that of the go tool (in module
mode) with the additional constraint that the list of packages must be main
packages.

...
```

### Version details

```
go version go1.11.1 linux/amd64
```

<!-- END -->
