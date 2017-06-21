#!/bin/bash
set -e
set -u
set -o pipefail

spec="../spec"

pushd "$spec" >/dev/null
    git checkout master
    git fetch origin
    git merge origin/master
    id=$(git log --max-count=1 --pretty=oneline | sed -e 's/ .*//')
popd >/dev/null

cp "$spec"/test/core/*.wast .
cp "$spec"/test/core/expected-output/*.log expected-output

for new in *.wast expected-output/*.log; do
    git add "$new" || :
done

git commit -a -m "update to spec repo $id"
git push

echo updated to spec repo $id
