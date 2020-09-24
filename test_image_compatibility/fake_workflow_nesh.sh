#!/bin/bash

# Testing these PBS commands: qsub, qstat, qdel

function sleep_then_kill { qstat; qdel "$1"; sleep 5; qstat; }
sleep_then_kill $( qsub test_job_nesh.sh | awk '{print $2}' )

