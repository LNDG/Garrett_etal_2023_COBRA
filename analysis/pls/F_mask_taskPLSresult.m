F_mask_taskPLSresult
% this script loads the full PLS model, masks the brain saliences to only
% relevant regions and re-calculateds the latent brain scores per subject
% within only these regions 
% Vincent's ROI and Shirer Network

%% IDs

%N163
%ID={'001', '003', '006', '007', '008', '009', '010', '013', '014', '015', '016', '017', '018', '019', '021', '022', '024', '025', '027', '028', '029', '030', '032', '033', '034', '035', '036', '038', '040', '041', '043', '045', '046', '049', '050', '051', '052', '053', '056', '057', '058', '059', '060', '061', '063', '064', '065', '066', '067', '068', '069', '071', '072', '073', '074', '075', '076', '079', '080', '081', '082', '084', '085', '087', '090', '091', '092', '093', '094', '095', '097', '099', '104', '105', '106', '107', '108', '109', '110', '112', '113', '114', '116', '117', '118', '119', '120', '121', '122', '123', '126', '127', '130', '131', '133', '134', '135', '136', '137', '138', '139', '140', '143', '144', '146', '148', '149', '150', '152', '153', '154', '155', '156', '158', '159', '160', '161', '162', '163', '164', '165', '168', '169', '170', '172', '173', '174', '176', '177', '178', '180', '181', '183', '184', '185', '186', '187', '188', '190', '191', '192', '193', '194', '195', '196', '197', '198', '199', '200', '201', '203', '204', '206', '208', '210', '211', '212', '213', '214', '216', '217', '219', '220'};
%N162 without C033
ID={'001', '003', '006', '007', '008', '009', '010', '013', '014', '015', '016', '017', '018', '019', '021', '022', '024', '025', '027', '028', '029', '030', '032', '034', '035', '036', '038', '040', '041', '043', '045', '046', '049', '050', '051', '052', '053', '056', '057', '058', '059', '060', '061', '063', '064', '065', '066', '067', '068', '069', '071', '072', '073', '074', '075', '076', '079', '080', '081', '082', '084', '085', '087', '090', '091', '092', '093', '094', '095', '097', '099', '104', '105', '106', '107', '108', '109', '110', '112', '113', '114', '116', '117', '118', '119', '120', '121', '122', '123', '126', '127', '130', '131', '133', '134', '135', '136', '137', '138', '139', '140', '143', '144', '146', '148', '149', '150', '152', '153', '154', '155', '156', '158', '159', '160', '161', '162', '163', '164', '165', '168', '169', '170', '172', '173', '174', '176', '177', '178', '180', '181', '183', '184', '185', '186', '187', '188', '190', '191', '192', '193', '194', '195', '196', '197', '198', '199', '200', '201', '203', '204', '206', '208', '210', '211', '212', '213', '214', '216', '217', '219', '220'};


%% Paths
BASEPATH = 'BASE';
VOX='2';

PLSPATH = ([BASEPATH,'data/mri+PETSharp/B_analyses/Paper1_2018/PLS_nback/SD_', VOX, 'mm/']);
MASKPATH= ([BASEPATH,'data/COBRA_masks-selected/']);
SAVEPATH= ([PLSPATH, 'taskPLS_N162_result_masked/']);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Vincent's seeds / networks %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load FPN seeds and extract coords
coords_FPN=[];
for k=1:9 %9 seeds
    seed=S_load_nii_2d([MASKPATH, 'VincentROIs/', num2str(k),  '_mask.nii.gz']);
    coords_seed=find(seed(st_coords));
    coords_FPN=vertcat(coords_FPN, coords_seed);
end

%load DAN seeds
coords_DAN=[];
for k=10:15 %6 seeds
    seed=S_load_nii_2d([MASKPATH, 'VincentROIs/',num2str(k),  '_mask.nii.gz']);
    coords_seed=find(seed(st_coords));
    coords_DAN=vertcat(coords_DAN, coords_seed);
end

%load DMN seeds
coords_DMN=[];
for k=16:21 %6 seeds
    seed=S_load_nii_2d([MASKPATH, 'VincentROIs/',num2str(k),  '_mask.nii.gz']);
    coords_seed=find(seed(st_coords));
    coords_DMN=vertcat(coords_DMN, coords_seed);
end

%load striatal seeds
coords_STM=[];
for k=1:4 %4 seeds
    seed=S_load_nii_2d([MASKPATH, 'VincentROIs/',num2str(k),  '_mask_STM.nii.gz']);
    coords_seed=find(seed(st_coords));
    coords_STM=vertcat(coords_STM, coords_seed);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shirer's matched networks: FPN, DAN, DMN, visual, basal gang %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%for FPN: load LECN, RECN and anterior salience
FPN={'LECN', 'RECN', 'anterior_Salience'};
coords_FPN=[];
for k=1:length(FPN)
    seed=S_load_nii_2d([MASKPATH, 'Shirer_masks/', FPN{k},  '.nii']);
    coords_seed=find(seed(st_coords));
    coords_FPN=vertcat(coords_FPN, coords_seed);
end

%for DAN: load visuospatial 
DAN={'Visuospatial'};
coords_DAN=[];
for k=1:length(DAN)
    seed=S_load_nii_2d([MASKPATH, 'Shirer_masks/', DAN{k},  '.nii']);
    coords_seed=find(seed(st_coords));
    coords_DAN=vertcat(coords_DAN, coords_seed);
end

%for DMN: load dDMN and vDMN 
DMN={'dDMN', 'vDMN'};
coords_DMN=[];
for k=1:length(DMN)
    seed=S_load_nii_2d([MASKPATH, 'Shirer_masks/', DMN{k},  '.nii']);
    coords_seed=find(seed(st_coords));
    coords_DMN=vertcat(coords_DMN, coords_seed);
end

%visual network: load primary and higher visual
visual={'prim_Visual', 'high_Visual'};
coords_visual=[];
for k=1:length(visual)
    seed=S_load_nii_2d([MASKPATH, 'Shirer_masks/', visual{k},  '.nii']);
    if k==1
        coords_prim_visual=find(seed(st_coords));
    else
        coords_high_visual=find(seed(st_coords));
    end
    coords_seed=find(seed(st_coords));
    coords_visual=vertcat(coords_visual, coords_seed);
end


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

%Vincent: FPN, DAN, DMN, STM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(ID)
    for k=1:length(conditions)
        load([PLSPATH, 'SD_C', ID{i}, '_2mm_BfMRIsessiondata.mat'], 'st_datamat'); 
        SD=st_datamat(k, coords_FPN); % for all three conditions k
        BS_FPN(i, k)=dot(SD', u(coords_FPN)); %dot product between masked SD values and masked brain saliences per condition
        SD=st_datamat(k, coords_DAN); 
        BS_DAN(i, k)=dot(SD', u(coords_DAN)); %dot product between masked SD values and masked brain saliences per condition
        SD=st_datamat(k, coords_DMN); 
        BS_DMN(i, k)=dot(SD', u(coords_DMN)); %dot product between masked SD values and masked brain saliences per condition
        SD=st_datamat(k, coords_STM); 
        BS_STM(i, k)=dot(SD', u(coords_STM)); %dot product between masked SD values and masked brain saliences per condition
    end
end


%Shirer's matched networks: FPN, DAN, DMN, visual, basal_gang
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(ID)
    for k=1:length(conditions)
        load([PLSPATH, 'SD_C', ID{i}, '_2mm_BfMRIsessiondata.mat'], 'st_datamat'); 
        SD=st_datamat(k, coords_FPN); % for all three conditions k
        BS_FPN(i, k)=dot(SD', u(coords_FPN)); %dot product between masked SD values and masked brain saliences per condition
        SD=st_datamat(k, coords_DAN); 
        BS_DAN(i, k)=dot(SD', u(coords_DAN)); %dot product between masked SD values and masked brain saliences per condition
        SD=st_datamat(k, coords_DMN); 
        BS_DMN(i, k)=dot(SD', u(coords_DMN)); %dot product between masked SD values and masked brain saliences per condition
        SD=st_datamat(k, coords_visual); 
        BS_visual(i, k)=dot(SD', u(coords_visual)); %dot product between masked SD values and masked brain saliences per condition
        SD=st_datamat(k, coords_high_visual); 
        BS_high_visual(i, k)=dot(SD', u(coords_high_visual)); %dot product between masked SD values and masked brain saliences per condition
        SD=st_datamat(k, coords_prim_visual); 
        BS_prim_visual(i, k)=dot(SD', u(coords_prim_visual)); %dot product between masked SD values and masked brain saliences per condition
        SD=st_datamat(k, coords_basal_gang); 
        BS_basal_gang(i, k)=dot(SD', u(coords_basal_gang)); %dot product between masked SD values and masked brain saliences per condition
        SD=st_datamat(k, coords_BGHAT_Morel); 
        BS_BGHAT_Morel(i, k)=dot(SD', u(coords_BGHAT_Morel)); %dot product between masked SD values and masked brain saliences per condition
    end
end
%save([SAVEPATH, 'masked_taskPLSN162_Shirer_selected.mat'], 'BS_FPN', 'BS_DAN', 'BS_DMN', 'BS_visual', 'BS_prim_visual', 'BS_high_visual', 'BS_basal_gang');
save([SAVEPATH, 'masked_taskPLSN162_Shirer_selected_unweighted.mat'], 'BS_FPN', 'BS_DAN', 'BS_DMN', 'BS_visual', 'BS_prim_visual', 'BS_high_visual', 'BS_basal_gang', 'BS_BGHAT_Morel');
