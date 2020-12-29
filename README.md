# ansible-role-testing-images

This is a series of Dockerfiles that can be used to test Ansible roles on
various platforms, including:

  * Ubuntu (18.04, 20.04, 20.10, 21.04)
  * CentOS (7, 8)
  * Alpine (3.12)

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

The tester will run the first role, only.
