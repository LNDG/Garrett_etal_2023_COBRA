function C_0_PCA_factor_calculation_14Shirer_networks(ID)

%script for finding dimensionality of 90% of total PCA variance
%within a set of variables.

%/opt/matlab/R2016b/bin/mcc -m C_PCA_factor_calculation_14Shirer_networks.m -a /toolboxes/preprocessing_tools -a /toolboxes/NIFTI_toolbox

%% IDs

%N181 ID={'001', '002', '003', '006', '007', '008', '009', '010', '011', '013', '014', '015', '016', '017', '018', '019', '021', '022', '023', '024', '025', '026', '027', '028', '029', '030', '031', '032', '033', '034', '035', '036', '037', '038', '039', '040', '041', '043', '045', '046', '047', '049', '050', '051', '052', '053', '054', '056', '057', '058', '059', '060', '061', '063', '064', '065', '066', '067', '068', '069', '071', '072', '073', '074', '075', '076', '079', '080', '081', '082', '083', '084', '085', '087', '090', '091', '092', '093', '094', '095', '096', '097', '098', '099', '104', '105', '106', '107', '108', '109', '110', '112', '113', '114', '116', '117', '118', '119', '120', '121', '122', '123', '126', '127', '130', '131', '132', '133', '134', '135', '136', '137', '138', '139', '140', '141', '142', '143', '144', '146', '148', '149', '150', '152', '153', '154', '155', '156', '158', '159', '160', '161', '162', '163', '164', '165', '168', '169', '170', '172', '173', '174', '176', '177', '178', '179', '180', '181', '183', '184', '185', '186', '187', '188', '190', '191', '192', '193', '194', '195', '196', '197', '198', '199', '200', '201', '202', '203', '204', '205', '206', '208', '210', '211', '212', '213', '214', '216', '217', '219', '220'};
%N163
ID={'001', '003', '006', '007', '008', '009', '010', '013', '014', '015', '016', '017', '018', '019', '021', '022', '024', '025', '027', '028', '029', '030', '032', '033', '034', '035', '036', '038', '040', '041', '043', '045', '046', '049', '050', '051', '052', '053', '056', '057', '058', '059', '060', '061', '063', '064', '065', '066', '067', '068', '069', '071', '072', '073', '074', '075', '076', '079', '080', '081', '082', '084', '085', '087', '090', '091', '092', '093', '094', '095', '097', '099', '104', '105', '106', '107', '108', '109', '110', '112', '113', '114', '116', '117', '118', '119', '120', '121', '122', '123', '126', '127', '130', '131', '133', '134', '135', '136', '137', '138', '139', '140', '143', '144', '146', '148', '149', '150', '152', '153', '154', '155', '156', '158', '159', '160', '161', '162', '163', '164', '165', '168', '169', '170', '172', '173', '174', '176', '177', '178', '180', '181', '183', '184', '185', '186', '187', '188', '190', '191', '192', '193', '194', '195', '196', '197', '198', '199', '200', '201', '203', '204', '206', '208', '210', '211', '212', '213', '214', '216', '217', '219', '220'};

%% Paths
BASEPATH = 'BASE';

modality='spatial';
%modality='temporal';

SAVEPATH = ([BASEPATH,'/dimensionality_nback/', modality, '_PCA/']);
NIFTIPATH=([BASEPATH, '/preproc_nback/preproc/C']);
MASKPATH= ([BASEPATH,'/dimensionality_nback/scripts/Shirer_masks/']);
VOX='2';
conditions = {'back1','back2','back3'};%set all relevant condition names


%get st_coords
load([BASEPATH, '/PLS/SD_2mm/SD_C002_2mm_BfMRIsessiondata.mat'], 'st_coords');

%network_names={'ant_salience', 'auditory', 'basal_ganglia', 'dorsal_DMN', 'high_visual', 'language', 'LECN', 'post_salience', 'precuneus', 'prim_visual', 'RECN', 'sensorimotor', 'ventral_DMN', 'visuospatial'};

%% load network coords
network_names={'anterior_Salience.nii', 'Auditory.nii', 'Basal_Ganglia.nii', 'dDMN.nii', 'high_Visual.nii', 'Language.nii', 'LECN.nii', 'post_Salience.nii', 'Precuneus.nii', 'prim_Visual.nii', 'RECN.nii', 'Sensorimotor.nii', 'vDMN.nii', 'Visuospatial.nii'};
for k=1:length(network_names)
    coords=S_load_nii_2d([MASKPATH, network_names{k}]);
    network_coords=coords(st_coords);
    network{k}=logical(network_coords);   
end    
%call waitbar
%h=waitbar(0,'You are on your way to results!');



%for i=1:length(ID)
    for k=1:length(network_names)

    
    clear a;
  a = load([BASEPATH, '/PLS_nback/scripts/mean_data/C',ID{i},'_nback_', VOX, 'mm_BfMRIsessiondata.mat']);%this loads a subject's sessiondata file.
    
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
      fname = ([NIFTIPATH, ID{i}, '/C', ID{i}, '_nback_FEAT_detrend_filt_FIX_MNI2mm.nii.gz']);
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
       data = cond_data{cond}(network{k},:); %only within network!

       tic;[~, ~, ~, ~, EXPLAINED{cond}] = pca(data', 'VariableWeights','variance', 'Centered', true); toc;   % spatial PCA using correlation matrix
       %initialize matrices
        TotalVar=0;
        Dimensions(1, cond)=0;

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
      end
      
 %% save individual .mats
%save([SAVEPATH, 'C', ID{i}, 'PCAcorr_', network_names{k}, '_dim.mat'], 'Dimensions');%note that EXPLAINED here is from typical, unrotated solution. 
%disp (['saved to: ', SAVEPATH, ID{i}]);

    PCAdim_14networks(k, :)=Dimensions;
    end
        
    save([SAVEPATH, 'C', ID, '_PCAdim_', modality, '_Shirer14networks.mat'], 'PCAdim_14networks');%note that EXPLAINED here is from typical, unrotated solution. 

for i=1: length(ID)
     load ([SAVEPATH, 'C', ID{i}, 'PCAcorr_BasalGanglia_dim.mat'], 'Dimensions');
     dimensionality(i, :)=Dimensions;
 end
save([SAVEPATH, 'N181_PCAcorr_BasalGanglia_dimensionality.mat'], 'dimensionality');

end