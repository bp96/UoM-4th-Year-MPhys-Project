# MPhys_Project_S1_Radiomics

See below descriptions of each script, numbered in the correct order to be compiled necessary to execute the pipeline.

1. createNIFTY.lua: For a particular patient identifies DCM T2 and DIXON scans based on filesize, creates mask expansions and then exports images in a NifTi format for use in PyRadiomics.

2. extractRadiomics.py: Filters through scan directory including all patients and visits, identifies all masks and NifTi images and then extracts all unfiltered Radiomics features in .csv format.
