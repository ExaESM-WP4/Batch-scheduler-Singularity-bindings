#!/bin/bash

# Pull container images.

# https://wiki.debian.org/DebianReleases
#seq 6 10 | xargs -I {} bash -c 'singularity pull docker://debian:{} || echo {} failed'

# https://wiki.ubuntu.com/Releases
#seq 10 2 20 | xargs -I {} bash -c 'singularity pull docker://ubuntu:{}.04 || echo {}.04 failed'

# https://www.centos.org/centos-linux/
#seq 6 8 | xargs -I {} bash -c 'singularity pull docker://centos:{} || echo {} failed'

# Test job submission.

ls *.sif | sort -V | xargs -I {} \
bash -c '{ SINGULARITYENV_USER=$USER ./bind_scheduler.sh singularity exec --cleanenv {} ./fake_workflow_slurm.sh; \
echo -----------------------------------------------; }'

