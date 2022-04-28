# MNFI Whitetail Deer project 2020: Camera Trap photo id

for Clay Wilton, [MNFI](https://mnfi.anr.msu.edu/)

## Overview

Run the "CameraTrap Megadetector" models based on TensorFlow (from Microsoft) on ~220K photos from 2020 to identify which have animals.

## Install


1. Get Tensorflow for GPU running on the HPC.   You will most likely need create a virtual env and load that. 
   See the SB in this repo for an example name.  I'm sorry but I did not save the commands to install TF for this project.  
   Please see the help desk for your local HPC.   

2. Clone the poject  megadetector GUI somewhere (does not need to be in this folder).  https://github.com/petargyurov/megadetector-gui

The project above already has a reformulation of the original megadetector project,
so you dodn't need the original Megadetector code.  Also we won't be using the GUI part of the Megadector-GUI project, but the python code in it is really helpful, so we will be extracting that.   This repository here does _not_ include that code so you must get it and included it.  

3. copy the python folder out of the "megadetector GUI" to a folder in this project. 

   `cp -r megadetector-gui/engine mdapi`

   Note the Python code we are copying automatically adds this folder to the python path so it can import it. 

4. download the models from the original Megadetector project from https://github.com/microsoft/CameraTraps/blob/master/megadetector.md#download-links into the "models" folder here. 

An Example model file is `md_v4.1.0.pb`

5. Make the main script 'executable' 

   The main script should be able to run directy from the command line (it may not be depending on how you copied this 
   program to your HPC).   For those new to linux, use the command like

    ```
    chmod u+x start_detector_job.sh
    ```


## Prepare/Copy Photos

1. create folders "photos" to hold input photos and "output" for the output (marked up photos)

2. put your own folders full of photos as subdirectories in the `photos` directory you created above. 

   The scripts here will work through each sub-folder of the `photos` folder so that you can organize the photos by camera. 

 
## Run
 
1. for each folder (e.g. "folderX" ) in the photos dir, run the `start_detector_job.sh` 
   
```
#in this folder main folder
./start_detector_job.sh photos/folderX
```

this will launch a single slurm job to process the photos in that folder.  It requires a K80 GPU as was avaialble in 2021. You may need to adjust to use current node and GPU names on the HPC.  Note this slurm script is written for the MSU HPCC. 

This shell script sets the variable  `$INPUT_FOLDER` which is then used by the slurm script.  Slurm scripts need a time-to-run parameters ("wall time") and this shell script assumes it will take ~ 2 secs per photo to process, so sets time = 2 * number of photos in seconds.   Adjust that if the job does not complete in time to process all the photos. 


2. To launch jobs for every photos sub-folder 

To launch a job (e.g. add to the HPC queue) for every subdir in your photos folder automaticaly, you could use a bash command as follows 

```sh
for d in `find photos -type d`; do ./start_detector_job.sh $d; done
```

This whole setup assumes that your photos folders (e.g. /photos/photosX) do not have additional sub-folders.   In addition the script above will re-process any folders already processed (it's not very smart, just a simple loop through all folders)

### About the slurm job

`run_detector.sb` script is for running on an HPC. 

Requires an environment variable `$INPUT_FOLDER` to be set (see `start_detector_job.sh` for example and HPC documentation for how to use environment variables with scripts). 

IN short loads requires LMOD modules, and a python environment (my env currently),  and creates a new folder 
`output/folderX` based on the INPUT_FOLDER.  The python program will put sub-folders with classfied images

In addition this assumes you are using a python environment and to make it flexible, looks for a variable 

`$PYTHON_FOLDER`  where you've installed python with "Virtual Env".    You must either edit the slurm script and put in your own folder (recommended) or set the variable prior to running any script

The job requires a K80 GPU.  If tensorflow was not installed correct to use GPUs, it will still run, but will only 
use the 1 core that was requests and will be much slower.  The slurm job has a 2-hour job time, and that may not be enough. 

Note the shell script above sets the wall time when it launches the job, and this overrides the wall time in this slurm script

### python 

run_detector.py

this simply sets up the folders based on convention outlined above, and starts the detector code from the 
Megadetector GUI project.  It also runs a quick check of GPU availability and prints that (for the slumr output)
The Megadetector GUI code is doing all the work. The author has created a better experience
for using the megadetector from the command line.    

see the batch script run_detector.sb for an example of how to launch this python program.
