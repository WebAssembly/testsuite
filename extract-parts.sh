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

mkdir -p valid invalid malformed
rm -f valid/*.wasm
rm -f invalid/*.wasm
rm -f malformed/*.wat

for wat in *.wat; do
    base="${wat##*/}"
    json="invalid/${base%.wat}.json"
    "$wabtbin/wat2wasm" --spec "$wat" -o "$json"
    rm "$json"
done

mv invalid/*.wat malformed

for wasm in invalid/*.wasm; do
    if "$wabtbin/wasm2wat" "$wasm" -o invalid/t.wat 2>/dev/null && \
       "$wabtbin/wat2wasm" invalid/t.wat -o /dev/null 2>/dev/null ; then
        mv "$wasm" valid
    fi
done
rm invalid/t.wat
