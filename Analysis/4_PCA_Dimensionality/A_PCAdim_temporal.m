function B_PCAdim_temporal(ID)

%script for finding dimensionality of 90% of total PCA variance
%within a set of variables.

%/opt/matlab/R2014b/bin/mcc -m B_PCAdim_temporal.m -a /toolboxes/preprocessing_tools -a /toolboxes/NIFTI_toolbox

%run as interactive job:
addpath(genpath('/toolboxes/preprocessing_tools')); 
addpath(genpath('/toolboxes/NIFTI_toolbox'));

% IDs
ID = readtable("/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv"); ID = table2array(ID(:,1));

%% Paths
BASEPATH = 'BASE';

SAVEPATH = ([BASEPATH,'/dimensionality_nback/temporal_PCA/']);
NIFTIPATH=([BASEPATH, '/preproc_nback/preproc/C']);

%get st_coords
load([BASEPATH, '/PLS/scripts/2mm_GM_commoncoordsN181.mat']);
st_coords=final_coords;
VOX='2';
conditions = {'back1','back2','back3'};%set all relevant condition names


for i = 1:numel(ID) 
clear a;
  a = load([BASEPATH, '/PLS/mean_data/C',ID{i},'_nback_', VOX, 'mm_BfMRIsessiondata.mat']);%this loads a subject's sessiondata file.
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
            disp(['bljak ' ID {i} ' something wrong in block onset lengths']);
            block_scans{cond}{dst_run}{block} = intersect(block_scans{cond}{dst_run}{block},[1:a.session_info.run(run).num_scans]);
            this_length = numel(block_scans{cond}{dst_run}{block});
          end
          tot_num_scans = tot_num_scans + this_length;
        end
      end
      cond_data{cond} = zeros(numel(st_coords),tot_num_scans);%create empty matrix with dimensions coords (rows) by total # of scans (columns). 
    end
    
    dst_run = 0;
      
   
        % load nifti file for this run
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
      % tic;[coeff.RAW{cond}, scores{cond}, ~, ~, EXPLAINED{cond}] = pca(cond_data{cond}', 'VariableWeights','variance', 'Centered', true); toc;   % spatial PCA using correlation matrix
       tic;[coeff.RAW{cond}, scores{cond}, ~, ~, EXPLAINED{cond}] = pca(cond_data{cond}, 'VariableWeights','variance', 'Centered', true); toc;   % temporal PCA using correlation matrix
       %Rows of X correspond to observations and columns correspond to variables
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
        
        %% standardize coeff scores to gain a comparable correlation matrix
        % to standardize, the scores (principal component scores) will be 
        % correlated with coeff.weights columnwise. I.e. each voxels TS is 
        % correlated with coeff.weights
        % for spatial PCA matrix has to be transposed 884*171922 -> 171922*884

        try
        coeff.STAND{cond} = corr(scores{cond}, cond_data{cond}');
        catch ME
        disp (ME.message)
        end
        
        %% create coefficient/eigenvector matrix of the rotated solution
        % with the exact number of dimenions for the subject previously calculated
        try
         coeff.STAND_ROT{cond}=rotatefactors(coeff.STAND{cond}(:, 1:Dimensions(1, cond)));%create rotated versions of standardized coeffs above. Default is varimax... 
        catch ME
         disp (ME.message)
        end
        
      end
   
%% save individual .mats
%save([SAVEPATH, 'C', ID{i}, 'PCAcorr_dim_spatial.mat'], 'Dimensions', 'coeff', 'EXPLAINED', 'scores');%note that EXPLAINED here is from typical, unrotated solution. 
save([SAVEPATH, 'C', ID{i}, 'PCAcorr_dim_temporal.mat'], 'Dimensions', 'coeff', 'EXPLAINED', 'scores');%note that EXPLAINED here is from typical, unrotated solution. 
disp (['saved to: ', SAVEPATH, ID{i}]);
     
end
% 
for i=1: length(ID)
   % load ([SAVEPATH, 'C', ID{i}, 'PCAcorr_dim_spatial.mat'], 'Dimensions');
    load ([SAVEPATH, 'C', ID{i}, 'PCAcorr_dim_temporal.mat'], 'Dimensions');
    dimensionality(i, :)=Dimensions;
end
%save([SAVEPATH, 'N181_PCAcorr_dimensionality_spatial.mat'], 'dimensionality');
save([SAVEPATH, 'N181_PCAcorr_dimensionality_temporal.mat'], 'dimensionality');

end