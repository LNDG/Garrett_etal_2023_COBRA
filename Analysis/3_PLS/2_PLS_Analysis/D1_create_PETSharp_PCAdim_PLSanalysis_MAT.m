%create_SDnback_PETSharp_PLSanalysis_MAT

BASEPATH='BASE';
PLSPATH=([BASEPATH, '/3_PLS/']);

%ID
ID = readtable("SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv"); ID = ID(:,1);

load([PLSPATH, '/toolboxes/PLS_batch_matrix_input_savev7.3/templates/behav_BfMRIanalysis.mat']); %load MAT template 

%load PCAdim
%temporal
load([BASEPATH, '/4_PCA_Dimensionality/N181_PCAcorr_dimensionality_temporal.mat']);

permutations=1000; 
bootstrap=1000; 

%temporal
batch_file.result_file=['behavPLS_COBRA_N163_PETSharp_nback_temporalPCAdim_', num2str(permutations), 'P', num2str(bootstrap), 'B_BfMRIresult.mat']; %name result file 

batch_file.smallResult=0; % produce small result file
batch_file.num_split=0; % no split-halfs
batch_file.selected_cond=[1]; % all three conditions
batch_file.num_boot=bootstrap; 
batch_file.num_perm=permutations; 
num_cond=length(find(batch_file.selected_cond)); 
num_subj=length(ID);

    for i=1:num_subj
        batch_file.group_files{1, 1}{i, 1} = (['PET_C', ID{i}, '_COBRA_6mm_BfMRIsessiondata.mat']);
    end
    

% batch_file.behavdata=dimensionality(ID, :); %PCAdim
% %temporal
batch_file.behavname={'1back', '2back', '3back'};
 save([PLSPATH, 'PET_6mm/behavPLS_COBRA_N163_PETSharp_nback_temporalPCAdim_', num2str(permutations), 'P', num2str(bootstrap), 'B_BfMRIanalysis.mat'], 'batch_file');

