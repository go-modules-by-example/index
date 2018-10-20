### How is a guide structured?

A guide comprises a README.md and an accompanying bash script. The README is the human readable bit and the script acts
as a reproducible set of steps (that can be tested) for the guide. For example, the vgo tour has been rewritten as a _Go
modules by example_ guide:

<!-- __TEMPLATE: ls 001_go_modules_tour
```
$ {{.Cmd}}
{{.Out -}}
```
-->
```
$ ls 001_go_modules_tour
README.md
script.sh
```
<!-- END -->

script.sh contains, as its name suggests, the overall script for the guide. It includes a pre-amble that defines a
number of helper functions for testing the script, followed by the header:

```
# **START**
```

This marks the start of the script.

What follows are a number of optionally commented "blocks". For example, the following block is labelled `"install tools"`
and comprises all the contiguous lines that follow the special `# block:` comment:

```
# block: install tools
go install example.com/blah
assert "$? -eq 1" $LINENO
```

By default, each command is assumed to have an exit code of `0`, unless it is followed by an `assert` line, like above,
that asserts otherwise. In this respect, the script behaves much like `set -e`.

The corresponding README.md acts as a template for the guide itself, but crucially it can reference these blocks to
include the commands themselves and/or their output, e.g.:

    ```
    {{PrintBlock "install tools" -}}
    ```

Look at the raw [Go modules by example tour README.md](https://raw.githubusercontent.com/go-modules-by-example/index/master/001_go_modules_tour/README.md)
and [corresponding script](https://github.com/go-modules-by-example/index/blob/master/001_go_modules_tour/script.sh) for more examples.

### Getting started: regenerating a guide

What follows assumes you have [Docker](https://docs.docker.com/install/) installed.

The following environment variables must also be set:

```bash
GITHUB_USERNAME    # your Github username
GITHUB_PAT         # a personal access token with public_repo scope
GITHUB_ORG         # an org/user account where forks, examples will be created
GITHUB_ORG_ARCHIVE # an org/user account where old forks, examples etc will be moved
```

It's probably a good idea to [create a new personal access token](https://github.com/settings/tokens/new) specifically
for your "fork" of "Go Modules by Example" - you will need `public_repo` scope.

Creating a [new GitHub organisation](https://github.com/organizations/new) will allow you to segregate the
examples/forks created by your guides (instead of cluttering your personal account). This corresponds to the
`GITHUB_ORG` environment variable above. Similarly, create another organisation that will act as the archive,
`GITHUB_ORG_ARCHIVE`.

<!-- __JSON: egrunner -df -v=/var/run/docker.sock:/var/run/docker.sock -df -v=/tmp:/tmp contributing.sh # LONG ONLINE

Verify that you can pull the required image:

```
{{PrintBlock "docker pull" -}}
```

Clone this repo:

```
{{PrintBlock "clone" -}}
```

Install the required commands (assumes your `PATH` is correctly setup):

```
{{PrintBlock "go install" | lineEllipsis 8 -}}
```

Check that you can use `egrunner`:

```
{{PrintBlockOut "echo egrun" -}}
```

should give the output:

```
{{PrintBlockOut "egrun" -}}
```

Finally check you can use `mdreplace`:

```
{{PrintBlock "mdrun" -}}
```

-->

Verify that you can pull the required image:

```
$ docker pull golang
Using default tag: latest
latest: Pulling from library/golang
Digest: sha256:63ec0e29aeba39c0fe2fc6551c9ca7fa16ddf95394d77ccee75bc7062526a96c
Status: Image is up to date for golang:latest
```

Clone this repo:

```
$ git clone https://github.com/go-modules-by-example/index
Cloning into 'index'...
$ cd index
```

Install the required commands (assumes your `PATH` is correctly setup):

```
$ go install myitcv.io/cmd/{mdreplace,egrunner,githubcli}
go: finding myitcv.io v0.0.0-20181019205227-29e3c27c8823
go: finding github.com/jteeuwen/go-bindata v3.0.7+incompatible
go: finding github.com/sclevine/agouti v3.0.0+incompatible
go: finding github.com/google/go-github v17.0.0+incompatible
go: finding github.com/gopherjs/jsbuiltin v0.0.0-20180426082241-50091555e127
go: finding github.com/onsi/gomega v1.4.1
go: finding golang.org/x/oauth2 v0.0.0-20181017192945-9dcd33a902f4
...
```

Check that you can use `egrunner`:

```
$ egrunner -out std ./000_simple_example/script.sh
```

should give the output:

```
go: creating new go.mod: module example.com/simple
$ cd $HOME
$ mkdir simple
$ cd simple
$ go mod init example.com/simple
$ go list -m
example.com/simple
```

Finally check you can use `mdreplace`:

```
$ mdreplace -w -long -online ./000_simple_example/README.md
```

<!-- END -->
