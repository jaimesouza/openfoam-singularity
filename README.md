# OpenFOAM on Singularity

Describe how to run OpenFOAM using a singularity container on a slurm cluster

## Build the OpenFOAM singularity container

First we need to create a singularity definition file to build a container with OpenFOAM installation. 

For example, we can create the [`openfoam.def`](openfoam.def) file.

The `singularity build` command will build the singularity container image (`openfoam.sif`)

`singularity build -f openfoam.sif openfoam.def`

## Run MotorBike example

Now we can run the [OpenFOAM motorBike example](https://github.com/OpenFOAM/OpenFOAM-10/tree/master/tutorials/incompressible/simpleFoam/motorBike) using the following job scripts:

- [Sequential execution](run-motorBike-sequential.sh)
- [Parallel executon](run-motorBike-parallel.sh)

OpenFOAM uses MPI for parallelism. So, the environment must have some MPI implementation installed. The above scripts have been tested with OpenMPI.

## Visualization on Paraview

When the calculation is done, the results can be viewed in paraview, using the following command inside the motorBike folder:

`singularity run ../openfoam.sif paraFoam`
