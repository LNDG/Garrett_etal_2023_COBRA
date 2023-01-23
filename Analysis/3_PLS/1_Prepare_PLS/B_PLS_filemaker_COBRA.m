function B_PLS_filemaker_COBRA
%% 
%% creates batchfiles for PLS
%%add these to workingpath
% -m PLS_filemaker_COBRA -a /scripts/toolboxes/pls -a /scripts/toolboxes/parfor_progress

%% Paths

BASEPATH = 'DATAPATH';
VOX = '2';
ID = readtable("/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv"); ID = table2array(ID(:,1));

    for k=1:length(ID)
        BATCHPATH = ([BASEPATH, '/C', ID{k}, '_', VOX, 'mm_PLS_batchfile.txt']);
        cd (BASEPATH)
        fprintf('Creating PLS_data_mat for subject %s \n', ID{k});
        batch_plsgui (BATCHPATH);
        fprintf('Finished creating PLS_data_mat for subject %s \n', SIID{k}D);	
    end

end