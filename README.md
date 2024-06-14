Amalgamated WebAssembly Test Suite
==================================

This repository holds a mirror of the WebAssembly core testsuite which is
maintained [here](https://github.com/WebAssembly/spec/tree/main/test/core),
as well as the tests from the various [proposals
repositories](https://github.com/WebAssembly/proposals/blob/master/README.md).

In addition it also contains tests from various proposals which are currently
forks of the primary spec repo.

To add new tests or report problems in existing tests, please file issues and
PRs within the spec or individual proposal repositories rather than within this
mirror repository.


## Updating this repository

This repository is updated weekly on Wednesday via automated pull requests.
Maintainers can also
[manually trigger an update](https://github.com/WebAssembly/testsuite/actions/workflows/autoupdate.yml).

Contributors can update tests by running the `./update-testsuite.sh` script and
making a pull request.
