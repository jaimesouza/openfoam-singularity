#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=6
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

# create a hostfile to list the set of hosts on which to spawn MPI processes
# using localhost with 6 processors
NUM_PROCESSORS=6
rm -f hostfile
echo "$(hostname) slots=${NUM_PROCESSORS}" >> hostfile

# define surface features inside the block mesh
singularity run ../openfoam.sif surfaceFeatures

# generate the first mesh
# mesh the environment (block around the model)
singularity run ../openfoam.sif blockMesh

# decomposition of mesh and initial field data
# according to the parameters in decomposeParDict located in the system
# create 6 domains by default
singularity run ../openfoam.sif decomposePar -copyZero

# mesh the motorcicle
# overwrite the new mesh files that are generated
mpirun -n ${NUM_PROCESSORS} --hostfile hostfile singularity run ../openfoam.sif snappyHexMesh -overwrite -parallel

# write field and boundary condition info for each patch
mpirun -n ${NUM_PROCESSORS} --hostfile hostfile singularity run ../openfoam.sif patchSummary -parallel

# potential flow solver
# solves the velocity potential to calculate the volumetric face-flux field
mpirun -n ${NUM_PROCESSORS} --hostfile hostfile singularity run ../openfoam.sif potentialFoam -parallel

# steady-state solver for incompressible turbutent flows
mpirun -n ${NUM_PROCESSORS} --hostfile hostfile singularity run ../openfoam.sif simpleFoam -parallel

# after a case has been run in parallel
# it can be reconstructed for post-processing
singularity run ../openfoam.sif reconstructParMesh -constant
singularity run ../openfoam.sif reconstructPar -latestTime

# open up the solution on paraview
#singularity run ../openfoam.sif paraFoam
