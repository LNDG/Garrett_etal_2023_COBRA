function C_bandpass_filter_detrend( subjID )
% This function bandpass filters unfiltered nifti files with a butterworth
% filter. And detrend to k order 


%% Variables
%% IDs
ID = readtable("/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv"); ID = table2array(ID(:,1));

BASEPATH = 'BASE';

for k=1:length(ID)
    
    DATAPATH = ([BASEPATH,'imaging_files/nback/preproc/C', ID{k}, '/']);

    %% check if session 2 is available

    if ~exist (DATAPATH,'file') == 7
        exit;
    end

    %% load nifti

    img = load_nii ([DATAPATH,'/FEAT.feat/filtered_func_data.nii.gz']);
    nii = double(reshape(img.img, [], img.hdr.dime.dim(5)));

    % TR
    TR = img.hdr.dime.pixdim(5);

    %%load mask

    mask = load_nii ([DATAPATH,'/FEAT.feat/filtered_func_data_mask_mask.nii.gz']);
    mask = double(reshape(mask.img, [], mask.hdr.dime.dim(5)));
    mask_coords = find(mask);

    % mask image
    nii_masked = nii(mask_coords,:);


    %% Detrend
    k = 3;           % linear , quadratic and cubic detrending

    % get TS voxel means
    nii_means = mean(nii_masked,2);

    [ nii_masked ] = S_detrend_data2D( nii_masked, k );


    %% readd TS voxel means
    for i=1:size(nii_masked,2)
        nii_masked(:,i) = nii_masked(:,i)+nii_means;
    end

    disp ([subjID, ': add mean back done']);


    %% filter
    % parameters, for detail see help NoseGenerator.m

    LowCutoff = 0.01;
    HighCutoff = 0.1;
    filtorder = 8;
    samplingrate = 1/TR;         %in Hz, TR=2s, FS=1/(TR=2)


    %parfor_progress(size(nii,1));
    for i = 1:size(nii_masked,1)

        [B,A] = butter(filtorder,LowCutoff/(samplingrate/2),'high'); 
        nii_masked(i,:)  = filtfilt(B,A,nii_masked(i,:)); clear A B;

        [B,A] = butter(filtorder,HighCutoff/(samplingrate/2),'low');
        nii_masked(i,:)  = filtfilt(B,A,nii_masked(i,:)); clear A B


        %parfor_progress;
    end


    %% readd TS voxel means
    for i=1:size(nii_masked,2)
        nii_masked(:,i) = nii_masked(:,i)+nii_means;
    end


    disp ([ID{k}, ': detrending + bandpass filtering + add mean back done']);

    %parfor_progress(0);


    %% save file


    nii(mask_coords,:)= nii_masked;

    img.img = nii;
    save_nii (img, [DATAPATH,'/C', ID{k},'_nback_FEAT_detrend_filt.nii.gz'])
    disp (['saved as: ',[DATAPATH,'/C', ID{k},'_nback_FEAT_detrend_filt.nii.gz']])
end

end

