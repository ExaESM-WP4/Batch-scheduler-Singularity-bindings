#!/usr/bin/env bash
#PBS -l elapstim_req=00:05:00 -l cpunum_job=1 -l memsz_job=1gb -q clmedium

sleep 5; echo $(hostname)

