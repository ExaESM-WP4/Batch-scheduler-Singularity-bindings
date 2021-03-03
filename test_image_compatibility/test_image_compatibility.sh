#!/bin/bash

# Test batch job scheduling functionality.

MACHINE=`basename $(readlink scheduler-bindings.conf) | cut -d "." -f 1`

ls *.sif | sort -V | xargs -I {} \
bash -c '{ SINGULARITYENV_USER=$USER ./bind_scheduler.sh singularity exec --cleanenv {} ./fake_workflow_slurm.sh; \
echo -----------------------------------------------; }' \
> ${MACHINE}.log 2>&1

# Append host system version information.

date >> ${MACHINE}.log
echo ----------------------------------------------- >> ${MACHINE}.log
cat /etc/*release >> ${MACHINE}.log
echo ----------------------------------------------- >> ${MACHINE}.log
uname -a >> ${MACHINE}.log
echo ----------------------------------------------- >> ${MACHINE}.log
sbatch --version >> ${MACHINE}.log
echo ----------------------------------------------- >> ${MACHINE}.log
singularity --version >> ${MACHINE}.log
echo ----------------------------------------------- >> ${MACHINE}.log
ls *.sif | xargs -I {} bash -c 'echo {}; singularity inspect {} | grep build-date' >> ${MACHINE}.log

# Hide machine paths in log file.

sed "s#$(pwd)#<local-repository-path>/test_image_compatibility#" --in-place ${MACHINE}.log
