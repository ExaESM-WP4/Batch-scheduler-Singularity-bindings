#!/bin/bash

# Get system-specific bindings to use here.
CONFIG=scheduler-bindings.conf
source ${CONFIG} || { echo ${CONFIG} not found. Make sure to correctly link or create it: "ln -sf <machine>.conf scheduler-bindings.conf"; exit; }
echo Will use: $(readlink scheduler-bindings.conf)

# Check if Singularity is available.
singularity --version || { echo Singularity not found... exiting.; exit; }

# Get Singularity image path.
# https://stackoverflow.com/a/25535717

ORIGINAL_SINGULARITY_COMMAND="$@" # Optional.
echo Will execute: ${ORIGINAL_SINGULARITY_COMMAND}

for SINGULARITY_ARG in "$@"; do
 case $SINGULARITY_ARG in *.sif) IMAGE="$SINGULARITY_ARG";; esac
done

if [[ -z "$IMAGE" ]]; then echo "No *.sif image location found. Exiting..."; exit; fi

echo Enable host SLURM user for: ${IMAGE}

# Prepare binding of system-specific SLURM user.
#
# We'll filter the host system users and if there is a SLURM user, we'll add it to the
# /etc/passwd and /etc/group files used in the container.
# 
# This is done very similar to how Singularity iself enables the calling user inside the container:
# First, briefly start the container to get /etc/passwd and /etc/groups from with, then
# append users and groups to the files and bind the files when the container is finally started.

# For the manually assembled /etc/passwd and /etc/group files we'll create a temporary directory
# that'll be deleted automatically once the script exists successfully.
TEMPDIR=$(mktemp -d $(pwd)/tmp.XXXXXXXX)
echo Temporary directory: ${TEMPDIR}
trap "echo Deleting: ${TEMPDIR}; rm -rf ${TEMPDIR}" 0

# Extract user and group info from container and (maybe) append the SLURM user.
singularity exec ${IMAGE} cp -p /etc/passwd ${TEMPDIR}/etc_passwd
singularity exec ${IMAGE} cp -p /etc/group ${TEMPDIR}/etc_group
grep slurm /etc/passwd >> ${TEMPDIR}/etc_passwd
grep slurm /etc/group >> ${TEMPDIR}/etc_group

# Note that if system users are not managed in /etc/..., we could use getent:
# getent passwd | grep slurm >> ${TEMPDIR}/etc_passwd
# getent group | grep slurm >> ${TEMPDIR}/etc_group

# Relative bind paths are necessary because of how file system overlays are handled.
RTEMPDIR=$(basename $TEMPDIR)

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
