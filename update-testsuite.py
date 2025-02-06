#!/usr/bin/env python3

"""
Script to automatically update all tests in this repository based on the
status of the upstream repositories themselves. This will prepare a git
submodule-of-sorts (not literally) in `repos` with all the upstream
repos fetched into that one location. Tests will be diff'd against the merged
version of the upstream spec repo and the proposal repo, and if there's a
difference then the test is included.
"""

import os
import shutil
import subprocess
import sys
from datetime import datetime


class GitError(RuntimeError):
    def __init__(self, output, args):
        self.output = output
        self.args = args

    def __str__(self):
        cmd = ' '.join(self.args)
        desc = f'failed to run: git {cmd}'
        desc += f'\n\treturncode: {self.output.returncode}'
        if len(self.output.stdout) > 0:
            stdout = self.output.stdout.replace('\n', '\n\t\t')
            desc += f'\n\tstdout:\n\t\t{stdout}'
        return desc


def git(*args, quiet=False):
    """
    Helper to run a `git` command and handle the output/exit code in an
    ergonomic fashion.
    """
    if not quiet:
        print('running: git', *args)
    ret = subprocess.run(['git', *args], stdout=subprocess.PIPE, text=True)
    if ret.returncode != 0:
        raise GitError(ret, args)
    return ret.stdout.strip()


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

    def update(self):
        """
        Fetch the latest revision from this repository and store the revision
        within `self` of what was found.
        """
        Repo.git('fetch', self.url(), self.branch)
        self.rev = Repo.git('rev-parse', 'FETCH_HEAD', quiet=True)

    def url(self):
        return f'https://github.com/WebAssembly/{self.repo}'

    @staticmethod
    def git(*args, **kwargs):
        """
        Helper to run a `git` command within the `repos` repository.
        """
        return git('-C', 'repos', *args, **kwargs)

    def checkout_merge(self, spec=None):
        """
        Check out this repository to `repos` with a merge against `spec`
        if specified.

        Returns `False` if the merge fails.
        """
        Repo.git('checkout', '-B', 'try-merge')
        Repo.git('reset', '--hard', self.rev)

        if spec is None:
            return True

        try:
            # Attempt to merge with the `spec` repository
            Repo.git('merge', '-q', spec.rev, '-m', 'merge')
        except GitError:
            # If the merge failed try to ignore merge conflicts in non-test
            # directories as we don't care about those changes
            non_tests = ':(exclude)test/'
            Repo.git('checkout', '--ours', non_tests)
            Repo.git('add', non_tests)
            try:
                Repo.git('-c', 'core.editor=true', 'merge', '--continue')
            except GitError:
                # If all that failed then the merge couldn't be done.
                Repo.git('merge', '--abort')
                return False
        self.merged_rev = Repo.git('rev-parse', 'HEAD', quiet=True)
        return True

    def list_tests(self):
        """
        Return a list-of-triples where each triple is

          (path_to_test, git_path_of_test, destination_path_of_test)

        This is used to run diffs and copy the test to its final location.
        """
        tests = []
        for subdir in ['core', 'legacy']:
            for root, dirs, files in os.walk(f'repos/test/{subdir}'):
                for file in files:
                    path = os.path.join(root, file)
                    repo_path = os.path.relpath(path, 'repos')
                    ext = os.path.splitext(path)[1]
                    if ext != '.wast':
                        continue
                    dst = os.path.basename(path)
                    if subdir == 'legacy':
                        dst = 'legacy/' + dst
                    tests.append((path, repo_path, dst))
        return tests


def main():
    spec = Repo('spec')
    spec3 = Repo('spec', branch='wasm-3.0')

    repos = [
        spec3,
        Repo('threads'),
        Repo('exception-handling'),
        Repo('gc'),
        Repo('tail-call'),
        Repo('annotations'),
        Repo('function-references'),
        Repo('extended-const'),
        Repo('multi-memory'),
        Repo('relaxed-simd'),
        Repo('custom-page-sizes'),
        Repo('wide-arithmetic'),
    ]

    # Make sure that `repos` is a git repository
    if not os.path.isdir('repos'):
        git('init', 'repos')

    failed_merges = []
    updated = []

    # Update the spec itself, reset to the latest version of the spec, and then
    # copy all files from the upstream spec tests into this repository's own
    # suite of tests to run.
    spec.update()
    spec.checkout_merge()
    tests = []
    for path, _repo_path, dst in spec.list_tests():
        shutil.copyfile(path, dst)
        tests.append(dst)
    git('add', *tests, quiet=True)
    status = git('status', '-s', *tests, quiet=True)
    if len(status) > 0:
        updated.append(spec)

    # Process all upstream repositories and proposals.
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
        print('No spec changes found, not creating a new commit')
        return 0
    today = datetime.now().strftime("%Y-%m-%d")
    message = f'Auto-update for {today}\n\nUpdate repos:\n\n'
    for repo in updated:
        message += f'  {repo.dir}:\n'
        message += f'    {repo.url()}/commit/{repo.rev}\n'
    message += '\n'
    message += 'This change was automatically generated by `update-testsuite.py`'
    git('commit', '-a', '-m', message)
    return 0


if __name__ == '__main__':
    sys.exit(main())
