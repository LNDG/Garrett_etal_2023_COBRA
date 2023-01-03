function E_create_BGHAT_Morel_changeSDnback_changePCAdim_PLSanalysis_MAT

BASEPATH='BASE';

%NIIPATH=([BASEPATH, 'imaging_files/nback/preproc/']);
PLSPATH=([BASEPATH, '/PLS_nback/']);
MASKPATH=([BASEPATH, '/data/COBRA_masks-selected/']);

%N162 without behav outlier C033
ID={'001', '003', '006', '007', '008', '009', '010', '013', '014', '015', '016', '017', '018', '019', '021', '022', '024', '025', '027', '028', '029', '030', '032', '034', '035', '036', '038', '040', '041', '043', '045', '046', '049', '050', '051', '052', '053', '056', '057', '058', '059', '060', '061', '063', '064', '065', '066', '067', '068', '069', '071', '072', '073', '074', '075', '076', '079', '080', '081', '082', '084', '085', '087', '090', '091', '092', '093', '094', '095', '097', '099', '104', '105', '106', '107', '108', '109', '110', '112', '113', '114', '116', '117', '118', '119', '120', '121', '122', '123', '126', '127', '130', '131', '133', '134', '135', '136', '137', '138', '139', '140', '143', '144', '146', '148', '149', '150', '152', '153', '154', '155', '156', '158', '159', '160', '161', '162', '163', '164', '165', '168', '169', '170', '172', '173', '174', '176', '177', '178', '180', '181', '183', '184', '185', '186', '187', '188', '190', '191', '192', '193', '194', '195', '196', '197', '198', '199', '200', '201', '203', '204', '206', '208', '210', '211', '212', '213', '214', '216', '217', '219', '220'};


%get st_coords
load([BASEPATH, '/PLS_nback/SD_2mm/SD_C001_2mm_BfMRIsessiondata.mat'], 'st_coords');
%calculate BGHAT/Morel coords in prig and st_coord space
BGHAT_Morel=S_load_nii_2d([MASKPATH, 'BGHAT_Morel_combined.nii']);
BGHAT_Morel_st_coords=find(BGHAT_Morel(st_coords)); %
BGHAT_Morel_orig_coords=intersect(st_coords, find(BGHAT_Morel));

%% calculate change in PCAdim (3-2) within BGHAT/Morel network %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load([BASEPATH'/toolboxes/PLS/templates/behav_BfMRIanalysis.mat']); %load MAT template 
for i=1:length(ID)
    load([BASEPATH, '/Dimensionality_nback/temporal_PCA/BGHAT_Morel/C', ID{i}, '_PCAdim_temporal_BGHAT_Morel.mat'], 'Dimensions');
    change32_tempPCAdim(i)=Dimensions(1, 3)-Dimensions(1, 2); %change score: 3-2back
    clear Dimensions    
end

save([BASEPATH, '/data/behav_data/COBRA_N162_BGHAT_Morel_change32_tempPCA.mat'], 'change32_tempPCAdim', 'ID');


%% create PLS analysis file %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

permutations=1000; 
bootstrap=1000; 

batch_file.result_file=['behavPLS_COBRA_N162_change32SDBOLD_tempPCAdim_change32_BGHATMorel_', num2str(permutations), 'P', num2str(bootstrap), 'B_BfMRIresult.mat']; %name result file 
batch_file.smallResult=0; % produce small result file
batch_file.num_split=0; % no split-halfs
batch_file.selected_cond=[0, 0, 0, 0, 1]; % only condition with 3-2back (5th condition)
batch_file.num_boot=bootstrap; 
batch_file.num_perm=permutations; 
num_cond=length(find(batch_file.selected_cond)); 
num_subj=length(ID);


for i=1:num_subj
    batch_file.group_files{1, 1}{i, 1} = (['SD_C', ID{i}, '_2mm_BGHAT_Morel_BfMRIsessiondata.mat']);
    behav_values(i, 1)=change32_tempPCAdim(i); %PCAdim change in BG
%   behav_values(i, 1)=change32_spatPCAdim(i); %PCAdim change in BG

end

batch_file.behavdata=behav_values;
batch_file.behavname={'BGHATMoreltempPCAdimChange32'}; 

save([PLSPATH, 'SD_2mm/BGHAT_Morel/behavPLS_COBRA_N162_change32SDBOLD_tempPCAdim_change32_BGHATMorel_', num2str(permutations), 'P', num2str(bootstrap), 'B_BfMRIanalysis.mat'], 'batch_file');

end