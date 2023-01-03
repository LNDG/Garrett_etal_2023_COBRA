function D_SD_BOLD_maker_COBRA( )

% /opt/matlab/R2014b/bin/mcc -m SD_BOLD_maker_COBRA -a  /scripts/toolboxes/pls -a  /scripts/toolboxes/NIFTI_toolbox



% N181 (21.04.17)
ID={'001', '002', '003', '006', '007', '008', '009', '010', '011', '013', '014', '015', '016', '017', '018', '019', '021', '022', '023', '024', '025', '026', '027', '028', '029', '030', '031', '032', '033', '034', '035', '036', '037', '038', '039', '040', '041', '043', '045', '046', '047', '049', '050', '051', '052', '053', '054', '056', '057', '058', '059', '060', '061', '063', '064', '065', '066', '067', '068', '069', '071', '072', '073', '074', '075', '076', '079', '080', '081', '082', '083', '084', '085', '087', '090', '091', '092', '093', '094', '095', '096', '097', '098', '099', '104', '105', '106', '107', '108', '109', '110', '112', '113', '114', '116', '117', '118', '119', '120', '121', '122', '123', '126', '127', '130', '131', '132', '133', '134', '135', '136', '137', '138', '139', '140', '141', '142', '143', '144', '146', '148', '149', '150', '152', '153', '154', '155', '156', '158', '159', '160', '161', '162', '163', '164', '165', '168', '169', '170', '172', '173', '174', '176', '177', '178', '179', '180', '181', '183', '184', '185', '186', '187', '188', '190', '191', '192', '193', '194', '195', '196', '197', '198', '199', '200', '201', '202', '203', '204', '205', '206', '208', '210', '211', '212', '213', '214', '216', '217', '219', '220'};


NVal = num2str(length(ID));
BASEPATH = 'BASE';
VOX='2';

% %these commands find a common set of coords across subjects to find masked,
% %common coords. We first load the MNI template, already GM masked, and go from
% %there. Subject files MUST BE IN MNI space at this point!
load([DATAPATH, '/2mm_commoncoordsN181.mat'], 'common_coords');



%% Enable when testing/if running as interactive
addpath(genpath('/scripts/toolboxes/NIFTI_toolbox'));
addpath(genpath('/scripts/toolboxes/pls'));

disp('Loading mask...')
%load MNI GM mask
mask=load_nii([BASE, '/PLS_nback/scripts/GM_MNI_', VOX, 'mm_mask.nii']);
mask_coords = (find(mask.img))';
final_coords=intersect(common_coords,mask_coords);

disp ('adjusting conditions...')

%And now the real work begins to create the SDBOLD datamats :-)
%just PRE for now
conditions = {'back1','back2','back3','fix'};%set all relevant condition names

% %this command produces a waitbar to check on progress of datamat creation
% %for all files. Waitbar is then called within the loop.
% h=waitbar(0,'You are on your way to results!');

for i = 1:numel(ID) 
try

  clear a;
  a = load([BASEPATH, '/PLS_nback/scripts/mean_data/C',ID{i},'_nback_', VOX, 'mm_BfMRIsessiondata.mat']);%this loads a subject's sessiondata file.
  a = rmfield(a,'st_datamat');
  a = rmfield(a,'st_coords');

  %replace fields with correct info.
  a.session_info.datamat_prefix=['SD_C',ID{i}, '_', VOX, 'mm' ];
  a.st_coords = final_coords; 
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % create this subject's datamat
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  a.st_datamat = zeros(numel(conditions),numel(final_coords)); %(cond voxel)
    
      
  % intialize cond specific scan count for populating cond_data
  clear count cond_data block_scan;
  for cond = 1:numel(conditions)
      count{cond} = 0;
  end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % within each block express each scan as deviation from block's 
    % temporal mean.Concatenate all these deviation values into one 
    % long condition specific set of scans that were normalized for 
    % block-to-block differences in signal strength. In the end calculate
    % stdev across all normalized cond scans
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % for each condition identify its scans within  runs 
    % and prepare where to put cond specific normalized data
    used_run = [];
    for cond = 1:numel(conditions)
      tot_num_scans = 0;
      
      dst_run = 0;
      for run = 1:a.session_info.num_runs
        onsets = a.session_info.run(run).blk_onsets{cond}+1;% +1 is because we need matlab indexing convention
        if onsets==0; %this if statement looks for any conditions (within run) that don't have data of interest, and if it finds any, then the next "run" loop is entered.
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
      cond_data{cond} = zeros(numel(final_coords),tot_num_scans);%create empty matrix with dimensions coords (rows) by total # of scans (columns). 
    end
    
    dst_run = 0;
    for run = 1:a.session_info.num_runs   %1:2       
      
     
      %set right nifti path as sessiondatamat were created for the
      %unfiltered nifti, but we want to use the filtered, detrended,
      %denoised and despiked nifti here
            
        % load nifti file for this run
      fname = ([a.session_info.run(run).data_path, '/', a.session_info.run(run).data_files{1}]);
      nii = load_nii(fname); %(x by y by z by time)
      img = double(reshape(nii.img,[],size(nii.img,4)));% 4 here refers to 4th dimension in 4D file....time.
      img = img(final_coords,:);%this command constrains the img file to only use final_coords, which is common across subjects.
      clear nii;



      %now, proceed with creating SD datamat...          

	
	disp('writing SD data...')      
      
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
      end
    end

%   % now calc stdev across all cond scans.
    for cond = 1:numel(conditions)
      a.st_datamat(cond,:) = squeeze(std(cond_data{cond},0,2))';
    end
    %all values get saved in approp datamat below; nothing should need to be
    %saved to session files at this point, so leave those as is.
    clear data;
    save([BASEPATH, '/PLS_nback/SD_', VOX, 'mm/SD_C',ID{i}, '_', VOX, 'mm_BfMRIsessiondata.mat'],'-struct','a','-mat');
% 
%     waitbar(i/numel(ID),h);

    
   
	disp (['ID: ', ID{i}, ' done!'])

catch ME
	disp ( ME)
end
end	
end
