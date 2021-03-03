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

Please note, for SLURM only `sinfo`, `squeue`, `sbatch` and `scancel` and for PBS only `qsub`, `qstat`, and `qdel` are currently supported.

## Usage instructions

Before you can use the `bind_scheduler.sh` wrapper you have to provide the configuration for your HPC system. This is done by setting up a soft link,

```shell
$ ln -sf juwels.conf scheduler-bindings.conf
```

```shell
$ singularity pull docker://centos:8
$ ./bind_scheduler.sh singularity shell --cleanenv centos_8.sif
Will use: juwels.conf
singularity version 3.6.1-1.20200803git8a92cf127.el7
Will execute: singularity shell --cleanenv centos_8.sif
Enable host SLURM user for: centos_8.sif
Temporary directory: <path-to-script>/tmp.CU7R16oG
SINGULARITYENV_LD_LIBRARY_PATH: /usr/lib64
SINGULARITY_BIND: /usr/bin/sinfo,/usr/bin/squeue,/usr/bin/sbatch,/usr/bin/scancel,/usr/lib64/slurm,/etc/slurm,/usr/lib64/libmunge.so.2,/var/run/munge,/usr/lib64/liblua-5.1.so,/usr/share/lua/5.1,/usr/lib64/lua/5.1,/opt/jsc/slurm/etc/globres.json,tmp.CU7R16oG/etc_passwd:/etc/passwd,tmp.CU7R16oG/etc_group:/etc/group
Singularity> exit
exit
Deleting: <path-to-script>/tmp.CU7R16oG
```

## Compatibility

As already state above, the wrapper script bind mounts system users, executables, shared libraries and configuration files from the HPC systems's batch scheduler into the container's file system.
Most operating systems deployed on HPC systems are glibc-based, therefore currently only container images based on the glibc-implementation are expected to work (note, e.g., that Alpine images are musl-based and therefore not compatible).
To give an overview, for the [most popular Docker container base image](https://hub.docker.com/search?type=image&image_filter=official&category=base) versions a few dedicated [compatibility tests](./test_image_compatibility) have been done on the supported HPC systems.

| HPC system | Singularity | compatible | not compatible |
| ---------: | :-----: | ------------- | ----- |
| NESH<br>Redhat-7.5_3.10.0<br>PBS | v3.5.3 | Ubuntu: 12, 14, 16, 18, 20<br>CentOS: 7, 8<br>Debian: 8, 9, 10<br>Amazon Linux: 1, 2<br> | Ubuntu: 10<br>CentOS: 6<br>Debian: 6, 7<br>--- |
| JUWELS<br>CentOS-7.8_3.10.0<br>SLURM | v3.6.1 | Ubuntu: 12, 14, 16, 18, 20<br>CentOS: 7, 8<br>Debian: 8, 9, 10<br>Amazon Linux: 1, 2 | Ubuntu: 10<br>CentOS: 6<br>Debian: 6, 7<br>--- |
| HLRN-B<br>Redhat-7.8_3.10.0<br>SLURM | v3.5.3 | Ubuntu: 12, 14, 16, 18, 20<br>CentOS: 7, 8<br>Debian: 8, 9, 10<br>Amazon Linux: 1, 2 | Ubuntu: 10<br>CentOS: 6<br>Debian: 6, 7<br>--- |
| HLRN-G<br>Redhat-7.8_3.10.0<br>SLURM | v3.2.1 | ---<br>CentOS: 7, 8<br>---<br>Amazon Linux: 1, 2 | Ubuntu: 10, 12, 14, 16, 18, 20<br>CentOS: 6<br>Debian: 6, 7, 8, 9, 10<br>--- |
| Mistral<br>Redhat-6.10_2.6.32<br>SLURM | v3.6.1 | Ubuntu: 10, 12, 14, 16<br>CentOS: 6, 7<br>Debian: 6, 7, 8, 9<br>Amazon Linux: 1 | Ubuntu: 18, 20<br>CentOS: 8<br>Debian: 10<br>Amazon Linux: 2 |

Please note, for containers to be compatible with the wrapper script it might also be required that an application's executables and libraries are not installed in one of the file system locations that are specified in the HPC system-specific configuration files.
Singularity bind mounting takes precedence over the container's original file system contents, which may result in a broken application when a container application is started with the wrapper.
It should be noted that, in general, the portability of a container image can be improved considerably by installing target applications not in a default file system location, but in application-specific folders inside e.g. the container's root path (and then explicitly adding these to the `$PATH` environment variable).
