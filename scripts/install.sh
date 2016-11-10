#!/bin/sh

set -e

./node_modules/bs-platform/bin/bsc.exe -bs-package-name orme -bs-package-output lib/js -I src -c -bs-files src/*.mli src/*.ml

# install
cp ./src/*.cm* ./lib/ocaml
