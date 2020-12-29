#!/bin/sh

workdir="$(pwd)"
rolename="$(sed -Ene 's/^[[:space:]]*-[[:space:]]([^:[:space:]]*)$/\1/p'  < tests/test.yml | head -1)"

if [ -z "$connection" ] ; then
  connection="local"
fi

echo "Testing '$rolename'"

ln -fs "$workdir" "/$rolename"

export ANSIBLE_ROLES_PATH=".."

ansible-playbook \
  --connection=$connection \
  --check \
  --inventory tests/inventory \
  tests/test.yml \
  "$@"
