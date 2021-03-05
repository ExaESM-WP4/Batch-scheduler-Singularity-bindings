# Batch scheduler bindings for Singularity containers

This repository provides a wrapper script that adds HPC system batch scheduler functionality to Singularity containers.
It was designed with container image portability in mind.
Therefore, it does not require any target-system specific adaption to a container's `Dockerfile` and instead bind mounts the required system users, executables, libraries and configuration files into the container's file system at startup (see e.g. the [compatibility tests](./test_image_compatibility) for which only default container base images were used).
For a brief overview on current limitations, see the compatibility section below.

There are a few specific HPC usage scenarios that have motivated this wrapper,

* batch job orchestration via e.g. JupyterLab terminals in a containerized Jupyter environment
* Dask jobqueue workflows from inside a containerized JupyterLab environment
* workflow managers like e.g. Nextflow when used from a container
* ...

## Functionality

Please note, for SLURM only `sinfo`, `squeue`, `sbatch` and `scancel` are currently supported.

## Usage instructions

Before you can use the `bind_scheduler.sh` wrapper you have to provide the configuration for your HPC system. This is done by setting up a soft link,

```shell
$ git clone https://github.com/ExaESM-WP4/Batch-scheduler-Singularity-bindings.git
$ cd Batch-scheduler-Singularity-bindings
$ ln -sf nesh.conf scheduler-bindings.conf
```

Example output:
```shell
$ singularity pull docker://centos:8
$ ./bind_scheduler.sh singularity shell --cleanenv centos_8.sif
Will use: nesh.conf
linux kernel 4.18.0-193.el8.x86_64
slurm 20.02.4-1aurora
singularity version 3.5.2
Will execute: singularity shell --cleanenv centos_8.sif
Enable host SLURM user for: centos_8.sif
Temporary directory: .../Batch-scheduler-Singularity-bindings/tmp.d0ma2UHL
SINGULARITY_BIND: /usr/bin/sinfo,/usr/bin/squeue,/usr/bin/sbatch,/usr/bin/scancel,/usr/lib64/slurm/,/etc/slurm/,/usr/lib64/libmunge.so.2,/var/run/munge/,tmp.d0ma2UHL/etc_passwd:/etc/passwd,tmp.d0ma2UHL/etc_group:/etc/group
Singularity> sbatch test_job_slurm.sh 
Submitted batch job 444855
Singularity> squeue -u smomw260
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON) 
            444855   cluster test_job smomw260  R       0:02      1 neshcl119 
Singularity> exit
exit
Deleting: .../Batch-scheduler-Singularity-bindings/tmp.d0ma2UHL
```

## Compatibility

As already state above, the wrapper script bind mounts system users, executables, shared libraries and configuration files from the HPC systems's batch scheduler into the container's file system.
Most operating systems deployed on HPC systems are glibc-based, therefore currently only container images based on the glibc-implementation are expected to work (note, e.g., that Alpine images are musl-based and therefore not compatible).
To give an overview, for the [most popular Docker container base image versions](https://hub.docker.com/search?type=image&image_filter=official&category=base) a few dedicated [compatibility tests](./test_image_compatibility) have been done on the supported HPC systems.

| HPC system | Singularity | compatible | not compatible |
| ---------: | :---------: | ---------- | -------------- |
| NESH<br>Redhat-8.2_4.18.0<br>SLURM_20.02.4 | v3.5.2 | Ubuntu: 18, 20<br>CentOS: 8<br>Debian:  10<br>--- | Ubuntu: 10, 12, 14, 16<br>CentOS: 6, 7<br>Debian: 6, 7, 8, 9<br>Amazon Linux: 1, 2 |
| JUWELS<br>CentOS-7.8_3.10.0<br>SLURM | v3.6.1 | Ubuntu: 12, 14, 16, 18, 20<br>CentOS: 7, 8<br>Debian: 8, 9, 10<br>Amazon Linux: 1, 2 | Ubuntu: 10<br>CentOS: 6<br>Debian: 6, 7<br>--- |
| HLRN-B<br>Redhat-7.8_3.10.0<br>SLURM | v3.5.3 | Ubuntu: 12, 14, 16, 18, 20<br>CentOS: 7, 8<br>Debian: 8, 9, 10<br>Amazon Linux: 1, 2 | Ubuntu: 10<br>CentOS: 6<br>Debian: 6, 7<br>--- |
| HLRN-G<br>Redhat-7.8_3.10.0<br>SLURM | v3.2.1 | ---<br>CentOS: 7, 8<br>---<br>Amazon Linux: 1, 2 | Ubuntu: 10, 12, 14, 16, 18, 20<br>CentOS: 6<br>Debian: 6, 7, 8, 9, 10<br>--- |
| Mistral<br>Redhat-6.10_2.6.32<br>SLURM | v3.6.1 | Ubuntu: 10, 12, 14, 16<br>CentOS: 6, 7<br>Debian: 6, 7, 8, 9<br>Amazon Linux: 1 | Ubuntu: 18, 20<br>CentOS: 8<br>Debian: 10<br>Amazon Linux: 2 |

Please note, for containers to be compatible with the wrapper script it might also be required that an application's executables and libraries are not installed in one of the file system locations that are specified in the HPC system-specific configuration files.
Singularity bind mounting takes precedence over the container's original file system contents, which may result in a broken application when a container application is started with the wrapper.
It should be noted that, in general, the portability of a container image can be improved considerably by installing target applications not in a default file system location, but in application-specific folders inside e.g. the container's root path (and then explicitly adding these to the `$PATH` environment variable).
