#!/bin/sh

workdir="$(pwd)"
rolename="$(sed -Ene 's/^[[:space:]]*-[[:space:]]([^:[:space:]]*)$/\1/p'  < tests/test.yml)"

echo "Testing '$rolename'"

ln -fs "$workdir" "/$rolename"

export ANSIBLE_ROLES_PATH=".."

ansible-playbook \
  --connection=local \
  --check \
  --inventory tests/inventory \
  tests/test.yml \
  "$@"
