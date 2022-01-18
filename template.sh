#!/bin/bash
 
#SBATCH -N numberOfNodes                 # number of nodes
#SBATCH --tasks-per-node=someNumber      # number of cores used per node
#SBATCH -t 0-2:00                        # wall time (D-HH:MM)
#SBATCH -J jobName                       # job name 
#SBATCH -o slurm.%j.out                  # STDOUT (%j = JobId) (file containing output)
#SBATCH -e slurm.%j.err                  # STDERR (%j = JobId) (file containing error)
#SBATCH --mail-type=ALL                  # Send a notification when the job starts, stops, or fails
#SBATCH --mail-user=yourEmailAddress     # send-to address

nodes=numberOfNodes
coresUsedPerNode=someNumber              # keep it the same as --tasks-per-node
nOPENMP=numberOfThreads                  # leave it as 1 if openmp not used
nMPI=`echo $nodes $nOPENMP $coresUsedPerNode | awk '{print $1*$3/$2}'`
                                         # nMPI=nodes*coresUsedPerNode/nOPENMP 

binDir=...                               # location of the executable

#module purge                            # unload all the modules
module load ...

# uncomment if openmp is used
#export OMP_NUM_THREADS=$nOPENMP

# to run some package
srun -n $nMPI -c $nOPENMP $binDir/command ...
