#!/bin/bash
# Update tests based on upstream repositories.
set -e
set -u
set -o pipefail

non_tests=":(exclude)test/"

repos='
  spec
  threads
  exception-handling
  gc
  tail-call
  annotations
  function-references
  memory64
  extended-const
  multi-memory
  relaxed-simd
  custom-page-sizes
  wide-arithmetic
  wasm-3.0
'

log_and_run() {
    echo ">>" $*
    if ! $*; then
        echo "sub-command failed: $*"
        exit
    fi
}

try_log_and_run() {
    echo ">>" $*
    $*
}

pushdir() {
    pushd $1 >/dev/null || exit
}

popdir() {
    popd >/dev/null || exit
}

update_repo() {
    local dir=$1
    local branch=main
    local repo=$dir
    if [ "${repo}" == "wasm-3.0" ]; then
      branch="wasm-3.0"
      repo="spec"
    fi
    pushdir repos
        if [ -d ${dir} ]; then
            log_and_run git -C ${dir} fetch origin
            log_and_run git -C ${dir} reset origin/${branch} --hard
        else
            log_and_run git clone https://github.com/WebAssembly/${repo} ${dir} --branch ${branch}
        fi

        # Add upstream spec as "spec" remote.
        if [ "${dir}" != "spec" ]; then
            pushdir ${dir}
                if ! git remote | grep spec >/dev/null; then
                    log_and_run git remote add spec https://github.com/WebAssembly/spec
                fi

                log_and_run git fetch spec
            popdir
        fi
    popdir
}

set_upstream() {
    local repo=$1
    upstream="main"
    [ "${repo}" == "memory64" ] && upstream="wasm-3.0"
    echo "set_upstream $upstream"
}

merge_with_spec() {
    local repo=$1

    [ "${repo}" == "spec" ] && return

    set_upstream ${repo}

    local head_ref=origin/HEAD
    [ "${repo}" == "wasm-3.0" ] && head_ref=origin/wasm-3.0

    pushdir repos/${repo}
        # Create and checkout "try-merge" branch.
        if ! git branch | grep try-merge >/dev/null; then
            log_and_run git branch try-merge $head_ref
        fi
        log_and_run git checkout try-merge

        # Attempt to merge with upstream branch in spec repo.
        log_and_run git reset $head_ref --hard
        try_log_and_run git merge -q spec/$upstream -m "merged"
        if [ $? -ne 0 ]; then
            # Ignore merge conflicts in non-test directories.
            # We don't care about those changes.
            try_log_and_run git checkout --ours ${non_tests}
            try_log_and_run git add ${non_tests}
            try_log_and_run git -c core.editor=true merge --continue
            if [ $? -ne 0 ]; then
                git merge --abort
                popdir
                return 1
            fi
        fi
    popdir
    return 0
}


echo -e "Update repos\n" > commit_message

failed_repos=
any_updated=0

for repo in ${repos}; do
    echo "++ updating ${repo}"
    update_repo ${repo}

    if ! merge_with_spec ${repo}; then
        echo -e "!! error merging ${repo}, skipping\n"
        failed_repos="${failed_repos} ${repo}"
        continue
    fi

    if [ "${repo}" = "spec" ]; then
        wast_dir=.
        log_and_run cp $(find repos/${repo}/test/core -name \*.wast) ${wast_dir}
    else
        wast_dir=proposals/${repo}
        # Start by removing any existing test files for this proposal.
        log_and_run rm -rf ${wast_dir}/
        mkdir -p ${wast_dir}

        # Checkout the corresponding upstream branch in the spec repo
        set_upstream ${repo}
        pushdir repos/spec
          try_log_and_run git checkout origin/${upstream}
        popdir

        # Don't add tests from proposal that are the same as spec.
        pushdir repos/${repo}
            for new in $(find test/core -name \*.wast); do
                old=../../repos/spec/${new}
                if [[ ! -f ${old} ]] || ! diff ${old} ${new} >/dev/null; then
                    log_and_run cp ${new} ../../${wast_dir}/
                fi
            done
            for new in $(find test/legacy -name \*.wast); do
                old=../../repos/spec/${new}
                if [[ ! -f ${old} ]] || ! diff ${old} ${new} >/dev/null; then
                    mkdir -p ../../${wast_dir}/legacy/
                    log_and_run cp ${new} ../../${wast_dir}/legacy/
                fi
            done
        popdir
    fi

    # Check whether any files were removed.
    for old in $(find ${wast_dir} -maxdepth 1 -name \*.wast); do
      new=$(find repos/${repo}/test/core -name ${old##*/})
      if [[ ! -f ${new} ]]; then
          log_and_run git rm ${old}
      fi
    done

    # Check whether any files were updated.
    if [ $(git status -s ${wast_dir} | wc -l) -ne 0 ]; then
        log_and_run git add ${wast_dir}

        branch=main
        dir=${repo}
        if [ "${repo}" == "wasm-3.0" ]; then
          branch="wasm-3.0"
          repo="spec"
        fi
        repo_sha=$(git -C repos/${dir} log --max-count=1 --oneline origin/$branch | sed -e 's/ .*//')
        echo "  ${dir}:" >> commit_message
        echo "    https://github.com/WebAssembly/${repo}/commit/${repo_sha}" >> commit_message
        any_updated=1
    fi

    echo -e "-- ${repo}\n"
done

if [ -n "${failed_repos}" ]; then
  echo "!! failed to update repos: ${failed_repos}"
fi

if [ "$any_updated" = "0" ]; then
  echo "no tests were updated from upstream repositories"
else
  echo "" >> commit_message
  echo "This change was automatically generated by \`update-testsuite.sh\`" >> commit_message
  git commit -a -F commit_message
  # git push
fi


echo "done"
