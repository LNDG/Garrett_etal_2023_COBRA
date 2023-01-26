function D1_create_BGHAT_Morel_changeSDnback_changePCAdim_PLSanalysis_MAT

BASEPATH='BASE';

%NIIPATH=([BASEPATH, 'imaging_files/nback/preproc/']);
PLSPATH=([BASEPATH, '/3_PLS/']);
MASKPATH=([BASEPATH, '/1_Preprocessing/Masks/']);

% IDs
ID = readtable([BASEPATH,"SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv"]); ID = table2array(ID(:,1));

%get st_coords
load([PLSPATH, 'SD_2mm/SD_C001_2mm_BfMRIsessiondata.mat'], 'st_coords');
%calculate BGHAT/Morel coords in prig and st_coord space
BGHAT_Morel=S_load_nii_2d([MASKPATH, 'BGHAT_Morel_combined.nii']);
BGHAT_Morel_st_coords=find(BGHAT_Morel(st_coords)); %
BGHAT_Morel_orig_coords=intersect(st_coords, find(BGHAT_Morel));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% calculate change in PCAdim (3-2) within BGHAT/Morel network %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load([BASEPATH'/toolboxes/PLS/templates/behav_BfMRIanalysis.mat']); %load MAT template 
for i=1:length(ID)
    load([BASEPATH, '/4_PCA_Dimensionality/temporal_PCA/BGHAT_Morel/C', ID{i}, '_PCAdim_temporal_BGHAT_Morel.mat'], 'Dimensions');
    change32_tempPCAdim(i)=Dimensions(1, 3)-Dimensions(1, 2); %change score: 3-2back
    clear Dimensions    
end

save([BASEPATH, '/data/COBRA_N162_BGHAT_Morel_change32_tempPCA.mat'], 'change32_tempPCAdim', 'ID');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
end

batch_file.behavdata=behav_values;
batch_file.behavname={'BGHATMoreltempPCAdimChange32'}; 

save([PLSPATH, 'SD_2mm/BGHAT_Morel/behavPLS_COBRA_N162_change32SDBOLD_tempPCAdim_change32_BGHATMorel_', num2str(permutations), 'P', num2str(bootstrap), 'B_BfMRIanalysis.mat'], 'batch_file');

end