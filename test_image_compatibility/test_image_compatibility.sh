#!/bin/bash

# Pull container images.

# https://wiki.debian.org/DebianReleases
#seq 6 10 | xargs -I {} bash -c 'singularity pull docker://debian:{} || echo {} failed'

# https://wiki.ubuntu.com/Releases
#seq 10 2 20 | xargs -I {} bash -c 'singularity pull docker://ubuntu:{}.04 || echo {}.04 failed'

# https://www.centos.org/centos-linux/
#seq 6 8 | xargs -I {} bash -c 'singularity pull docker://centos:{} || echo {} failed'

# https://aws.amazon.com/de/amazon-linux-ami/
# https://aws.amazon.com/de/amazon-linux-2/
# https://hub.docker.com/_/amazonlinux
#seq 1 2 | xargs -I {} bash -c 'singularity pull docker://amazonlinux:{} || echo {} failed'

# Test job submission.

MACHINE=`basename $(readlink scheduler-bindings.conf) | cut -d "." -f 1`

ls *.sif | sort -V | xargs -I {} \
bash -c '{ SINGULARITYENV_USER=$USER ./bind_scheduler.sh singularity exec --cleanenv {} ./fake_workflow_slurm.sh; \
echo -----------------------------------------------; }' \
> ${MACHINE}.log 2>&1

# Append host system information.

cat /etc/*release >> ${MACHINE}.log
echo ----------------------------------------------- >> ${MACHINE}.log
uname -a >> ${MACHINE}.log
echo ----------------------------------------------- >> ${MACHINE}.log
date >> ${MACHINE}.log

# Hide paths.

sed "s#$(pwd)#<path-to-repo>/test_image_compatibility#" --in-place ${MACHINE}.log

