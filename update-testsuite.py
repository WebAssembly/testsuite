#!/usr/bin/env python3

# Script to automatically update all tests in this repository based on the
# status of the upstream repositories themselves. This will prepare a git
# submodule-of-sorts (not literally) in `repos/spec` with all the upstream repos
# fetched into that one location. Tests will be diff'd against the merged
# version of the upstream spec repo and the proposal repo, and if there's a
# difference then the test is included.

import subprocess
import os
import shutil

def main():
    spec = Repo('spec')
    spec3 = Repo('spec', branch='wasm-3.0')

    repos = []
    repos.append(spec3)
    repos.append(Repo('threads'))
    repos.append(Repo('exception-handling'))
    repos.append(Repo('gc'))
    repos.append(Repo('tail-call'))
    repos.append(Repo('annotations'))
    repos.append(Repo('function-references'))
    repos.append(Repo('memory64', upstream=spec3))
    repos.append(Repo('extended-const'))
    repos.append(Repo('multi-memory'))
    repos.append(Repo('relaxed-simd'))
    repos.append(Repo('custom-page-sizes'))
    repos.append(Repo('wide-arithmetic'))

    # Make sure that `repos/spec` is a git repository
    if not os.path.isdir('repos/spec'):
        git('init', 'repos/spec')

    # Update the spec itself, reset to the latest version of the spec, and then
    # copy all files from the upstream spec tests into this repository's own
    # suite of tests to run.
    spec.update()
    spec.checkout_merge()
    for path, _repo_path, dst in spec.list_tests():
        shutil.copyfile(path, dst)

    # Process all upstream repositories and proposals.
    failed_merges = []
    updated = []
    for repo in repos:
        # Repositories may not be mergable with the upstream spec repository in
        # which case we skip them and print an informational message at the end.
        repo.update()
        if not repo.checkout_merge(spec):
            failed_merges.append(repo)
            continue

        # Blow away this proposal's list of tests if it exists.
        dstdir = f'proposals/{repo.dir}'
        if os.path.isdir(dstdir):
            shutil.rmtree(dstdir)

        # For all tests in this proposal run a diff against the upstream
        # revision. If the diff is non-empty then include this test by copying
        # it to its destination.
        for path, repo_path, dst in spec.list_tests():
            upstream = repo.upstream or spec

            diff = repo.git('diff', upstream.rev, repo.merged_rev, '--', repo_path, quiet=True)
            if len(diff) == 0:
                continue

            dst = os.path.join(dstdir, dst)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copyfile(path, dst)

        # If anything changed, then this is an updated proposal, and take note
        # of that for later.
        git('add', dstdir)
        status = git('status', '-s', dstdir)
        if len(status) > 0:
            updated.append(repo)

    for repo in failed_merges:
        print('!! failed to update:', repo.url())

    # If anything was updated, make a commit message indicating as such.
    if len(updated) == 0:
        return
    message = "Update repos:\n\n"
    for repo in updated:
        message += f"  {repo.dir}:\n"
        message += f"    {repo.url()}/commit/{repo.rev}\n"
    message += "\n"
    message += "This change was automatically generated by `update-testsuite.py`"
    git('commit', '-a', '-m', message)

class Repo:
    def __init__(self, repo, branch = 'main', upstream = None):
        self.repo = repo
        if branch == 'main':
            self.dir = repo
        else:
            self.dir = branch
        self.branch = branch
        self.upstream = upstream

    def __str__(self):
        repo = f'WebAssembly/{self.repo}'
        if self.branch != 'main':
            repo += f'@{self.branch}'
        return repo

    # Fetch the latest revision from this repository and store the revision
    # within `self` of what was found.
    def update(self):
        self.git('fetch', self.url(), self.branch)
        self.rev = self.git('rev-parse', 'FETCH_HEAD', quiet=True)

    def url(self):
        return f'https://github.com/WebAssembly/{self.repo}'

    # Helper to run a `git` command within the `repos/spec` repository.
    def git(self, *args, **kwargs):
        return git('-C', 'repos/spec', *args, **kwargs)

    # Check out this repository to `repos/spec` with a merge against `spec`
    # if specified.
    #
    # Returns `False` if the merge fails.
    def checkout_merge(self, spec=None):
        self.git('checkout', '-B', 'try-merge')
        self.git('reset', '--hard', self.rev)

        if spec is None:
            return True

        try:
            # Attempt to merge with the `spec` repository
            self.git('merge', '-q', spec.rev, '-m', 'merge')
        except GitError:
            # If the merge failed try to ignore merge conflicts in non-test
            # directories as we don't care about those changes
            non_tests = ":(exclude)test/"
            self.git('checkout', '--ours', non_tests)
            self.git('add', non_tests)
            try:
                self.git('-c', 'core.editor=true', 'merge', '--continue')
            except GitError:
                # If all that failed then the merge couldn't be done.
                self.git('merge', '--abort')
                return False
        self.merged_rev = self.git('rev-parse', 'HEAD', quiet=True)
        return True

    # Return a list-of-triples where each triple is
    #
    #   (path_to_test, git_path_of_test, destination_path_of_test)
    #
    # This is used to run diffs and copy the test to its final location.
    def list_tests(self):
        tests = []
        for subdir in ['core', 'legacy']:
            for root, dirs, files in os.walk(f'repos/spec/test/{subdir}'):
                for file in files:
                    path = os.path.join(root, file)
                    repo_path = os.path.relpath(path, 'repos/spec')
                    _, ext = os.path.splitext(path)
                    if ext != '.wast':
                        continue
                    _, dst = os.path.split(path)
                    if subdir == 'legacy':
                        dst = 'legacy/' + dst
                    tests.append((path, repo_path, dst))
        return tests


# Helper to run a `git` command and handle the output/exit code in an ergonomic
# fashion.
def git(*args, quiet=False):
    if not quiet:
        print('running: git', *args)
    ret = subprocess.run(["git", *args], stdout=subprocess.PIPE)
    if ret.returncode != 0:
        raise GitError(ret, args)
    return ret.stdout.decode('utf-8').strip()


class GitError(RuntimeError):
    def __init__(self, output, args):
        self.output = output
        self.args = args

    def __str__(self):
        desc = f'failed to run: git {" ".join(self.args)}'
        desc += f"\n\treturncode: {self.output.returncode}"
        if len(self.output.stdout) > 0:
            stdout = self.output.stdout.decode('utf-8')
            stdout = stdout.replace('\n', '\n\t\t')
            desc += f"\n\tstdout:\n\t\t{stdout}"
        return desc


if __name__ == '__main__':
    main()
