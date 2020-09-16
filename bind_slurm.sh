#!/bin/bash

# Specify bindings to use.

source hlrnb.conf

# Get Singularity image path.

SINGULARITY_COMMAND="$@" # Preserve original command for while-approach below

echo Will execute: ${SINGULARITY_COMMAND}

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

singularity run ${IMAGE} cp -p /etc/passwd ${TEMPDIR}/etc_passwd
singularity run ${IMAGE} cp -p /etc/group ${TEMPDIR}/etc_group
cat /etc/passwd | grep slurm >> ${TEMPDIR}/etc_passwd
cat /etc/group | grep slurm >> ${TEMPDIR}/etc_group

RTEMPDIR=$(basename $TEMPDIR) # get relative temp dir path

MERGED_PASSWD_GROUP="\
${RTEMPDIR}/etc_passwd:/etc/passwd,\
${RTEMPDIR}/etc_group:/etc/group\
"

# Setup bind mount environment.

SINGULARITY_BIND=${SLURM_COMMANDS},${SYSTEM_SPECS}
SINGULARITY_BIND=${SINGULARITY_BIND},${MERGED_PASSWD_GROUP}
export SINGULARITY_BIND

echo Binding: "${SINGULARITY_BIND}"

# Execute original Singularity command.

${SINGULARITY_COMMAND}

