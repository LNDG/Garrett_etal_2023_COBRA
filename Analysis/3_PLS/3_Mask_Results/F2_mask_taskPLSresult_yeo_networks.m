E3_mask_taskPLSresult_yeo
% this script loads the full PLS model, masks the brain saliences to only
% relevant regions and re-calculateds the latent brain scores per subject
% within only these regions 
% Yeo Networks

addpath('/toolboxes/pls/')
addpath(genpath('/toolboxes/preprocessing_tools'));
addpath(genpath('/toolboxes/NIFTI_toolbox'));

%% IDs
ID = readtable("/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv"); ID = table2array(ID(:,1));

%% Paths
BASEPATH = 'BASE';
VOX='2';

PLSPATH = ([BASEPATH,'/3_PLS/SD_', VOX, 'mm/']);
MASKPATH= ([BASEPATH,'1_Preprocessing/Masks/Yeo7/net/']);
SAVEPATH= ([PLSPATH, 'taskPLS_N156_result_masked/']);
conditions = {'back1','back2','back3'};%set all relevant condition names

% load subject file for common coords
load([PLSPATH, 'SD_C200_BfMRIsessiondata.mat'],'st_coords'); %load st_coords

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yeo 7 networks %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k=1:7 %7 nets
    % load networks and select voxel
    coords{k} = [];
    net=S_load_nii_2d([MASKPATH, num2str(k) ,'/net', num2str(k),'_Yeo2011_7Networks_MNI152_FreeSurferConformed2mm_LiberalMask.nii.gz']);
    %net=find(net);
    %coords_net=intersect(st_coords, net);
    coords_net=find(net(st_coords));
    coords{k}=vertcat(coords{k}, coords_net);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% mask model with network nets %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(ID)
    for k=1:length(conditions)
        load([PLSPATH, 'SD_C', ID{i}, '_BfMRIsessiondata.mat'], 'st_datamat'); 
        
        SD=st_datamat(k, coords{1}); % for all three conditions k
        BS_net1(i, k)=mean(SD);% average SD for all those voxels
        
        % network 2
        SD=st_datamat(k, coords{2}); % for all three conditions k
        BS_net2(i, k)=mean(SD);

        
        % network 3
        SD=st_datamat(k, coords{3}); % for all three conditions k
        BS_net3(i, k)=mean(SD);
  
        
        % network 4
        SD=st_datamat(k, coords{4}); % for all three conditions k
        BS_net4(i, k)=mean(SD);
  
        
        % network 5
        SD=st_datamat(k, coords{5}); % for all three conditions k
        BS_net5(i, k)=mean(SD);

        
        % network 6
        SD=st_datamat(k, coords{6}); % for all three conditions k
        BS_net6(i, k)=mean(SD);

        
        % network 7
        SD=st_datamat(k, coords{7}); % for all three conditions k
        BS_net7(i, k)=mean(SD);
    end
end

save([SAVEPATH, 'masked_taskPLSN156_Yeo7.mat'], 'BS_net1', 'BS_net2', 'BS_net3', 'BS_net4', 'BS_net5', 'BS_net6','BS_net7');

%% Check if they look sane: %%%%%
nii=S_load_nii_2d([BASEPATH,'1_Preprocessing_fMRI/Standards/MNI152_T1_2mm_brain.nii.gz']);

for k=1:7 %7 nets

clearvars nifti;
    % load networks and select voxel
    coords{k} = [];
    nets{k} = [];
    net=S_load_nii_2d([MASKPATH, num2str(k) ,'/net', num2str(k),'_Yeo2011_7Networks_MNI152_FreeSurferConformed2mm_LiberalMask.nii.gz']);
    net=find(net);
    nets{k} = vertcat(nets{k}, net);
    coords_net=intersect(st_coords, net);
    coords{k}=vertcat(coords{k}, coords_net);
    
%     check if files look ok: save it as a nifti
%     data=zeros(length(nii), 1); 
%     data(coords_net)=1;
%     nifti=load_nii([BASEPATH,'/Standards/MNI152_T1_2mm_brain.nii.gz']);
%     nifti.img=reshape(data, nifti.hdr.dime.dim(2),nifti.hdr.dime.dim(3),nifti.hdr.dime.dim(4),size(nifti.img,4));
%     save_nii(nifti, [BASEPATH,'yeo_net',num2str(k),'_coords.nii'])
end

% compare length of arrays

percent_cutoff = [];
for k=1:7 %7 nets
    
    net_before = nets{k};
    net_after = coords{k};

    net_before = length(net_before);
    net_after = length(net_after);

    percent_cutoff(1, k) = 100-((net_after/net_before)*100);
end

load([SAVEPATH, 'masked_taskPLSN156_Yeo7.mat']);
allDat=[];
allDat(:,4) = [];
allDat(:,5) = [];

allDat=[BS_net1; BS_net2; BS_net3; BS_net4; BS_net5; BS_net6; BS_net7];
allDat(:,4) = allDat(:,2)-allDat(:,1);
allDat(:,5) = allDat(:,3)-allDat(:,2);

load([SAVEPATH, 'yeo_nets_all_SDBold.mat']);
