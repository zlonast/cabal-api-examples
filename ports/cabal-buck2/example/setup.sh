#!/usr/bin/env bash
# Generates the buck2 build of this example with cabal-buck2, using the buck2
# support code of this repository (the buck2/ submodule). Run it again when
# GHC or the dependencies change. The command can be set with $CABAL_BUCK2, for
# example to a cabal-buck2 that is not installed.
#
# The dependencies are built with profiling as well as without it (it doesn't
# imply --disable-library-vanilla), so that this one build covers the dev,
# opt and prof modes.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# An absolute path: buck2 does not accept a symlink with ".." in it.
ln -sfn "$(cd ../buck2 && pwd)" buck2

${CABAL_BUCK2:-cabal buck2} --enable-tests --enable-profiling "$@"

cat <<'MSG'

Done. Now try:
  cd example
  buck2 build //...          # dev
  buck2 test //...
  buck2 build -m opt //...   # opt
  buck2 test -m opt //...
  buck2 build -m prof //...  # profiling
  buck2 test -m prof //...
MSG
