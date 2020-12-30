#!/bin/sh

## @brief ENTRYPOINT for interacting with the Ansible role tester
## @author Wesley Dean <info@kdaweb.com>
## @details
## This is the script that runs when the Ansible role tester images
## are instantiated as containers.
##
## Initially, this ran `ansible-playbook` and that was it.  Eventually,
## functionality was added to detect the name of the role being tested
## and use the test framework provided by `ansible-galaxy init`.
##
## Then, the functionality to "fix" the paths produced by the tester
## was added (i.e., instead of /rolename/ being displayed in output.
## it would preface paths with WORKSPACE (which can be set by Jenkins)
## so that tools that depend on the output of the test can point to
## the correct files.
##
## Finally, there were problems testing steps that rely on the
## functioning of previous steps.  For example, on Alpine Linux, if
## one relies on a package that's in the community repository (which
## is disabled by default), even if there are steps to enable the
## community repository earlier in the playbook, these steps would
## fail when using --check mode since those changes wouldn't have
## been made.  So, since the containers running the tests are
## ephemeral in nature (especially when run via `docker run --rm`)
## it may be acceptable to run the playbooks "for real" knowing that
## they won't change anything permanently.  So, runtype was added
## to support running playbooks for real, check mode, or syntax-check
## mode.
##
## @param connection how to connect to the image with --connect flag (default: local)
## @param runtype how to run (check (default), run, syntax, etc.)
## @param WORKSPACE path to prepend to container paths to make then back to the host system
## @param inventory the inventory string (e.g., filename) to run (default: tests/inventory)
## @param playbook the playbook file to run (default: tests/test.yml)
## @param logfile path to write the output of ansible-playbook (if the container is retained; defaut: /output.log)
## @param color set to `true` (default) to enable colors in the output or `false` to disable colors
## @rolespath the path to the playbook's `roles` directory (default: `..`)
## @retval 0 if everything ran successfully
## @retval 1 if something failed

workdir="$(pwd)"
rolename="$(sed -Ene 's/^[[:space:]]*-[[:space:]]([^:[:space:]]*)$/\1/p'  < tests/test.yml | head -1)"

connection="${connection:-local}"
inventory="${inventory:-tests/inventory}"
playbook="${playbook:-tests/test.yml}"
WORKSPACE="${WORKSPACE:-/}"
runtype="${runtype:-check}"
logfile="${logfile:-/output.log}"
color="${color:-true}"
rolespath="${rolespath:-..}"

case "$runtype" in
  [Rr]*) operation="" ;;
  [Cc]*) operation="--check" ;;
  [Ss]*) operation="--syntax-check" ;;
  *) operation="--check" ;;
esac

echo "Testing '$rolename'"

ln -fs "$workdir" "/$rolename"

export ANSIBLE_ROLES_PATH="$rolespath"
export ANSIBLE_FORCE_COLOR="$color"

ansible-playbook \
  $operation \
  --connection="$connection" \
  --inventory "$inventory" \
  "$playbook" \
  "$@" \
| tee "$logfile" \
| sed -Ee "s|/($rolename)(/.*)|$WORKSPACE/\1\2|g"

if [ "$operation" = "--syntax-check" ] \
&& grep -qE 'ERROR:' "$logfile" ; then
  exit 1
elif [ ! "$operation" = "--syntax-check" ] \
&& grep -qE 'failed=0' "$logfile" ; then
  exit 0
fi

# if we get here, either we're in syntax mode and
# we found 'ERROR:' or we're not in syntax mode
# and we did Not find 'failed=0', so.. something
# failed.
exit 1
