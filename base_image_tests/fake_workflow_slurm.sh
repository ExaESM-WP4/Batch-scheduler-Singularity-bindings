#!/bin/bash

function sleep_then_kill { sleep 3; squeue -u $USER; scancel "$1"; squeue -u $USER; }
sleep_then_kill $( sbatch test_job_slurm.sh | awk '{print $4}' )

