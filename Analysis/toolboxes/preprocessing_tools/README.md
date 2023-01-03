# FMRI PREPROCESSING TOOLS

this collection is intendet to provide a substential collection of tools used for fMRI preprocessing in MATLAB. 

### The following tools are included:

- loading Nifti files
	- just load a Nifti header
	- reshape into 2 dimensions
	- reshape into 4 dimensions
	
- saving Nifti files
	- 4 dimensions

- reshape 4D structure form LOAD_NII to 2D voxel x time matrix
	
- gather common coordinates from a set of Niftis

- applying a set coordinates to a Nifti file

- detrend a 2 dimension matrix

- checking ID lists

====


### Content

1. S_appl_st_coords.m
2. S_CommonCoords.m
3. S_detrend_data2D.m
4. S_detrend_nifitLS.m
5. S_GMcommonCoords.m
6. S_CheckIDlist.m
7. S_nii4dto2d.m
6. S_load_nii_2d.m
7. S_load_nii_struct.m
8. S_save_nii_4d.m

