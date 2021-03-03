#!/bin/bash

# Tests the following SLURM commands
# sinfo, sbatch, squeue, scancel

sinfo 1> /dev/null && echo successful call: sinfo || echo failed to call: sinfo
function sleep_then_kill { squeue -u $USER; scancel "$1"; sleep 5; squeue -u $USER; }
sleep_then_kill $( sbatch test_job_slurm.sh | awk '{print $4}' )

