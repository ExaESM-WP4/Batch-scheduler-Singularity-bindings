# SLURM-Singularity-bindings

Wrapper scripts that enable host-system batch scheduler commands inside the container.
Should be working especially with Red Hat (e.g. CentOS, ...) and Debian (e.g. Ubuntu, ...) Linux flavours.
Tested for CentOS (7 and 8), Debian (8, 9 and 10) and Ubuntu (18.04 and 20.04) container images.
Please note, that for SLURM, currently only `sinfo`, `squeue`, `sbatch` and `scancel` are supported.

```shell
$ singularity pull docker://centos:8
$ ./bind_slurm.sh singularity shell --cleanenv centos_8.sif
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

The wrapper script above enables Dask jobqueue workflows (see e.g. [here](https://github.com/ExaESM-WP4/dask-jobqueue-configs) for non-container examples and Jobqueue configuration files) from containerized JupyterLab analysis environments (see e.g. [here](https://github.com/martinclaus/py-da-stack) or [there](https://github.com/ExaESM-WP4/Containerized-Jupyter-on-HPC)).
