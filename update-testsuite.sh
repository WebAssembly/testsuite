#!/bin/bash
set -e
set -u
set -o pipefail

repos='spec threads simd exception-handling gc bulk-memory-operations tail-call nontrapping-float-to-int-conversions multi-value host-bindings sign-extension-ops mutable-global'

log_and_run() {
    echo $*
    if ! $*; then
        echo "sub-command failed: $*"
        exit
    fi
}

update_repo() {
    local repo=$1
    pushd repos >/dev/null
        if [ -d ${repo} ]; then
            pushd ${repo} >/dev/null
                log_and_run git fetch origin
                log_and_run git reset origin/master --hard
            popd >/dev/null
        else
            log_and_run git clone https://github.com/WebAssembly/${repo}
        fi
    popd >/dev/null
}

echo -e "update repos\n" > commit_message

for repo in ${repos}; do
    echo "++ updating ${repo}"
    update_repo ${repo}

    if [ "${repo}" = "spec" ]; then
        wast_dir=.
        log_and_run cp repos/${repo}/test/core/*.wast ${wast_dir}
    else
        wast_dir=proposals/${repo}
        mkdir -p ${wast_dir}

        # Don't add old versions of spec tests.
        pushd repos/${repo} >/dev/null
            for new in test/core/*.wast; do
                sha=$(git hash-object ${new})
                if ! git -C ../../repos/spec cat-file -t ${sha} >/dev/null 2>&1; then
                    log_and_run cp ${new} ../../${wast_dir}
                fi
            done
        popd >/dev/null
    fi

    # Check whether any files were updated.
    if [ $(git status -s ${wast_dir}/*.wast | wc -l) -ne 0 ]; then
        git add ${wast_dir}/*.wast

        repo_sha=$(git -C repos/${repo} log --max-count=1 --pretty=oneline | sed -e 's/ .*//')
        echo "  ${repo}: ${repo_sha}" >> commit_message
    fi

    echo -e "-- ${repo}\n"
done

git commit -a -F commit_message
# git push

echo "done"
