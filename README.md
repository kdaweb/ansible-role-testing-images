# Ansible Role Tester

This is a series of Dockerfiles that can be used to test Ansible roles on
various platforms, including:

  * Ubuntu (18.04, 20.04, 20.10, 21.04)
  * CentOS (7, 8)
  * Alpine (3.12)
  * Amazon Linux (2)

## Image Names

The images built here will have tags for the various releases; for example,
there is an image called 'centos' which has tags for 7 and 8 (i.e.
'centos:7' and 'centos:8').

The version of Ansible that is installed is codified in the name of the
images that are created; by default, they are of the form:

  wesleydean/ansible-VERSION-tester-DISTRIBUTION:VERSION

For example, the image to test Ansible v2.9 on Ubuntu 20.10 is:

  wesleydean/ansible-2.9-tester-ubuntu:20.10

## Using a Tester Image

To run the image, use `docker run` with the directory of the Ansible role
to be tested bind-mounted to `/workdir` like this:

```sh
docker run --rm -it -v "$(pwd):/workdir" wesleydean/ansible-2.9-tester-ubuntu:20.10
```

To determine the directory to mount, use the parent of the 'tests/' directory.

### Specifying Options to ansible-playbook

The ENTRYPOINT for the tester calls `ansible-playbook` to perform tests with
the `--check` flag.  Any arguments passed to the image (i.e., the CMD) are
appended to `ansible-playbook` when it's run.

### Network Connectivity

The tester images, by default, are set to use 'local' connections (i.e.,
not over SSH; `--connection=local`).  This can be modified by setting
the 'connection' environment variable:

```sh
connection=local docker run [...]
```

This should help circumvent SSH-related issues (e.g., authentication,
private key passing, etc.).

The `ansible-playbook` command is passed the location of the test
inventory (`tests/inventory`) which, by default, includes the line 'localhost'.

### Running the Role

The contents of the test playbook (`tests/test.yml`) are used to run the role.
By default, this includes an item for the role being tested set to run on
all hosts.

The tester will run the first role, only.  (why?  this is a role tester,
not a playbook tester)

### Run Types

The tester supports multiple "run types":

* check / dry-run
* syntax-check
* run / ephemeral

By default, check / dry-run mode is used.  This is the same as running
`ansible-playbook` with the `--check` flag.

There are times when check / dry-run mode is insufficient, such as when
some steps are required for later steps.  For example, by default, on
Alpine Linux, the community repository is disabled; so, if a package
is to be installed from the community repository, even if there are steps
to enable the repository on the system, in check mode, those changes
won't be made and the package install will fail.

Therefore, run / ephemeral allows the tester to actually make changes
to the system.  Because the tester, by default, uses ephemeral containers
that are removed upon completion of the test, each test run will take
place on an identical, base system -- none of the changes carry through.

This is assuming the use of `docker run --rm` which removes the container
upon termination.

Finally, there is a 'syntax-check' mode which verifies that the syntax
for the role is correct.  This may be necessary when it's not possible
to use run / ephemeral or check / dry-run mode.  It's likely highly
redundant to perform a syntax-check on multiple different platforms.

To specify the mode, set the 'runtype' variable to one of:

* check
* dry-run
* run
* ephemeral
* syntax-check

### Correcting Path Display

When the containers run with the role bind-mounted, the path that
`ansible-playbook` sees is, by default, the name of the role being
tested.  When the entrypoint runs, it determines the role to be
tested and then creates a symlink in the container so that the
role mounted at `/workdir/` also appears to be in a directory named
for the role.  For example, if the role's name is `example` then
a symlink will be created at `/example/` that points to `/workdir/`.

This is convenient for allowing `ansible-playbook` to find the role
to be tested, but it may cause problems with the display of paths
relative to the host system.  For example, a CI/CD system or an
editor may specify a file named `/path/to/role/dir/filename.yml`
but the tester image sees that file as `/role/dir/filename.yml` and
will report messages based on its location.

Therefore, if the `WORKSPACE` environment variable is set, the
output will be corrected to prepend the value of `WORKSPACE` to the
beginning of paths.  The `WORKSPACE` variable should have the path
of the directory where role is stored on the filesystem; typically,
this is `pwd` from the role's directory or `git rev-parse --show-toplevel`
from a local git repository.

This environment variable is populated by Jenkins automatically;
one need only supply it to the container (`docker run -e "WORKSPACE=$WORKSPACE"`).

If this is not a concern and/or no value is set, the path correcting
functionality won't be applied.

### Results

The tester will return `0` (true) if the tester successfully ran or
`1` (false) if the tester failed.

### Other Variables

* connection: how to connect to the container; default is `local`
* inventory: the inventory to use; default is `tests/inventory`
* playbook: the playbook to use; default is `tests/test.yml`
* logfile: where to store the output of `ansible-playbook`; default is `/output.log`
* color: whether or not to colorize output; default is `true`
* rolespath: path to where `ansible-playbook` should look for roles; default is `..`
