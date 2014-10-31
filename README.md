# Command line of ATPP

ATPP (Automatic Tractography-based Parcellation Pipeline)

- Multi-ROI oriented brain parcellation
- Automatic parallel computing
- Modular and flexible structure
- Simple and easy-to-use settings

## Notice
- Some files are from ADPP, the predecessor of ATPP, just ignore them
-  Usage: `sh ATPP.sh batch_list***.txt`


##Prerequisites:
===============================================

- Tools:
    - FSL (with FDT toolbox), SGE and MATLAB (with SPM8 and NIfTI toolbox)
- Data files:
    - T1 image for each subject
    - b0 image for each subject
    - images preprocessed by FSL(BedpostX) for each subject
- Directory structure:
```
     Working_dir
     |-- sub1
     |   |-- T1_sub1.nii
     |   |-- b0_sub1.nii
     |-- sub2
     |-- ...
     |-- subN
     |-- ROI
     |   |-- ROI_L.nii
     |   `-- ROI_R.nii
     `-- log 
```
===============================================