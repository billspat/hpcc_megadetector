#!/usr/bin/env bash

# start_detector_job.sh
# launches slurm script with variable name  and time based on size of folder
if [ -z "$1" ]
then
      echo "usage start_detector_job.sh photos/foldername"
fi

export PHOTOFOLDER=`pwd`/$1
echo "running for $PHOTOFOLDER"

# how many photos in this folder?
PHOTOCOUNT=`ls -b $PHOTOFOLDER | wc -l`
# estimate run time at 2 seconds per photo +  5 minute start up time
EST_SECONDS=$(($PHOTOCOUNT*2+600))
# convert  num of seconds to time  expression for the slurm -t parameter
TIME_EXPR=$( date -d@$EST_SECONDS -u +%H:%M:%S)
#  slurm batch submit command
cmd="sbatch --export=INPUT_FOLDER=$PHOTOFOLDER -t $TIME_EXPR --job-name=$(basename $PHOTOFOLDER) --output=$(basename $PHOTOFOLDER)-%j.txt run_detector.sb"
# show the command
echo $cmd
# submit
$cmd
