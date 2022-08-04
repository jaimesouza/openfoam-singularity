#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH -p osd-slurmd
#SBATCH -J openfoam
#SBATCH --output=R-%x.%j.out
#SBATCH --error=R-%x.%j.err

# clone the OpenFOAM 10 tutorial repository
git clone https://github.com/OpenFOAM/OpenFOAM-10.git

# copy motorBike folder
cp -r OpenFOAM-10/tutorials/incompressible/simpleFoam/motorBike .

# enter motorBike folder
cd motorBike

# clear any previous execution
singularity run ../openfoam.sif ./Allclean

# copy motorBike geometry obj
cp ../OpenFOAM-10/tutorials/resources/geometry/motorBike.obj.gz constant/geometry/

# define surface features inside the block mesh
singularity run ../openfoam.sif surfaceFeatures

# generate the first mesh
# mesh the environment (block around the model)
singularity run ../openfoam.sif blockMesh

# mesh the motorcicle
# overwrite the new mesh files that are generated
singularity run ../openfoam.sif snappyHexMesh -overwrite

# write field and boundary condition info for each patch
singularity run ../openfoam.sif patchSummary

# potential flow solver
# solves the velocity potential to calculate the volumetric face-flux field
singularity run ../openfoam.sif potentialFoam

# steady-state solver for incompressible turbutent flows
singularity run ../openfoam.sif simpleFoam

# open up the solution on paraview
#singularity run ../openfoam.sif paraFoam
