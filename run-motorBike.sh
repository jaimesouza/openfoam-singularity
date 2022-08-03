#!/bin/bash

# clone the OpenFOAM tutorial repository
git clone https://github.com/OpenFOAM/OpenFOAM-dev.git

# copy motorBike folder
cp -r OpenFOAM-dev/tutorials/incompressible/simpleFoam/motorBike .

# enter motorBike folder
cd motorBike

# clear any previous execution
singularity run ../openfoam.sif ./Allclean

# copy motorBike geometry obj
cp ../OpenFOAM-dev/tutorials/resources/geometry/motorBike.obj.gz constant/geometry/

# define surface features inside the block mesh
singularity run ../openfoam.sif surfaceFeatures

# generate the first mesh
# mesh the environment (block around the model)
singularity run ../openfoam.sif blockMesh

# decomposition of mesh and initial field data
# according to the parameters in decomposeParDict located in the system
singularity run ../openfoam.sif decomposePar -copyZero

# mesh the motorcicle
# overwrite the new mesh files that are generated
singularity run ../openfoam.sif snappyHexMesh -overwrite -parallel

# write field and boundary condition info for each patch
singularity run ../openfoam.sif patchSummary -parallel

# potential flow solver
# solves the velocity potential to calculate the volumetric face-flux field
singularity run ../openfoam.sif potentialFoam -parallel

# steady-state solver for incompressible turbutent flows
singularity run ../openfoam.sif simpleFoam -parallel

# after a case has been run in parallel
# it can be reconstructed for post-processing
singularity run ../openfoam.sif reconstructPar -latestTime

# open up the solution on paraview
singularity run ../openfoam.sif paraFoam
