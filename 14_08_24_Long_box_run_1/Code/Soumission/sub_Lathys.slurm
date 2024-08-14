#!/bin/bash
#SBATCH --job-name=14_08_24_Long_box_run_1              # Job name
#SBATCH --partition=nodes               # What partition the job should run on
#SBATCH --time=0-00:30:00                     # Time limit (DD-HH:MM:SS)
#SBATCH --ntasks=8                # Number of MPI tasks to request
#SBATCH --cpus-per-task=1             # Number of CPU cores per MPI task
#SBATCH --mem=2G                        # Total memory to request
#SBATCH --account=pet-interplan-2024    # Project account to use
#SBATCH --mail-type=END,FAIL            # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=eb2019@york.ac.uk   # Where to send mail
#SBATCH --output=%x-%j.log              # Standard output log
#SBATCH --error=%x-%j.err               # Standard error log

##set -x

TEMPDIR="$HOME/Project/LatHyS/bin/ephemeral/14_08_24_Long_box_run_1"

SCRATCHDIR="/users/eb2019/Project/scratch/"

cd $SCRATCHDIR
mkdir 14_08_24_Long_box_run_1
cd 14_08_24_Long_box_run_1
mkdir Code
cp -rf $TEMPDIR/src Code/
mkdir Code/Soumission
cp $TEMPDIR/sub_Lathys.slurm Code/Soumission
cp $TEMPDIR/launcher.sh Code/Soumission
cp $TEMPDIR/sub_restart.slurm Code/Soumission
cp ~/Project/LatHyS/bin/restart.sh Code/Soumission

mkdir ncfiles
cd ncfiles

#
### on amene sur le workdir les fichiers necessaires
#
cp $TEMPDIR/quiet_plasma .
cp $TEMPDIR/diag .
### on fait le calcul proprement dit
srun --mpi=pmi2 -K1 --resv-ports -n $SLURM_NTASKS ./quiet_plasma -ncxyz 1000 8 8 -dt 0.05 --gstep 1 -nhm 6000 -pn earth -r 0 -ug 1

###Gather all the restart files
mkdir restart_files
mv r_*.nc restart_files

### return in the job root directory ###
cd ..

### Save the .output file separately so that it is easier to access
mv $HOME/Project/LatHyS/bin/14_08_24_Long_box_run_1*.err ./
mv $HOME/Project/LatHyS/bin/14_08_24_Long_box_run_1*.log ./

### Once everything is done, delete the tempdir ###
cd $TEMPDIR
cd ..
rm -rf 14_08_24_Long_box_run_1

### And launch a run on a single node to post-process run results ###
cd $SCRATCHDIR/14_08_24_Long_box_run_1/ncfiles/
cp $HOME/Project/LatHyS/bin/diagnostic_files/* ./

#source ./launch_diag.sh



