#!/bin/bash

docker build -t singularity-pull .

seq 10 2 20 | xargs -I {} bash -c 'docker run --rm -v $(pwd):/output singularity-pull singularity pull docker://ubuntu:{}.04 || echo {}.04 failed'
seq 6 8 | xargs -I {} bash -c 'docker run --rm -v $(pwd):/output singularity-pull singularity pull docker://centos:{} || echo {} failed'
seq 6 10 | xargs -I {} bash -c 'docker run --rm -v $(pwd):/output singularity-pull singularity pull docker://debian:{} || echo {} failed'
seq 1 2 | xargs -I {} bash -c 'docker run --rm -v $(pwd):/output singularity-pull singularity pull docker://amazonlinux:{} || echo {} failed'

