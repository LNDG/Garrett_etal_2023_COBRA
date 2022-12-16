%script for renaming and sorting Yeo networks

%% IDs
%ID 156, '001','003','006',
ID={'001','003','006','007','008','009','010','013','014','015','016','017','018','019','021','022','024','025','027','028','029','030','032','034','035','038','040','041','043','045','046','049','050','051','052','053','056','057','058','059','060','061','063','064','065','066','067','068','069','071','072','073','075','079','080','081','082','084','085','087','090','091','092','093','094','095','097','099','104','105','106','107','108','109','110','112','114','116','117','118','119','120','121','122','123','126','127','130','131','133','134','135','136','137','138','139','140','143','144','146','148','149','150','152','153','154','155','156','158','159','160','161','162','163','164','165','168','169','170','172','173','174','176','177','178','180','181','183','184','185','186','188','190','191','192','193','194','195','196','197','198','199','200','201','203','204','206','208','210','211','212','213','214','216','217','219'};

BASEPATH='BASE';
SAVEPATH = ([BASEPATH,'/dimensionality_nback/temporal_PCA/Yeo/']);
%NIIPATH=([BASEPATH, 'imaging_files/nback/preproc/']);
PLSPATH=([BASEPATH, '/PLS_nback/SD_2mm/']);
MASKPATH=([BASEPATH,'COBRA_masks-selected/Yeo7/net/']);

for i=1:length(ID)
    load([SAVEPATH, 'C', ID{i}, '_PCAdim_temp_Yeo7.mat'], 'PCAdim_networks', 'Var_explained_1stfactor', 'network_names');%note that EXPLAINED here is from typical, unrotated solution. 
        PCAdim_Vis(i, :)=PCAdim_networks(1, :);
        PCAdim_SMN(i, :)=PCAdim_networks(2, :);
        PCAdim_DAN(i, :)=PCAdim_networks(3, :);
        PCAdim_VAN(i, :)=PCAdim_networks(4, :);
        PCAdim_Lim(i, :)=PCAdim_networks(5, :);
        PCAdim_FPN(i, :)=PCAdim_networks(6, :);
        PCAdim_DMN(i, :)=PCAdim_networks(7, :);
        VarEXPL_1stfactor_Vis(i, :)=Var_explained_1stfactor(1, :);
        VarEXPL_1stfactor_SMN(i, :)=Var_explained_1stfactor(2, :);
        VarEXPL_1stfactor_DAN(i, :)=Var_explained_1stfactor(3, :);
        VarEXPL_1stfactor_VAN(i, :)=Var_explained_1stfactor(4, :);
        VarEXPL_1stfactor_Lim(i, :)=Var_explained_1stfactor(5, :);
        VarEXPL_1stfactor_FPN(i, :)=Var_explained_1stfactor(6, :);
        VarEXPL_1stfactor_DMN(i, :)=Var_explained_1stfactor(7, :);
end
save ([SAVEPATH, 'N156_PCAdim_VarEXPL_temp_Yeo7.mat'], 'PCAdim_Vis', 'PCAdim_SMN', 'PCAdim_DAN', 'PCAdim_VAN', 'PCAdim_Lim', 'PCAdim_FPN', 'PCAdim_DMN', 'VarEXPL_1stfactor_Vis', 'VarEXPL_1stfactor_SMN', 'VarEXPL_1stfactor_DAN', 'VarEXPL_1stfactor_VAN', 'VarEXPL_1stfactor_Lim', 'VarEXPL_1stfactor_FPN', 'VarEXPL_1stfactor_DMN', 'ID');


load([SAVEPATH,'N156_PCAdim_VarEXPL_temp_Yeo7.mat']);

allDat=[];allDat(:,4) = [];


allDat=[PCAdim_Vis; PCAdim_SMN; PCAdim_DAN; PCAdim_VAN; PCAdim_Lim; PCAdim_FPN; PCAdim_DMN];
allDat(:,4) = allDat(:,2)-allDat(:,1);
allDat(:,5) = allDat(:,3)-allDat(:,2);
