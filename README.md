### `**This is a work-in-progress and pending review. Please do not link to this for now.**`

### Go modules by example

_Go modules by example_ is a series of work-along guides that look to help explain how go modules works and how to get things done.

* [The go modules tour](https://github.com/myitcv/go-modules-by-example/blob/master/001_go_modules_tour/README.md) (a rewrite of the original vgo tour)
* [Using go modules with gopkg.in](https://github.com/myitcv/go-modules-by-example/blob/master/002_using_gopkg_in/README.md)
* [Migrating Buffalo from dep to go modules](https://github.com/myitcv/go-modules-by-example/blob/master/003_migrate_buffalo/README.md)
* [Using a package that has not been converted to go modules](https://github.com/myitcv/go-modules-by-example/blob/master/004_echo_example/README.md)
* [Example of backwards compatability in Go 1.10 with semantic import paths](https://github.com/myitcv/go-modules-by-example/blob/master/005_old_go/README.md)
* [Another example of package/project that has not yet been converted to a module](https://github.com/myitcv/go-modules-by-example/blob/master/006_not_yet_go_module/README.md)
* ...

See the [Feedback and TODO wiki](https://github.com/myitcv/go-modules-by-example/wiki/Feedback-TODO) for more up-to-date
commentary.

### Structure

A guide simply comprises a README.md and an accompanying bash script. The README is the human readable bit and the
script acts as a reproducible set of steps (that can be tested) for the guide. For example, the vgo tour has been
rewritten as a _Go modules by example_ guide:

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
assert "$? -eq 0" $LINENO
```

Assertions can be made within the script to ensure that everything is still "on track".

The corresponding README.md acts as a template for the guide itself, but crucially it can reference these blocks to
include the commands themselves and/or their output, e.g.:

    ```
    {{PrintBlock "install tools" -}}
    ```

Look at the raw [Go modules by example tour README.md](https://raw.githubusercontent.com/myitcv/go-modules-by-example/master/001_go_modules_tour/README.md)
and [corresponding script](https://github.com/myitcv/go-modules-by-example/blob/master/001_go_modules_tour/script.sh) for more examples.

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

The following two environment variables must be set:

```bash
GITHUB_USERNAME # your Github username
GITHUB_PAT      # a personal access token with public_repo scope
```

_[Create a new personal access token](https://github.com/settings/tokens/new)._

Ensure `egrunner` is installed (and on your PATH):

<!-- __TEMPLATE: go install myitcv.io/go-modules-by-example/cmd/egrunner
```
{{.Cmd}}
```
-->
```
go install myitcv.io/go-modules-by-example/cmd/egrunner
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

<!-- __TEMPLATE: go install myitcv.io/go-modules-by-example/cmd/egrunner myitcv.io/go-modules-by-example/cmd/mdreplace
```
{{.Cmd}}
```
-->
```
go install myitcv.io/go-modules-by-example/cmd/egrunner myitcv.io/go-modules-by-example/cmd/mdreplace
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

This project is:

* work-in-progress
* pending review
* likely to move somewhere else
