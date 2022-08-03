# OpenFOAM on Singularity

Describe how to run OpenFOAM using a singularity container on a slurm cluster

## Build the OpenFOAM singularity container

First we need to create a singularity definition file to build a container with OpenFOAM installation. 

For example, we can create the `[openfoam.def](openfoam.def)` file.

The `singularity build` command will build the singularity container image (`openfoam.sif`)

`singularity build -f openfoam.sif openfoam.def`
