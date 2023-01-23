function Run_PLS_analysis_MAT(PLSPATH, textfile)
%% 

%runs PLS analysis from mat-file
%% Paths

BASEPATH = 'BASE';
PLSPATH = ([BASEPATH, '/3_PLS/']);

%% prep

cd (PLSPATH);
permutations=1000; 
bootstrap=1000; 

% change matfile according to which PLS you want to run! Check file
% beforehands!
matfile = [PLSPATH, 'SD_2mm/behavPLS_COBRA_N163_SDBOLDnback_temporalPCAdim_', num2str(permutations), 'P', num2str(bootstrap), 'B_BfMRIanalysis.mat'];

batch_plsgui (matfile);

end


