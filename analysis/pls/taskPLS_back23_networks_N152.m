%% Mask wholebrain task PLS with all nets

addpath('/Volumes/FB-LIP/LNDG/Programs_Tools_Scripts/preprocessing_tools/')
addpath('/Volumes/FB-LIP/LNDG/Programs_Tools_Scripts/NIFTI_toolbox/')


clear all
BASEPATH = '/Volumes/LNDG/Projects/COBRA/data';
SAVEPATH = [BASEPATH,'/mri+PETSharp/B_analyses/Paper1_2018/PLS_nback/SD_2mm/taskPLS_N152_results_masked/'];

PLSPATH = [BASEPATH,'/mri+PETSharp/B_analyses/Paper1_2018/PLS_nback/SD_2mm/Whole_brain/'];
ID={'001','003','006','007','008','009','010','013','014','015','016','017','018','019','021','022',...
    '024','025','027','029','030','032','034','035','038','040','041','043','045','046','049','050',...
    '051','052','053','056','057','058','059','060','061','063','064','065','066','067','068','069',...
    '071','072','073','075','079','080','081','082','084','085','087','090','092','093','094','095',...
    '097','099','104','105','106','107','108','109','110','112','114','116','117','118','119','120',...
    '121','122','123','126','127','130','131','133','134','135','136','138','139','140','143','144',...
    '146','148','149','150','152','153','154','155','156','158','159','160','161','162','163','164',...
    '165','168','169','170','172','173','174','176','177','178','180','181','183','184','185','186',...
    '188','190','191','192','193','194','195','196','197','199','200','201','203','204','206','208',...
    '210','211','212','213','214','216','217','219'};

% load whole brain task PLS
load([BASEPATH,'/mri+PETSharp/B_analyses/Paper1_2018/PLS_nback/SD_2mm/Whole_brain/TaskPLS_COBRA_N152_23back_1000P1000B_BfMRIresult.mat'], 'result', 'st_coords')
SD_coords = st_coords;
SD_u = result.u(:,1);

% load Yeo networks (unified based on wholebrain SD coordinates see: LNDG/Projects/COBRA/data/COBRA_masks-selected/Yeo7/extract_yeo_coords.m)
load([BASEPATH,'/COBRA_masks-selected/Yeo7/net/SDmasked_coordinates_Yeo7.mat']);
net_coords = coords;

% basal ganglia: load BGHAT/Morel network
seed=S_load_nii_2d([BASEPATH, '/COBRA_masks-selected/BGHAT_Morel_combined.nii']);
coords_BGHAT_Morel=find(seed(st_coords));


cond = [2,3];
networks = [1,3,6,7];%(Visual, DAN, FPN, DMN)
%%
for i=1:length(ID)
    i_sub = ID{i};
    load([PLSPATH, 'SD_C', i_sub, '_BfMRIsessiondata.mat'], 'st_datamat'); 
    for k=1:2 % conditions (2-back, 3-back)
        i_cond = cond(k);
        %for n = 1:4 % networks
        %i_net = networks(n);
        SD =st_datamat(i_cond, net_coords{1}); % mask subject SD data with net coordinates
        BS_vis(i,k)=dot(SD', SD_u(net_coords{1}));

        SD =st_datamat(i_cond, net_coords{3}); % mask subject SD data with net coordinates
        BS_DAN(i,k)=dot(SD', SD_u(net_coords{3}));

        SD =st_datamat(i_cond, net_coords{6}); % mask subject SD data with net coordinates
        BS_FPN(i,k)=dot(SD', SD_u(net_coords{6}));
        
        SD =st_datamat(i_cond, net_coords{7}); % mask subject SD data with net coordinates
        BS_DMN(i,k)=dot(SD', SD_u(net_coords{7}));
        % so here I'm not averaging SD across each network?
        %meanSD{i,k,n}=SD{k,n};
        
        SD=st_datamat(i_cond, coords_BGHAT_Morel); 
        BS_BGHAT_Morel(i, k)=dot(SD', SD_u(coords_BGHAT_Morel));
    end
end

save([SAVEPATH, 'masked_taskPLSN152_allNets.mat'], 'BS_vis', 'BS_DAN', 'BS_FPN', 'BS_DMN', 'BS_BGHAT_Morel');