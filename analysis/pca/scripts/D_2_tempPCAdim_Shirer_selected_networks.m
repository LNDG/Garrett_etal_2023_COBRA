function D_2_tempPCAdim_Shirer_selected_networks(ID)

%script for finding dimensionality of 90% of total PCA variance
%within a set of variables.

%/opt/matlab/R2016b/bin/mcc -m D_2_tempPCAdim_Shirer_selected_networks.m -a /home/mpib/LNDG/COBRA/data/mri+PETSharp/B_analyses/Paper1_2018/PLS_nback/scripts/toolboxes/NIFTI_toolbox -a /home/mpib/LNDG/COBRA/data/mri+PETSharp/B_analyses/Paper1_2018/PLS_nback/scripts/toolboxes/preprocessing_tools 

%% IDs

%N162 without C033
%ID={'001', '003', '006', '007', '008', '009', '010', '013', '014', '015', '016', '017', '018', '019', '021', '022', '024', '025', '027', '028', '029', '030', '032', '034', '035', '036', '038', '040', '041', '043', '045', '046', '049', '050', '051', '052', '053', '056', '057', '058', '059', '060', '061', '063', '064', '065', '066', '067', '068', '069', '071', '072', '073', '074', '075', '076', '079', '080', '081', '082', '084', '085', '087', '090', '091', '092', '093', '094', '095', '097', '099', '104', '105', '106', '107', '108', '109', '110', '112', '113', '114', '116', '117', '118', '119', '120', '121', '122', '123', '126', '127', '130', '131', '133', '134', '135', '136', '137', '138', '139', '140', '143', '144', '146', '148', '149', '150', '152', '153', '154', '155', '156', '158', '159', '160', '161', '162', '163', '164', '165', '168', '169', '170', '172', '173', '174', '176', '177', '178', '180', '181', '183', '184', '185', '186', '187', '188', '190', '191', '192', '193', '194', '195', '196', '197', '198', '199', '200', '201', '203', '204', '206', '208', '210', '211', '212', '213', '214', '216', '217', '219', '220'};

%% Paths
BASEPATH = 'BASE';
modality='temporal';

SAVEPATH = ([BASEPATH,'/dimensionality_nback/', modality, '_PCA/Shirer_networks_selected/']);
NIFTIPATH=([BASEPATH, '/preproc_nback/preproc/C']);
MASKPATH= ([BASEPATH,'/COBRA_masks-selected/']);
VOX='2';
conditions = {'back1','back2','back3'};%set all relevant condition names


%get st_coords
load([BASEPATH, '/PLS/SD_2mm/SD_C002_2mm_BfMRIsessiondata.mat'], 'st_coords');

%% load network coords
network_names={'FPN', 'DAN', 'DMN', 'prim_visual', 'high_visual', 'visual', 'basal_ganglia'};

%for FPN: load LECN, RECN and anterior salience
FPN={'LECN', 'RECN', 'anterior_Salience'};
coords_FPN=[];
for k=1:length(FPN)
    seed=S_load_nii_2d([MASKPATH, 'Shirer_masks/', FPN{k},  '.nii']);
    coords_seed=find(seed(st_coords));
    coords_FPN=vertcat(coords_FPN, coords_seed);
end
coords_networks{1}=coords_FPN;

%for DAN: load visuospatial 
DAN={'Visuospatial'};
coords_DAN=[];
for k=1:length(DAN)
    seed=S_load_nii_2d([MASKPATH, 'Shirer_masks/', DAN{k},  '.nii']);
    coords_seed=find(seed(st_coords));
    coords_DAN=vertcat(coords_DAN, coords_seed);
end
coords_networks{2}=coords_DAN;

%for DMN: load dDMN and vDMN 
DMN={'dDMN', 'vDMN'};
coords_DMN=[];
for k=1:length(DMN)
    seed=S_load_nii_2d([MASKPATH, 'Shirer_masks/', DMN{k},  '.nii']);
    coords_seed=find(seed(st_coords));
    coords_DMN=vertcat(coords_DMN, coords_seed);
end
coords_networks{3}=coords_DMN;

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
coords_networks{4}=coords_prim_visual;
coords_networks{5}=coords_high_visual;
coords_networks{6}=coords_visual;

%striatum: load basal ganglia network
basal_gang={'Basal_Ganglia'};
coords_basal_gang=[];
for k=1:length(basal_gang)
    seed=S_load_nii_2d([MASKPATH, 'Shirer_masks/', basal_gang{k},  '.nii']);
    coords_seed=find(seed(st_coords));
    coords_basal_gang=vertcat(coords_basal_gang, coords_seed);
end
coords_networks{7}=coords_basal_gang;


    
%% PCAdim calculation for every condition separataly 

%for i=1:length(ID)
    for k=1:length(network_names)

    
      clear a;
      a = load([BASEPATH, '/PLS/scripts/mean_data/C',ID,'_nback_2mm_BfMRIsessiondata.mat']);%this loads a subject's sessiondata file.

      % intialize cond specific scan count for populating cond_data
      clear count cond_data block_scan coeff block scores Dimensions EXPLAINED;
      for cond = 1:numel(conditions)
          count{cond} = 0;
      end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % within each block express each scan as deviation from block's 
    % temporal mean.Concatenate all these deviation values into one 
    % long condition specific set of scans that were normalized for 
    % block-to-block differences in signal strength. 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % for each condition identify its scans within  runs 
    % and prepare where to put cond specific normalized data
    used_run = [];
    for cond = 1:numel(conditions)
      tot_num_scans = 0;
      
      dst_run = 0;
      for run = 1:a.session_info.num_runs
        onsets = a.session_info.run(run).blk_onsets{cond}+1;% +1 is because we need matlab indexing convention
        if onsets==0 %this if statement looks for any conditions (within run) that don't have data of interest, and if it finds any, then the next "run" loop is entered.
            continue
        end
        
        dst_run = dst_run + 1;
        used_run(cond, run) = 1;
        
        lengths = a.session_info.run(run).blk_length{cond};
        
        for block = 1:numel(onsets)
          block_scans{cond}{dst_run}{block} = onsets(block)-1+[1:lengths(block)];
          this_length = lengths(block);
          if max(block_scans{cond}{dst_run}{block}>a.session_info.run(run).num_scans)
            disp(['bljak ' ID  ' something wrong in block onset lengths']);
            block_scans{cond}{dst_run}{block} = intersect(block_scans{cond}{dst_run}{block},[1:a.session_info.run(run).num_scans]);
            this_length = numel(block_scans{cond}{dst_run}{block});
          end
          tot_num_scans = tot_num_scans + this_length;
        end
      end
      cond_data{cond} = zeros(numel(st_coords),tot_num_scans);%create empty matrix with dimensions coords (rows) by total # of scans (columns). 
    end
    
    dst_run = 0;
      
   
      % load nifti file for 'this run
      %fname = ([a.session_info.run(run).data_path, '/', a.session_info.run(run).data_files{1}, '.gz']);
      fname = ([NIFTIPATH, ID, '/C', ID, '_nback_FEAT_detrend_filt_FIX_MNI2mm.nii']);
      nii = load_nii(fname); %(x by y by z by time)
      img = double(reshape(nii.img,[],size(nii.img,4)));% 4 here refers to 4th dimension in 4D file....time.
      img = img(st_coords,:);%this command constrains the img file to only use final_coords, which is common across subjects. 
      clear nii;

      
      dst_run = dst_run + 1;

      for cond = 1:numel(conditions)

        if not(used_run(cond,run))
          continue
        end
        
       for block = 1:numel(block_scans{cond}{run}) % {1:9} {1:6}  -> 4

          block_data = img(:,block_scans{cond}{dst_run}{block});% (vox time)
          % normalize block_data to global block mean = 100. 
          block_data = 100*block_data/mean(mean(block_data));
          % temporal mean of this block
          block_mean = mean(block_data,2); % (vox) - this should be 100
          % express scans in this block as  deviations from block_mean
          % and append to cond_data
          good_vox = find(block_mean);              
          for t = 1:size(block_data,2)
            count{cond} = count{cond} + 1;
            cond_data{cond}(good_vox,count{cond}) = block_data(good_vox,t) - block_mean(good_vox);%must decide about perc change option here!!??
          end
       end
       
       %% Dimensions
       data=0;
       data = cond_data{cond}(coords_networks{k},:); %only within network!

       tic;[~, ~, ~, ~, EXPLAINED{cond}] = pca(data, 'VariableWeights','variance', 'Centered', true); toc;   % temporal PCA using correlation matrix
       %initialize matrices
        TotalVar=0;
        Dimensions(1, cond)=0;
        explained_var(1, cond)=0;

        %% Extracting components explaining > 90% variance
        %calculate factor loading for number of dimensions (so that 90% of
        %total variance explained)
        for j=1:numel(EXPLAINED{cond})
        TotalVar=TotalVar+EXPLAINED{cond}(j);   %EXPLAINED represents variance accounted for by a given dimension.
        if TotalVar>90                      %set 90% criterion here.
            Dimensions(1, cond)=j-1;                 %if greater than 90, then go with previous dimension as final.
            break
        end
        end
        
        %% Percent of variance epxlianed by first component
        j=1;
        explained_var(1, cond)=EXPLAINED{cond}(j);
        
      end
      
 %% save individual .mats
%save([SAVEPATH, 'C', ID{i}, 'PCAcorr_', network_names{k}, '_dim.mat'], 'Dimensions');%note that EXPLAINED here is from typical, unrotated solution. 
%disp (['saved to: ', SAVEPATH, ID{i}]);

    PCAdim_networks(k, :)=Dimensions;
    disp([num2str(Dimensions)]);
    Var_explained_1stfactor(k, :)=explained_var;
    disp([num2str(explained_var)]);
    
    end
        
    save([SAVEPATH, 'C', ID, '_PCAdim_', modality, '_FPN_DAN_DMN_vis_basalG.mat'], 'PCAdim_networks', 'Var_explained_1stfactor', 'network_names');%note that EXPLAINED here is from typical, unrotated solution. 
    disp(['saved as ', SAVEPATH, 'C', ID, '_PCAdim_', modality, '_FPN_DAN_DMN_vis_basalG.mat']);
    
% for i=1:length(ID)
%     load([SAVEPATH, 'C', ID{i}, '_PCAdim_', modality, '_FPN_DAN_DMN_vis_basalG.mat'], 'PCAdim_networks', 'Var_explained_1stfactor', 'network_names');%note that EXPLAINED here is from typical, unrotated solution. 
%         PCAdim_FPN(i, :)=PCAdim_networks(1, :);
%         PCAdim_DAN(i, :)=PCAdim_networks(2, :);
%         PCAdim_DMN(i, :)=PCAdim_networks(3, :);
%         PCAdim_prim_vis(i, :)=PCAdim_networks(4, :);
%         PCAdim_high_vis(i, :)=PCAdim_networks(5, :);
%         PCAdim_visual(i, :)=PCAdim_networks(6, :);
%         PCAdim_basal_ganglia(i, :)=PCAdim_networks(7, :);
%         VarEXPL_1stfactor_FPN(i, :)=Var_explained_1stfactor(1, :);
%         VarEXPL_1stfactor_DAN(i, :)=Var_explained_1stfactor(2, :);
%         VarEXPL_1stfactor_DMN(i, :)=Var_explained_1stfactor(3, :);
%         VarEXPL_1stfactor_prim_vis(i, :)=Var_explained_1stfactor(4, :);
%         VarEXPL_1stfactor_high_vis(i, :)=Var_explained_1stfactor(5, :);
%         VarEXPL_1stfactor_visual(i, :)=Var_explained_1stfactor(6, :);
%         VarEXPL_1stfactor_basal_ganglia(i, :)=Var_explained_1stfactor(7, :);
% end
% save ([SAVEPATH, 'N162_PCAdim_VarEXPL_', modality, '_FPN_DAN_DMN_vis_basalG.mat'], 'PCAdim_FPN', 'PCAdim_DAN', 'PCAdim_DMN', 'PCAdim_prim_vis', 'PCAdim_high_vis', 'PCAdim_visual', 'PCAdim_basal_ganglia', 'VarEXPL_1stfactor_FPN', 'VarEXPL_1stfactor_DAN', 'VarEXPL_1stfactor_DMN', 'VarEXPL_1stfactor_prim_vis', 'VarEXPL_1stfactor_high_vis', 'VarEXPL_1stfactor_visual', 'VarEXPL_1stfactor_basal_ganglia', 'ID');
% 
end