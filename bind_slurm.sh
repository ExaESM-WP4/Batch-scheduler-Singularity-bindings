#!/bin/bash

# Get system-specific bindings to use here.
CONFIG=batch-bindings.conf
source ${CONFIG} || { echo ${CONFIG} not found. Make sure to link or create it!; exit; }
echo Will use: $(readlink batch-bindings.conf)

# Check if singularity is available.
singularity --version || { echo Singularity not found... exiting.; exit; }

# Get Singularity image path.
# We'll Preserve the original command and then parse all inputs until we find an image file.

ORIGINAL_SINGULARITY_COMMAND="$@"
echo Will execute: ${ORIGINAL_SINGULARITY_COMMAND}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    *.sif) IMAGE="$1" ;;
    *) ;;
  esac
  shift
done

echo Enable host SLURM user for: ${IMAGE}

# Prepare binding of system-specific SLURM.
#
# We'll filter system users and if there is a slurm user, we'll add it to the 
# /etc/passwd and /etc/group files used in the container.
# 
# This is done very similar to how singularity enables the human user inside the container:
# First, briefly start the container to get /etc/passwd and /etc/groups from with, then
# append users and groups to the files and bind the files when finally starting the container.

# create temporary directory that'll be deleted automatically once the script exists successfully
TEMPDIR=$(mktemp -d $(pwd)/tmp.XXXXXXXX)
echo Temporary directory: ${TEMPDIR}
trap "echo Deleting: ${TEMPDIR}; rm -rf ${TEMPDIR}" 0

# Extract user and group info from container and (mayby) append the slurm user
singularity exec ${IMAGE} cp -p /etc/passwd ${TEMPDIR}/etc_passwd
singularity exec ${IMAGE} cp -p /etc/group ${TEMPDIR}/etc_group
grep slurm /etc/passwd >> ${TEMPDIR}/etc_passwd
grep slurm /etc/group >> ${TEMPDIR}/etc_group

# Note that if system users are not managed in /etc/..., we could use getent:
# getent passwd | grep slurm >> ${TEMPDIR}/etc_passwd
# getent group | grep slurm >> ${TEMPDIR}/etc_group

# Create bind paths
RTEMPDIR=$(basename $TEMPDIR) # get relative temp dir path

MERGED_PASSWD_GROUP="\
${RTEMPDIR}/etc_passwd:/etc/passwd,\
${RTEMPDIR}/etc_group:/etc/group\
"

# Setup Singularity bind mount and (library) path environment.

if [[ ! -z "$SCHEDULER_PREPEND_PATH" ]]; then
export SINGULARITYENV_PREPEND_PATH=${SCHEDULER_PREPEND_PATH}${SINGULARITYENV_PREPEND_PATH:+:$SINGULARITYENV_PREPEND_PATH}
echo SINGULARITYENV_PREPEND_PATH: "${SINGULARITYENV_PREPEND_PATH}"
fi

if [[ ! -z "${SCHEDULER_LD_LIBRARY_PATH}" ]]; then
export SINGULARITYENV_LD_LIBRARY_PATH=${SCHEDULER_LD_LIBRARY_PATH}${SINGULARITYENV_LD_LIBRARY_PATH:+:$SINGULARITYENV_LD_LIBRARY_PATH}
echo SINGULARITYENV_LD_LIBRARY_PATH: "${SINGULARITYENV_LD_LIBRARY_PATH}"
fi

SINGULARITY_BIND=${SCHEDULER_COMMANDS},${SCHEDULER_SYSTEM_SPECS}
SINGULARITY_BIND=${SINGULARITY_BIND},${MERGED_PASSWD_GROUP}
export SINGULARITY_BIND

echo SINGULARITY_BIND: "${SINGULARITY_BIND}"

# Execute original Singularity command.

${ORIGINAL_SINGULARITY_COMMAND}
