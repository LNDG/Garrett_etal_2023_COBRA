%% Mask wholebrain task PLS with all nets

addpath('/toolboxes/preprocessing_tools/')
addpath('/toolboxes/NIFTI_toolbox/')


clear all
BASEPATH = 'BASE';
SAVEPATH = [BASEPATH,'/3_PLS/SD_2mm/taskPLS_N152_results_masked/'];

PLSPATH = [BASEPATH,'/3_PLS/SD_2mm/Whole_brain/'];
ID = readtable([BASEPATH,"SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv"]); ID = table2array(ID(:,1));

% load whole brain SDBOLD 2-3 back task PLS
load([BASEPATH,'/3_PLS/SD_2mm/Whole_brain/TaskPLS_COBRA_N152_23back_1000P1000B_BfMRIresult.mat'], 'result', 'st_coords')
SD_coords = st_coords;
SD_u = result.u(:,1);

% load Yeo networks
% net_coords = coords;

% basal ganglia: load BGHAT/Morel network
% seed=S_load_nii_2d([BASEPATH, '/COBRA_masks-selected/BGHAT_Morel_combined.nii']);
% coords_BGHAT_Morel=find(seed(st_coords));

%load the striato-thalamic SDBOLD task PLS results
load([BASEPATH,'/3_PLS/SD_2mm/BGHAT_Morel/TaskPLS_COBRA_N152_23back_BGHATMorel_1000P1000B_BfMRIresult.mat'], 'result', 'st_coords')
SD_ST_coords = st_coords;

%unify brain coords from whole brain and S-T SDBOLD models
WHOLE_ST_memberset = ismember(SD_coords,SD_ST_coords);

%%
cond = [2,3];
% networks = [1,3,6,7];%(Visual, DAN, FPN, DMN)

for i=1:length(ID)
    i_sub = ID{i};
    load([PLSPATH, 'SD_C', i_sub, '_BfMRIsessiondata.mat'], 'st_datamat'); 
    for k=1:2 % conditions (2-back, 3-back)
        i_cond = cond(k);
        %for n = 1:4 % networks
        %i_net = networks(n);
%         SD =st_datamat(i_cond, net_coords{1}); % mask subject SD data with net coordinates
%         BS_vis(i,k)=dot(SD', SD_u(net_coords{1}));
% 
%         SD =st_datamat(i_cond, net_coords{3}); % mask subject SD data with net coordinates
%         BS_DAN(i,k)=dot(SD', SD_u(net_coords{3}));
% 
%         SD =st_datamat(i_cond, net_coords{6}); % mask subject SD data with net coordinates
%         BS_FPN(i,k)=dot(SD', SD_u(net_coords{6}));
%         
%         SD =st_datamat(i_cond, net_coords{7}); % mask subject SD data with net coordinates
%         BS_DMN(i,k)=dot(SD', SD_u(net_coords{7}));
%         % so here I'm not averaging SD across each network?
%         %meanSD{i,k,n}=SD{k,n};
        
        SD=st_datamat(i_cond, coords_BGHAT_Morel); 
        BS_BGHAT_Morel(i, k)=dot(SD', SD_u(WHOLE_ST_memberset));
    end
end

%save([SAVEPATH, 'masked_taskPLSN152_allNets.mat'], 'BS_vis', 'BS_DAN', 'BS_FPN', 'BS_DMN', 'BS_BGHAT_Morel');