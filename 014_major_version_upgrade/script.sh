echo "cloning our maturelib that we want to upgrade"
git clone https://github.com/athens-artifacts/maturelib.git
echo "installing the mod helper command"
go install github.com/marwan-at-work/mod/cmd/mod
cd maturelib
echo "current go.mod file looks like this:"
cat go.mod
echo "current sub package looks like this:"
cat subone/subone.go
echo "running mod upgrade to go from v2 to v3"
mod upgrade
echo "mod upgrade finished. Here's what go.mod looks like now:"
cat go.mod
echo "and here's what the sub package looks like:"
cat subone/subone.go