#!/bin/sh

ANSIBLE_ROLES_DIR=.. \
ansible-playbook --check -i tests/inventory tests/test.yml "$@"
