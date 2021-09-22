# MNFI Whitetail Deer project 2020: Camera Trap photo id

for Clay Wilton, [MNFI](https://mnfi.anr.msu.edu/)

## Overview

run the "CameraTrap Megadetector" models based on TensorFlow (from Microsoft) on ~220K photos from 2020 to identify which have animals, and then
of those count WhiteTail deer present.   For Clay Wilton of the MNFI.  



## Install

Details need to be added : 

1. Get Tensorflow for GPU running on the HPC.   Good luck.   You will most like need create a virtual env and load that. 
   See the SB in this repo for an example name.   I did not save the commands to install TF and I know I"ll be sorry later. 

2. Clone the poject  megadetector GUI somewhere (does not need to be in this folder).   This has a reformulation of the megadetector,
so you dodn't need the original Megadetector code, and we won't be using the GUI part. 

3. copy the python folder out of the "megadetector GUI" to a folder in this project called ?mdapi?  
   Note the Python code adds this folder to the python path so it can import it. 

4. download the models from the original Megadetector project to the "models" in this repository (URL?)

5. create folders "photos" to hold input photos and "output" for the output

6. copy folders full  photos into the photos sub-dir

7. for reach folder in the photos dir, run the `start_detector_job.sh`  eg 
   
```
#in this folder
chmod u+x start_detector_job.sh
./start_detector_job.sh photos/folderX
```

this will launch a slurm job (thar requires a K80 GPU). 

To launch jobs for every sub-folder in photos

```sh
for d in `find photos -type d`; do ./start_detector_job.sh $d; done
```

This shell script sets the variable  INPUT_FOLDER used by the slurm script, 
and  sets the wall time forr the slurm job based on number of photos in the folder (assumes 2 sec per photo)

Assumes that image files are not in sub-subfolders in photos (e.g. photos/cameraX/*.jpg)

### slurm job

run_detector.sb

Requires an environment variable INPUT_FOLDER to be set (see start_detector_job.sh ). 

loads requires LMOD modules, and python enviorrnment (my env currently),  and creates a new folder 
`output/folderX` based on the INPUT_FOLDER.  The python program will put sub-folders with classfied images

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
