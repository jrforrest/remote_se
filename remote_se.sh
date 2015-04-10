#!/bin/sh

# Set up environment for a remote session on a remote machine
#
# TODO:
#  - tmpfile cleanup on exit

make_bootstrap() {
# This has to be un-indented because I'm using spaces in this file and not
# tabs
cat >$BOOTSTRAP_PATH <<-EOF
  set -o vi 
  cd $REMOTE_HOME
  export HOME=${REMOTE_HOME}
  /bin/bash -l
EOF
  chmod +x $BOOTSTRAP_PATH
}

# Produce a manifest file with full paths to the local files
make_manifest() {
  while read filename; do
    echo ${HOME}/$filename
  done <$MANIFEST_FILE >$TMP_MANIFEST_PATH

  # Add the bootstrap file path to the manifest file
  echo $BOOTSTRAP_PATH >>$TMP_MANIFEST_PATH
  echo $tmp_manifest_file
}

put_manifest_files() {
  # This is kind of a hack that uses --rsync-path to run a remote
  # command to create the dest dir for the remote files.
  # This would probably be better accomplished by just running an SSH
  # command prior.
  rsync --rsync-path="mkdir -p ${REMOTE_DIR} && rsync" \
        -a --files-from=$TMP_MANIFEST_PATH / ${REMOTE}:${REMOTE_DIR}
}

ssh_with_home() {
  ssh -t $REMOTE "${REMOTE_DIR}/${BOOTSTRAP_PATH}" $@
}

cleanup() {
  rm $TMP_MANIFEST_PATH $BOOTSTRAP_PATH
}

_mktemp() {
  mktemp --tmpdir remote_home_${1}_XXXXXX.${2}
}

MANIFEST_FILE=$1
REMOTE=$2
shift
shift

# The tmp manifest is a file containing full paths to all the files we
# want to use on the remote system
TMP_MANIFEST_PATH=`_mktemp manifest lst`

# The bootstrap file is generated here
BOOTSTRAP_PATH=`_mktemp bootstrap sh`

REMOTE_DIR=/tmp/${USER}-`hostname`_home
REMOTE_HOME=${REMOTE_DIR}${HOME}

# If this script gets SIGTERM'd we should still clean up our tmpfiles
trap "cleanup" TERM
set -e

# If this file is being sourced, let's just make the vars and funcs available
# but don't execute anything
if [ "$_" = "$0" ]; then
  make_bootstrap
  make_manifest
  put_manifest_files
  ssh_with_home $@
fi
