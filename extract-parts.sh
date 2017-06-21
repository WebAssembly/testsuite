#!/bin/bash
set -e
set -u
set -o pipefail

# This script extracts the modules from the testsuite test files into
# individual files in the following directories:
#  - valid - valid wasm modules
#  - invalid - wasm modules that fail to validate
#  - malformed - wasm text tests that fail to parse

wabt="../wabt"
wabtbin="$wabt/out"

mkdir -p valid invalid malformed fail
rm -f valid/*.wasm
rm -f invalid/*.wasm
rm -f malformed/*.wast

for wast in *.wast; do
    base="${wast##*/}"
    json="invalid/${base%.wast}.json"
    "$wabtbin/wast2wasm" --spec "$wast" -o "$json"
    rm "$json"
done

mv invalid/*.wast malformed

for wasm in invalid/*.wasm; do
    if ../wabt/out/wasm2wast "$wasm" -o invalid/t.wast 2>/dev/null && \
       ../wabt/out/wast2wasm invalid/t.wast -o /dev/null 2>/dev/null ; then
        mv "$wasm" valid
    fi
done
rm invalid/t.wast
