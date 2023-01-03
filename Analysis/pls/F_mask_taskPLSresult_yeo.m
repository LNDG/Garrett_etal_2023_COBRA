F_mask_taskPLSresult_yeo
% this script loads the full PLS model, masks the brain saliences to only
% relevant regions and re-calculateds the latent brain scores per subject
% within only these regions 
% Yeo Networks

addpath('/toolboxes/pls/')
addpath('/scripts/')
addpath(genpath('/toolboxes/preprocessing_tools'));
addpath(genpath('/toolboxes/NIFTI_toolbox'));

%% IDs

%N163
%ID={'001', '003', '006', '007', '008', '009', '010', '013', '014', '015', '016', '017', '018', '019', '021', '022', '024', '025', '027', '028', '029', '030', '032', '033', '034', '035', '036', '038', '040', '041', '043', '045', '046', '049', '050', '051', '052', '053', '056', '057', '058', '059', '060', '061', '063', '064', '065', '066', '067', '068', '069', '071', '072', '073', '074', '075', '076', '079', '080', '081', '082', '084', '085', '087', '090', '091', '092', '093', '094', '095', '097', '099', '104', '105', '106', '107', '108', '109', '110', '112', '113', '114', '116', '117', '118', '119', '120', '121', '122', '123', '126', '127', '130', '131', '133', '134', '135', '136', '137', '138', '139', '140', '143', '144', '146', '148', '149', '150', '152', '153', '154', '155', '156', '158', '159', '160', '161', '162', '163', '164', '165', '168', '169', '170', '172', '173', '174', '176', '177', '178', '180', '181', '183', '184', '185', '186', '187', '188', '190', '191', '192', '193', '194', '195', '196', '197', '198', '199', '200', '201', '203', '204', '206', '208', '210', '211', '212', '213', '214', '216', '217', '219', '220'};
%N162 without C033
%ID={'001', '003', '006', '007', '008', '009', '010', '013', '014', '015', '016', '017', '018', '019', '021', '022', '024', '025', '027', '028', '029', '030', '032', '034', '035', '036', '038', '040', '041', '043', '045', '046', '049', '050', '051', '052', '053', '056', '057', '058', '059', '060', '061', '063', '064', '065', '066', '067', '068', '069', '071', '072', '073', '074', '075', '076', '079', '080', '081', '082', '084', '085', '087', '090', '091', '092', '093', '094', '095', '097', '099', '104', '105', '106', '107', '108', '109', '110', '112', '113', '114', '116', '117', '118', '119', '120', '121', '122', '123', '126', '127', '130', '131', '133', '134', '135', '136', '137', '138', '139', '140', '143', '144', '146', '148', '149', '150', '152', '153', '154', '155', '156', '158', '159', '160', '161', '162', '163', '164', '165', '168', '169', '170', '172', '173', '174', '176', '177', '178', '180', '181', '183', '184', '185', '186', '187', '188', '190', '191', '192', '193', '194', '195', '196', '197', '198', '199', '200', '201', '203', '204', '206', '208', '210', '211', '212', '213', '214', '216', '217', '219', '220'};
%ID 156
ID={'001','003','006','007','008','009','010','013','014','015','016','017','018','019','021','022','024','025','027','028','029','030','032','034','035','038','040','041','043','045','046','049','050','051','052','053','056','057','058','059','060','061','063','064','065','066','067','068','069','071','072','073','075','079','080','081','082','084','085','087','090','091','092','093','094','095','097','099','104','105','106','107','108','109','110','112','114','116','117','118','119','120','121','122','123','126','127','130','131','133','134','135','136','137','138','139','140','143','144','146','148','149','150','152','153','154','155','156','158','159','160','161','162','163','164','165','168','169','170','172','173','174','176','177','178','180','181','183','184','185','186','188','190','191','192','193','194','195','196','197','198','199','200','201','203','204','206','208','210','211','212','213','214','216','217','219'};

%% Paths
BASEPATH = 'BASE';
VOX='2';

PLSPATH = ([BASEPATH,'data/mri+PETSharp/B_analyses/Paper1_2018/PLS_nback/SD_', VOX, 'mm/']);
MASKPATH= ([BASEPATH,'data/COBRA_masks-selected/Yeo7/net/']);
%MASKPATH2= ([BASEPATH,'data/COBRA_masks-selected/']);
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Tian Hippocampus %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MASKPATH_hip= ([MASKPATH,'/Tian_hippocampus/']);
%load hip seeds and extract coords
coords_hip=[];
for k=1:2 %2 rh/lh
    seed=S_load_nii_2d([MASKPATH_hip, num2str(k), '_HIP_Tian_Subcortex_S1_3T_2mm.nii.gz']);
    coords_seed=find(seed(st_coords));
    coords_hip_DMN=vertcat(coords_hip, coords_seed, coords{7});
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(ID)
    for k=1:length(conditions)
        load([PLSPATH, 'SD_C', ID{i}, '_BfMRIsessiondata.mat'], 'st_datamat'); 
        
        SD=st_datamat(k, coords_hip); 
        BS_Hip_DMN(i, k)=mean(SD); %dot product between masked SD values and masked brain saliences per condition
    end
end

save([SAVEPATH, 'masked_taskPLSN156_Hip_Tian_DMN_Yeo.mat']);

%% Check if they look sane: %%%%%
nii=S_load_nii_2d([BASEPATH,'/Standards/MNI152_T1_2mm_brain.nii.gz']);

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
