%create_SDnback_PCAdim_PLSanalysis_MAT

BASEPATH='BASE';
DATAPATH='DATA';
PLSPATH=([BASEPATH, '/3_PLS/']);

%IDs
ID = readtable("/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv"); ID = table2array(ID(:,1));

%for masking the  dimensionality values
%mask_181=ismember(ID181, ID);
load([BASEPATH, '/toolboxes/PLS_batch_matrix_input_savev7.3/templates/behav_BfMRIanalysis.mat']); %load MAT template 

%load PCAdim
%temporal
load([BASEPATH, '/4_PCA_Dimensionality/N181_PCAcorr_dimensionality_temporal.mat']);

permutations=1000; 
bootstrap=1000; 

%temporal
batch_file.result_file=['behavPLS_COBRA_N163_SDBOLDnback_temporalPCAdim_', num2str(permutations), 'P', num2str(bootstrap), 'B_BfMRIresult.mat']; %name result file 

batch_file.smallResult=0; % produce small result file
batch_file.num_split=0; % no split-halfs
batch_file.selected_cond=[1, 1, 1, 0]; % all three conditions
batch_file.num_boot=bootstrap; 
batch_file.num_perm=permutations; 
num_cond=length(find(batch_file.selected_cond)); 
num_subj=length(ID);


for i=1:num_subj
    batch_file.group_files{1, 1}{i, 1} = (['SD_C', ID{i}, '_2mm_BfMRIsessiondata.mat']);
end

for k=1:num_cond
    behav_values((num_subj*(k-1)+1):(k*num_subj), 1)=dimensionality(mask_181, k); %stack all 3 condition PCAdim values 
end

batch_file.behavdata=behav_values; %PCAdim
%temporal
batch_file.behavname={'temporalPCAdim'};
ave([PLSPATH, 'SD_2mm/behavPLS_COBRA_N163_SDBOLDnback_temporalPCAdim_', num2str(permutations), 'P', num2str(bootstrap), 'B_BfMRIanalysis.mat'], 'batch_file');


