### Go modules by example

_Go modules by example_ is a series of work-along guides that look to help explain how [Go
modules](https://golang.org/cmd/go/#hdr-Modules__module_versions__and_more) work and how to get things done. They are
designed to complement the official Go documentation and the [Go modules
wiki](https://github.com/golang/go/wiki/Modules).

The guides are being released in no particular order and will instead be curated into a more cogent order/structure (in
conjunction with the modules wiki) at a later date.

The release-ordered list of guides:

* [How to use submodules](009_submodules/README.md)
* [Using modules to manage
  vendor](008_vendor_example/README.md)
* [Creating a module download cache
  "vendor"](012_modvendor/README.md)
* [Using `gohack` to "hack" on
  dependencies](011_using_gohack/README.md)
* [Migrating Buffalo from `dep` to go
  modules](003_migrate_buffalo/README.md)
* [Tools as dependencies](010_tools/README.md)
* [Cyclic module dependencies](013_cyclic/README.md)
* [Visually analysing module dependencies](014_mod_graph/README.md)
* [Semantic import versioning by example](015_semantic_import_versioning/README.md)
* [Options for repository structure with multiple major versions](016_major_version_repo_strategy/README.md)
* [Using `gobin` to install/run tools](017_using_gobin/README.md)

WIP guides:

* [The go modules tour](001_go_modules_tour/README.md) (a
  rewrite of the original vgo tour)
* [Using go modules with
  gopkg.in](002_using_gopkg_in/README.md)
* [Using a package that has not been converted to go
  modules](004_echo_example/README.md)
* [Example of backwards compatibility in Go 1.10 with semantic import
  paths](005_old_go/README.md)
* [Another example of package/project that has not yet been converted to a
  module](006_not_yet_go_module/README.md)
* [Forking a project which has not yet been converted to a Go
  module](007_old_code_replace/README.md)
* ...

Wikis:

* [FAQ](https://github.com/go-modules-by-example/index/wiki/FAQ)
* [TODO](https://github.com/go-modules-by-example/index/wiki/TODO)
* [Feedback](https://github.com/go-modules-by-example/index/wiki/Feedback)

### Contributing

See [Contributing](CONTRIBUTING.md).

### Caveats

This project is work-in-progress. Feedback/PRs welcome.

### Credits

With particular thanks (in no particular order) to:

* [ajstarks](https://github.com/ajstarks)
* [bcmills](https://github.com/bcmills)
* [marwan-at-work](https://github.com/marwan-at-work)
* [mvdan](https://github.com/mvdan)
* [rogpeppe](https://github.com/rogpeppe)
* [rsc](https://github.com/rsc)
* [thepudds](https://github.com/thepudds)
