# source this file to load the HPC modules needed
# to work with a local Python env with tensorflow installed
# note these are also loaded in the run_detector.sb slurm script
ml purge
ml  GNU/8.2.0-2.31.1 Python/3.7.2  CUDA/10.1.105 cuDNN/7.6.4.38
