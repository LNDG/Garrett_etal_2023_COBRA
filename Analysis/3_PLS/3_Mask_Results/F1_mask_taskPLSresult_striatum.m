E2_mask_taskPLSresult_striatum
% this script loads the full PLS model, masks the brain saliences to only
% relevant regions and re-calculateds the latent brain scores per subject
% within only these regions 
% Shirer Network

%% IDs
ID = readtable("/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv"); ID = table2array(ID(:,1));

%% Paths
BASEPATH = 'BASE';
VOX='2';

PLSPATH = ([BASEPATH,'/3_PLS/SD_', VOX, 'mm/']);
MASKPATH= ([BASEPATH,'1_Preprocessing/Masks/']);
SAVEPATH= ([PLSPATH, 'output/']);
conditions = {'back1','back2','back3'};%set all relevant condition names

% load task PLS
load([PLSPATH, 'taskPLS_COBRA_N162_no033_nback2mm_1000P1000B_BfMRIresult.mat']);
load([PLSPATH, 'SD_C200_2mm_BfMRIsessiondata.mat'],'st_coords'); %load st_coords

% weighted scores 
%%%%%%%%%%%%%%%%%
u=result.u(:, 1); %brain saliences from PLS result file

% unweighted scores 
%%%%%%%%%%%%%%%%%
u=ones(length(u), 1); %instead of weighting with the PLS file, just use ones

%striatum: load basal ganglia network
basal_gang={'Basal_Ganglia'};
coords_basal_gang=[];
for k=1:length(basal_gang)
    seed=S_load_nii_2d([MASKPATH, 'Shirer_masks/', basal_gang{k},  '.nii']);
    coords_seed=find(seed(st_coords));
    coords_basal_gang=vertcat(coords_basal_gang, coords_seed);
end

%basal ganglia: load BGHAT/Morel network
BGHAT_Morel={'BGHAT_Morel'};
coords_BGHAT_Morel=[];
seed=S_load_nii_2d([MASKPATH, 'BGHAT_Morel_combined.nii']);
coords_BGHAT_Morel=find(seed(st_coords));


%%%%%%%%%%%%%%%%%
%% sanity check%%
%%%%%%%%%%%%%%%%%
%full model as a sanity check: brain scores should be identical to the scores stored in usc first column

for i=1:length(ID)
    for k=1:length(conditions)
        load([PLSPATH, 'SD_C', ID{i}, '_2mm_BfMRIsessiondata.mat'], 'st_datamat'); 
        SD=st_datamat(k, :); %first row: 1back
        BS_full(i, k)=dot(SD', u); %dot product between SD values and saliences
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% mask model with network seeds %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Shirer's matched networks: basal_gang
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(ID)
    for k=1:length(conditions)
        load([PLSPATH, 'SD_C', ID{i}, '_2mm_BfMRIsessiondata.mat'], 'st_datamat'); 
        SD=st_datamat(k, coords_basal_gang); 
        BS_basal_gang(i, k)=dot(SD', u(coords_basal_gang)); %dot product between masked SD values and masked brain saliences per condition
        SD=st_datamat(k, coords_BGHAT_Morel); 
        BS_BGHAT_Morel(i, k)=dot(SD', u(coords_BGHAT_Morel)); %dot product between masked SD values and masked brain saliences per condition
    end
end
save([SAVEPATH, 'masked_taskPLSN162_Shirer_selected_unweighted.mat'], 'BS_basal_gang', 'BS_BGHAT_Morel');
