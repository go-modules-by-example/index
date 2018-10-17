### Go modules by example

_Go modules by example_ is a series of work-along guides that look to help explain how [Go
modules](https://golang.org/cmd/go/#hdr-Modules__module_versions__and_more) work and how to get things done. They are
designed to complement the official Go documentation and the [Go modules
wiki](https://github.com/golang/go/wiki/Modules).

The guides are being released in no particular order and will instead be curated into a more cogent order/structure (in
conjunction with the modules wiki) at a later date.

The release-ordered list of guides:

* [How to use submodules](https://github.com/go-modules-by-example/index/blob/master/009_submodules/README.md)
* [Using modules to manage
  vendor](https://github.com/go-modules-by-example/index/blob/master/008_vendor_example/README.md)
* [Creating a module download cache
  "vendor"](https://github.com/go-modules-by-example/index/blob/master/012_modvendor/README.md)
* [Using `gohack` to "hack" on
  dependencies](https://github.com/myitcv/go-modules-by-example/blob/master/011_using_gohack/README.md)
* [Migrating Buffalo from `dep` to go
  modules](https://github.com/go-modules-by-example/index/blob/master/003_migrate_buffalo/README.md)
* [Tools as dependencies](https://github.com/go-modules-by-example/index/blob/master/010_tools/README.md)
* [Cyclic module dependencies](https://github.com/go-modules-by-example/index/blob/master/013_cyclic/README.md)

WIP guides:

* [The go modules tour](https://github.com/go-modules-by-example/index/blob/master/001_go_modules_tour/README.md) (a
  rewrite of the original vgo tour)
* [Using go modules with
  gopkg.in](https://github.com/go-modules-by-example/index/blob/master/002_using_gopkg_in/README.md)
* [Using a package that has not been converted to go
  modules](https://github.com/go-modules-by-example/index/blob/master/004_echo_example/README.md)
* [Example of backwards compatibility in Go 1.10 with semantic import
  paths](https://github.com/go-modules-by-example/index/blob/master/005_old_go/README.md)
* [Another example of package/project that has not yet been converted to a
  module](https://github.com/go-modules-by-example/index/blob/master/006_not_yet_go_module/README.md)
* [Forking a project which has not yet been converted to a Go
  module](https://github.com/go-modules-by-example/index/blob/master/007_old_code_replace/README.md)
* ...

Wikis:

* [FAQ](https://github.com/go-modules-by-example/index/wiki/FAQ)
* [TODO](https://github.com/go-modules-by-example/index/wiki/TODO)
* [Feedback](https://github.com/go-modules-by-example/index/wiki/Feedback)

### Structure

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

### Testing scripts

To ensure reproducibility and isolation, scripts are run in a Docker container; the
[`golang`](https://hub.docker.com/_/golang/) container is used:

<!-- __TEMPLATE: docker pull golang # LONG ONLINE
```
{{.Cmd}}
```
-->
```
docker pull golang
```
<!-- END -->

The following environment variables must be set:

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

Ensure `egrunner` and `githubcli` are installed (and on your PATH):

<!-- __TEMPLATE: go install myitcv.io/go-modules-by-example/cmd/...
```
{{.Cmd}}
```
-->
```
go install myitcv.io/go-modules-by-example/cmd/...
```
<!-- END -->

Now run in debug mode to see real-time output:

<!-- __TEMPLATE: egrunner -out debug ./001_go_modules_tour/script.sh # LONG ONLINE
```
{{.Cmd}}
```
-->
```
egrunner -out debug ./001_go_modules_tour/script.sh
```
<!-- END -->

### Regenerating a guide

First ensure `mdreplace` and `egrunner` are installed (and on your PATH):

<!-- __TEMPLATE: go install myitcv.io/go-modules-by-example/cmd/...
```
{{.Cmd}}
```
-->
```
go install myitcv.io/go-modules-by-example/cmd/...
```
<!-- END -->

Then re-run `mdreplace` on a guide template, e.g. for the go modules by example tour:

<!-- __TEMPLATE: mdreplace -w -long -online ./001_go_modules_tour/README.md # LONG ONLINE
```
{{.Cmd}}
```
-->
```
mdreplace -w -long -online ./001_go_modules_tour/README.md
```
<!-- END -->

### Caveats

This project is work-in-progress. Feedback/PRs welcome.

### Credits

With particular thanks (in no particular order) to:

* [bcmills](https://github.com/bcmills)
* [mvdan](https://github.com/mvdan)
* [rogpeppe](https://github.com/rogpeppe)
* [rsc](https://github.com/rsc)
* [thepudds](https://github.com/thepudds)
