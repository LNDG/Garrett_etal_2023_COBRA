function B1_tempPCAdim_BGHAT_Morel(ID)
% this script calculates the dimensionality within a combined BGHAT (basal
% ganglia) / Morel (thalamus) mask with the help of temporal PCA


%% 
%IDs
ID = readtable("/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv"); ID = table2array(ID(:,1));

BASEPATH='BASE';

%NIIPATH=([BASEPATH, 'imaging_files/nback/preproc/']);
PLSPATH=([BASEPATH, '/3_PLS/']);
MASKPATH=([BASEPATH,'/1_Preprocessing/Masks/']);


%% create mask: Morel and BGHAT regions combined in one nifti
Morel=S_load_nii_2d([MASKPATH, 'Morel/Thalamus_Morel_consolidated_mask_v3.nii']);
BGHAT=S_load_nii_2d([MASKPATH, 'BGHAT_Prodoehl_2008/BGHAT_MNI2mm_mask.nii.gz']);

coords_Morel=find(Morel);
coords_BGHAT=find(BGHAT);

BGHAT_Morel=zeros(length(BGHAT), 1);
BGHAT_Morel(coords_Morel)=1; 
BGHAT_Morel(coords_BGHAT)=1; 

nifti=load_nii([MASKPATH, 'Morel/Thalamus_Morel_consolidated_mask_v3.nii']);
nifti.img=BGHAT_Morel;
save_nii(nifti, [MASKPATH, 'BGHAT_Morel_combined.nii']);

%get st_coords
load([BASEPATH, '/3_PLS/SD_2mm/SD_C001_2mm_BfMRIsessiondata.mat'], 'st_coords');
%calculate BGHAT/Morel coords in st_coord space
BGHAT_st_coords=find(BGHAT(st_coords));
Morel_st_coords=find(Morel(st_coords));
BGHAT_Morel_coords=unique(vertcat(BGHAT_st_coords, Morel_st_coords));

%%%%%%%%%%%%%%%%%%%%%%
%% calcualte PCAdim %%
%%%%%%%%%%%%%%%%%%%%%%

modality='temporal';

SAVEPATH = ([BASEPATH,'/4_PCA_Dimensionality/', modality, '_PCA/BGHAT_Morel/']);
NIFTIPATH=([BASEPATH,'/preproc_nback/preproc/C']);
VOX='2';
conditions = {'back1','back2','back3'};%set all relevant condition names


for i=1:length(ID)
      clearvars a;
      a = load([BASEPATH, '/3_PLS/mean_data/C',ID{i},'_nback_', VOX, 'mm_BfMRIsessiondata.mat']);%this loads a subject's sessiondata file.

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
            disp(['bljak ' ID{i}  ' something wrong in block onset lengths']);
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
      fname = ([NIFTIPATH, ID{i}, '/', ID{i}, '_nback_FEAT_detrend_filt_FIX_MNI2mm.nii.gz']);
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
       data = cond_data{cond}(BGHAT_Morel_coords,:); %only within network!

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
      
      disp([num2str(Dimensions)]);
      Var_explained_1stfactor(1, :)=explained_var;
      disp([num2str(explained_var)]);
          
     save([SAVEPATH, ID{i}, '_PCAdim_', modality, '_BGHAT_Morel.mat'], 'Dimensions', 'Var_explained_1stfactor');%note that EXPLAINED here is from typical, unrotated solution. 
     disp(['saved as ', SAVEPATH, ID{i}, '_PCAdim_', modality, '_BGHAT_Morel.mat']);
 
  end
end