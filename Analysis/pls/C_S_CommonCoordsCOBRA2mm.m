%% creates a mat-file with common coords that is used as a mask for the PLS input

% /opt/matlab/R2014b/bin/mcc -m S_CommonCoordsCOBRA2mm -a /scripts/toolboxes/pls -a /scripts/toolboxes/NIFTI_toolbox

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

% N181 (21.04.17)
IDlist={'001', '002', '003', '006', '007', '008', '009', '010', '011', '013', '014', '015', '016', '017', '018', '019', '021', '022', '023', '024', '025', '026', '027', '028', '029', '030', '031', '032', '033', '034', '035', '036', '037', '038', '039', '040', '041', '043', '045', '046', '047', '049', '050', '051', '052', '053', '054', '056', '057', '058', '059', '060', '061', '063', '064', '065', '066', '067', '068', '069', '071', '072', '073', '074', '075', '076', '079', '080', '081', '082', '083', '084', '085', '087', '090', '091', '092', '093', '094', '095', '096', '097', '098', '099', '104', '105', '106', '107', '108', '109', '110', '112', '113', '114', '116', '117', '118', '119', '120', '121', '122', '123', '126', '127', '130', '131', '132', '133', '134', '135', '136', '137', '138', '139', '140', '141', '142', '143', '144', '146', '148', '149', '150', '152', '153', '154', '155', '156', '158', '159', '160', '161', '162', '163', '164', '165', '168', '169', '170', '172', '173', '174', '176', '177', '178', '179', '180', '181', '183', '184', '185', '186', '187', '188', '190', '191', '192', '193', '194', '195', '196', '197', '198', '199', '200', '201', '202', '203', '204', '205', '206', '208', '210', '211', '212', '213', '214', '216', '217', '219', '220'};
common_coords = (1:1000000);

DATAPATH=('DATAPATH');
addpath(genpath('/scripts/toolboxes/preprocessing_tools'));
addpath(genpath('/scripts/toolboxes/NIFTI_toolbox'));

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

