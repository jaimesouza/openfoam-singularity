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

singularity run ../openfoam.sif surfaceFeatures

singularity run ../openfoam.sif blockMesh

# decomposition of mesh and initial field data
# according to the parameters in decomposeParDict located in the system
singularity run ../openfoam.sif decomposePar -copyZero

singularity run ../openfoam.sif snappyHexMesh -overwrite -parallel

singularity run ../openfoam.sif patchSummary -parallel

singularity run ../openfoam.sif potentialFoam -parallel

# run the solver
singularity run ../openfoam.sif simpleFoam -parallel

# after a case has been run in parallel
# it can be reconstructed for post-processing
singularity run ../openfoam.sif reconstructPar -latestTime

# open up the solution on paraview
singularity run ../openfoam.sif paraFoam
