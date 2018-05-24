### `**This is a work-in-progress and pending review. Please do not link to this for now.**`

### vgo by example

vgo by example is a series of work-along guides that look to help explain how vgo works and how to get things done with vgo.

* [The vgo tour](https://github.com/myitcv/vgo-by-example/blob/master/001_vgo_tour/README.md) (rewritten as a vgo-by-example)
* [Using vgo with gopkg.in](https://github.com/myitcv/vgo-by-example/blob/master/002_using_gopkg_in/README.md)
* ...

### Structure

A guide simply comprises a README.md and an accompanying bash script. The README is the human readable bit and the
script acts as a reproducible set of steps (that can be tested) for the guide. For example, the vgo tour has been
rewritten as a vgo by example guide:

```
$ ls vgo_tour
README.md
script.sh
```

script.sh contains, as its name suggests, the overall script for the guide. It includes a pre-amble that defines a
number of helper functions for testing the script, followed by the header:

```
# **START**
```

This marks the start of the script.

What follows are a number of optionally commented "blocks". For example, the following block is labelled `"go get vgo"`
and comprises all the contiguous lines that follow the special `# block:` comment:

```
# block: go get vgo
go get -u golang.org/x/vgo
assert "$? -eq 0" $LINENO
```

Assertions can be made within the script to ensure that everything is still "on track".

The corresponding README.md acts as a template for the guide itself, but crucially it can reference these blocks to
include the commands themselves and/or their output, e.g.:

    ```
    {{PrintBlock "go get vgo" -}}
    ```

Look at the raw [vgo tour README.md](https://raw.githubusercontent.com/myitcv/vgo-by-example/master/001_vgo_tour/README.md)
and [corresponding script](https://github.com/myitcv/vgo-by-example/blob/master/001_vgo_tour/script.sh) for more examples.

### Testing scripts

To ensure reproducibility and isolation, scripts are run in a Docker container; the
[`golang`](https://hub.docker.com/_/golang/) container is used:

```
docker pull golang
```

The following two environment variables must be set:

```bash
GITHUB_USERNAME # your Github username
GITHUB_PAT      # a personal access token with public_repo scope
```

_[Create a new personal access token](https://github.com/settings/tokens/new)._

Ensure `egrunner` is installed (and on your PATH):

```
go install myitcv.io/vgo-by-example/cmd/egrunner
```

Now run in debug mode to see real-time output:

```
egrunner -debug ./001_vgo_tour/script.sh
```

### Regenerating a guide

First ensure `mdreplace` and `egrunner` are installed (and on your PATH):

```
go install myitcv.io/vgo-by-example/cmd/mdreplace myitcv.io/vgo-by-example/cmd/egrunner
```

Then re-run `mdreplace` on a guide template, e.g. for the vgo tour:

```
mdreplace -w ./001_vgo_tour/README.md
```

### Caveats and TODO

This project is:

* work-in-progress
* pending review
* likely to move somewhere else

TODO:

* Automate the building of a table of contents in this README
* Make this a `vgo` project
* Move away from vendor of `mvdan.cc/sh` - currently vendoring to work around an issue with single statement printing.
