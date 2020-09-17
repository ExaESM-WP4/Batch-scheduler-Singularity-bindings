#!/bin/bash

# Get system-specific bindings to use here.
CONFIG=batch-bindings.conf
source ${CONFIG} || { echo ${CONFIG} not found. Make sure to link or create it!; exit; }
echo Will use: ${BATCH_CONFIG_NAME}

# Check if singularity is available.
singularity --version || { echo Singularity not found... exiting.; exit; }

# Get Singularity image path.

ORIGINAL_SINGULARITY_COMMAND="$@" # Preserve original argument

echo Will execute: ${ORIGINAL_SINGULARITY_COMMAND}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    *.sif) IMAGE="$1" ;;
    *) ;;
  esac
  shift
done

echo Enable host SLURM user for: ${IMAGE}

# Prepare system-specific SLURM user binding.

TEMPDIR=$(mktemp -d $(pwd)/tmp.XXXXXXXX)
echo Temporary directory: ${TEMPDIR}
trap "echo Deleting: ${TEMPDIR}; rm -rf ${TEMPDIR}" 0

singularity exec ${IMAGE} cp -p /etc/passwd ${TEMPDIR}/etc_passwd
singularity exec ${IMAGE} cp -p /etc/group ${TEMPDIR}/etc_group
cat /etc/passwd | grep slurm >> ${TEMPDIR}/etc_passwd
cat /etc/group | grep slurm >> ${TEMPDIR}/etc_group

#getent passwd >> ${TEMPDIR}/etc_passwd
#getent group >> ${TEMPDIR}/etc_group

RTEMPDIR=$(basename $TEMPDIR) # get relative temp dir path

MERGED_PASSWD_GROUP="\
${RTEMPDIR}/etc_passwd:/etc/passwd,\
${RTEMPDIR}/etc_group:/etc/group\
"

# Setup Singularity bind mount and (library) path environment.

if [[ ! -z "$SLURM_PREPEND_PATH" ]]; then
export SINGULARITYENV_PREPEND_PATH=${SLURM_PREPEND_PATH}${SINGULARITYENV_PREPEND_PATH:+:$SINGULARITYENV_PREPEND_PATH}
echo SINGULARITYENV_PREPEND_PATH: "${SINGULARITYENV_PREPEND_PATH}"
fi

if [[ ! -z "${SLURM_LD_LIBRARY_PATH}" ]]; then
export SINGULARITYENV_LD_LIBRARY_PATH=${SLURM_LD_LIBRARY_PATH}${SINGULARITYENV_LD_LIBRARY_PATH:+:$SINGULARITYENV_LD_LIBRARY_PATH}
echo SINGULARITYENV_LD_LIBRARY_PATH: "${SINGULARITYENV_LD_LIBRARY_PATH}"
fi

SINGULARITY_BIND=${CONFIG_SLURM_COMMANDS},${CONFIG_SYSTEM_SPECS}
SINGULARITY_BIND=${SINGULARITY_BIND},${MERGED_PASSWD_GROUP}
export SINGULARITY_BIND

echo SINGULARITY_BIND: "${SINGULARITY_BIND}"

# Execute original Singularity command.

${ORIGINAL_SINGULARITY_COMMAND}
