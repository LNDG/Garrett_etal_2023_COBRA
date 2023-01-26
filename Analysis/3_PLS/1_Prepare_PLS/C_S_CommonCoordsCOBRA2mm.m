%% creates a mat-file with common coords that is used as a mask for the PLS input

% /opt/matlab/R2014b/bin/mcc -m S_CommonCoordsCOBRA2mm -a /toolboxes/pls -a /toolboxes/NIFTI_toolbox

%Create a matrix of common cordinats of a sample
%   Detailed explanation goes here
%   Input:
%       DATAPATH: ...
%       IDlist: List of subject IDs
%       S = 1 = save coords to DATAPATH
%           0 = do not save coords

% 14-10-20


%% calc binary mask and save file 
% S: Improve list collectio=n... 
% ID = dir('*01*'); 
% subjlist = ID.name; 

%initalize final coords; 1 to 1mio to ensure 1st subjects coords are all

% IDs
ID = readtable("/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv"); ID = table2array(ID(:,1));
common_coords = (1:1000000);

DATAPATH='DATAPATH';
addpath(genpath('/toolboxes/preprocessing_tools'));
addpath(genpath('/toolboxes/NIFTI_toolbox'));

for i = 1:numel(IDlist)  
    
    %S: add S_load_nii...  
    %load nifti file
    try
    fname = ([DATAPATH , 'C', IDlist{i}, '/C', IDlist{i}, '_nback_FEAT_detrend_filt_FIX_MNI2mm.nii']);
    % load nifit from fname, unzip .gz and reshape to 2D
    %[ data ] = S_load_nii_2d( fname );
     
    % load coords from nii file
    nii=S_load_nii_2d(fname);
    subj_coords = find(nii(:,1));
    
    %resulting a matrix of intersecting coordinats over all subjects
    common_coords=intersect(common_coords,subj_coords);
    disp ([IDlist{i}, ': added to common coords']);

   % Error log    
   catch ME
       warning(['error with subject ', IDlist{i}]);
   end

end

%% save
save ([DATAPATH, '/2mm_commoncoordsN181.mat'], 'common_coords');


%% check if common coords look fine: save it as a nifti

% load ([DATAPATH, '/2mm_commoncoordsN181.mat'], 'common_coords');
% nifti=load_nii(DATAPATH, '/Standards/MNI152_T1_2mm_brain.nii.gz');
% nii=S_load_nii_2d(DATAPATH, '/Standards/MNI152_T1_2mm_brain.nii.gz');
% data=zeros(length(nii), 1); 
% data(common_coords)=1; 
% nifti.img=reshape(data,nifti.hdr.dime.dim(2),nifti.hdr.dime.dim(3),nifti.hdr.dime.dim(4),size(nifti.img,4));
% save_nii(nifti, DATAPATH, '/scripts/1-5_nback/10_PLS/2mm_commoncoordsN181.nii')

