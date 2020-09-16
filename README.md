# SLURM-Singularity-bindings

Wrapper scripts that enable host-system SLURM commands inside the container.
Please note, currently only `sinfo`, `squeue`, `sbatch` and `scancel` are supported.

```shell
$ singularity pull docker://centos:8
$ ./bind_slurm.sh singularity shell --cleanenv centos_8.sif
Will execute: singularity shell --cleanenv centos_8.sif
Enable host SLURM user for: centos_8.sif
Temporary directory: /<path-to-wrapper-script>/tmp.TaFBzORP
Binding: /usr/bin/sinfo,/usr/bin/squeue,/usr/bin/sbatch,/usr/bin/scancel,/var/run/munge,/usr/lib64/libmunge.so.2,/usr/lib64/slurm/,/etc/slurm/,/usr/lib64/liblua-5.1.so,/usr/lib64/lua/5.1/,/usr/share/lua/5.1/,/opt/jsc/slurm/etc/globres.json,tmp.TaFBzORP/etc_passwd:/etc/passwd,tmp.TaFBzORP/etc_group:/etc/group
Singularity>
Singularity> exit
exit
Deleting: /<path-to-wrapper-script>/tmp.TaFBzORP
```

