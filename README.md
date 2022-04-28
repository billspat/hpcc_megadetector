# MegaDetector on the MSU HPCC

## Overview

Written for Clay Wilton, [MNFI](https://mnfi.anr.msu.edu/) Whitetail Deer project 2020/21Camera Trap photo id

The goal is to run the "CameraTrap Megadetector" models on the MSU HPCC, originnally to process  ~220K photos from 2020 to 
identify photos with White Tail deer.    The "CameraTrap Megadetector"  project is from Microsoft, https://github.com/microsoft/CameraTraps/blob/main/megadetector.md and is based on TensorFlow (from Google).   The code here uses someone else's adaption of 
the Megadetector project and hacked to work on the MSU HPCC.   In short, it process folders full of photos in batch using the MSU HPCC's GPU nodes.  

## Install

1. Get Tensorflow for GPU running on the HPC.   Note that I don't recall if this code worked with Tensorflow 1.15 or version 2.   This was not straightforward, I'm sorry but I did not save the commands to install TF for this project. Please see the help desk for your local HPC.  You will most likely need create a python virtual env, install tensorflow into that virtual env.  ( see https://wiki.hpcc.msu.edu/display/ITH/Using+Python+in+HPCC+with+virtualenv)    The script that runs the 
megadector code loads a virtual env by name.   The name and location you use for your virtual env doesn't matter (for example could use $HOME/python/tensorflow), but you must edit the file `run_detector.sb` to match.  

It worked with Python 3.7  modules on HPCC.  to create a virtual env, use somethign like this


```Bash
# on the MSU HPCC
# load python module known to work with cuda and tensorflow
ml  GNU/8.2.0-2.31.1 Python/3.7.2  CUDA/10.1.105 cuDNN/7.6.4.38
# create new personal environment for python 
virtualenv $HOME/python37tf

# to use this python with tensorflow installed
source $HOME/python37tf/bin/activate

# this installs python packages sneeded 
pip intall -r requirements.txt
```

2. Optional "megadetector GUI" Installation

*Note this step is already done and part of this repository. You don't need to re-download.  The instructions are included for completeness*

Clone the program "megadetector GUI" from github somewhere   https://github.com/petargyurov/megadetector-gui  Where  you 
clone doesn't matter and does not need to be in this folder -  you will be copying something out into this folder.  The megadetector GUI project already has a reformulation of the original megadetector project, so you dodn't need the original 
Megadetector code.  Also we won't be using the GUI part of the Megadector-GUI project, but the python code in it is really helpful, so we will be extracting that.   This project/repository  does _not_ include that code so you must acquire it seperately.  

Copy the 'engine'  folder only out of the "megadetector GUI" to a folder in this project named `mdapi`. 

   `cp -r megadetector-gui/engine mdapi`

    
Note our script assumes the folder is mdapi/


3. download the models from the original Megadetector project from https://github.com/microsoft/CameraTraps/blob/master/megadetector.md#download-links into the "models" folder here.  An Example model file is `md_v4.1.0.pb`   To download on the HPCC with a browser consie the OnDemand Linux desktop service, or in the terminal a command like this 

```bash
DOWNLOAD_URL=https://lilablobssc.blob.core.windows.net/models/camera_traps/megadetector/md_v4.1.0/md_v4.1.0.pb
curl $DOWNLOAD_URL -o models/md_v4.1.0.pb
```

4. Make the main script 'executable' 

   The main script should be able to run directy from the command line (it may not be depending on how you copied this 
   program to your HPC).   For those new to linux, use the command like

    ```
    chmod u+x start_detector_job.sh
    ```


## Prepare/Copy Photos

1. create folders "photos" to hold input photos and "output" for the output (marked up photos)

2. put your own folders full of photos as subdirectories in the `photos` directory you created above.  This allows you to loop through 
all the subfolders of photos and process them.   The scripts here will work through each sub-folder of the `photos` folder so that you can organize the photos by camera. 

 
## Run

### Scripts

   1.  `run_detector.py`  simple python code to check GPU status and invoke detector on a folder of photos
   2.  `run_detector.sb`  Slurm submission script to set variables, load modules and run `run_detector.py`
   3. `start_detector_job.sh`  Shell (bash) script to count photos in a folder to set walltime, input & output folders for `run_detector.sb`
 
### Test Run

   To test that everything works, you can run this in an 'interactive job' ( ) on a node with a GPU.   First put a handful of photos in a folder, let's call the folder `testphotos`  If all is installed, you can process this folder like this: 

    ```Bash
    # start an 'interactive job' to use a GPU node for 1 hour
    salloc -c 2 --time=01:00:00 --mem=10gb --gres=gpu:k80:1
    
    # wait for resources to allocate
    
    # after the job starts and you are logged in, activate the python environment
    # assume your python is in your home dir in folder /python37tf
    source $HOME/python37tf/bin/activate
    
    # run the detector script on the folder testphotos, and save into testoutput
    python run_detector.py testphotos testoutput
    
    # if you see the output  Successfully opened dynamic library libcudart.so.10.1 then tensorflow is using the gpu
    # review the contents of testoutput to see if it worked
    
    # when finished testing, exit from the GPU node
    exit
    
    ```


### automated run

For automatic setting of walltime, input folder, output folders for a slurm job, for a folder of photos under the `photos` folder
(e.g. `camera_a` ) in the photos dir, run she shell script with the folder as the first parameter as follows
   
```
# set this to the location of your virtual env install where you have python and tensorflow 
export PYTHON_FOLDER=$HOME/my_tensorflow_python_folder 
./start_detector_job.sh photos/camera_a
```

this will launch a single slurm job to process the photos in that folder.  It requires a K80 GPU as was avaialble in 2021. You may need to adjust to use current node and GPU names on the HPC.  Note this slurm script is written for the MSU HPCC. 

This shell script sets the variable  `$INPUT_FOLDER` which is then used by the slurm script.  Slurm scripts need a time-to-run parameters ("wall time") and this shell script assumes it will take ~ 2 secs per photo to process, so sets time = 2 * number of photos in seconds.   Adjust that if the job does not complete in time to process all the photos. 


### To launch jobs for every photos sub-folder 

To launch a job (e.g. add to the HPC queue) for every subdir in your photos folder automaticaly, you could use a bash command as follows 

```sh
export PYTHON_FOLDER=/path/to/pythonenv # replace with your folder above
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
