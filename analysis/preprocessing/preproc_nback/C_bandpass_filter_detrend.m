function bandpass_filter_detrend( subjID )
% This function bandpass filters unfiltered nifti files with a butterworth
% filter. And detrend to k order 


%% Variables
%% check ID list!
ID={'001','002', '003','006','007','008','009','010','013','014','015','016','017','018','019','021','022','024','025','027','028','029','030','032','034','035','038','040','041','043','045','046','049','050','051','052','053','056','057','058','059','060','061','063','064','065','066','067','068','069','071','072','073','075','079','080','081','082','084','085','087','090','091','092','093','094','095','097','099','104','105','106','107','108','109','110','112','114','116','117','118','119','120','121','122','123','126','127','130','131','133','134','135','136','137','138','139','140','143','144','146','148','149','150','152','153','154','155','156','158','159','160','161','162','163','164','165','168','169','170','172','173','174','176','177','178','180','181','183','184','185','186','188','190','191','192','193','194','195','196','197','198','199','200','201','203','204','206','208','210','211','212','213','214','216','217','219'};

BASEPATH = ('BASE');

        
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

