function behav = plotSDT_DDMpars()

addpath('/Users/kloosterman/Dropbox/tardis_code/MATLAB/tools/custom_tools/plotting/plotSpread')

% N=156, HDDM1 
% csv = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/COBRA_DDMdata.csv');
% ddm = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/params_HDDMbias.csv');
% rub = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/gelman_rubin_vals.csv');

% % % N=152, HDDM2, has 4 subjects with G-R above 1.1
% csv = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/COBRA_DDMdata_drop_lowdprime.csv');
% ddm = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/params__biasmodel.csv');

% % % % N=152, HDDM2, 15 chains
% csv = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/COBRA_DDMdata_drop_lowdprime.csv');
% ddm = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/params__biasmodel_drop_lowdprime.csv');

PREIN = '/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/';
cd(PREIN)
time = ''; % early_ late_
% % % % N=152, only early trials in block
csv = readtable(fullfile(PREIN, 'COBRA_DDMdata_drop_lowdprime.csv'));
ddm = readtable(fullfile(PREIN, sprintf('params_run_biasmodel_%sdrop_lowdprime.csv', time)));

% % % % % N=152, only early trials in block
% csv = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/COBRA_DDMdata_drop_lowdprime.csv');
% ddm = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/params_run_biasmodel_early_drop_lowdprime.csv');

% % % % N=152, only late trials in block
% csv = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/COBRA_DDMdata_drop_lowdprime.csv');
% ddm = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/params_run_biasmodel_late_drop_lowdprime.csv');



% N = 148, has 2 more subjects with G-R above 1.1
% csv = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/COBRA_DDMdata_lowdprimedropped_R-Gdropped.csv');
% ddm = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/params__biasmodel_dprimedropped_R-Gdropped.csv');

% % N = 146, all good
% csv = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/COBRA_DDMdata_drop_lowdprime_and_gelman_rubin2.csv');
% ddm = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/params__biasmodel_dprimedropped_R-Gdropped2.csv');
% rub = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/gelman_rubin_vals_dprimedropped_R-Gdropped2.csv');


disp 'remove NaN trials'
csv = rmmissing(csv);

subj = transpose(unique(csv.subj_idx));
nsub = length(subj);
behav=[];
behav.condleg = { '1'  '2'  '3' '2-1' '3-2'};
behav.modelfree_behavior = ...
  {'meanRT' 'sdRT' 'meanRTyes' 'meanRTno' 'meanRTcorrect'...
  'meanRTerror' 'meanRTYescorrect' 'meanRTNocorrect' 'accuracy' 'H' ...
  'FA' 'propcorrect' 'dprime' 'criterion' 'prop_yes' ...
  'accuracy_Yes', 'accuracyNo' 'RTyescorrect' 'RTnocorrect'};
behav.modelfree = NaN(5, length(subj), length(behav.modelfree_behavior) );

for icond=1:3
  dat = csv( csv.stim == str2double(behav.condleg{icond}),:);  
  for isub = 1:nsub
    subjdat = dat(dat.subj_idx == subj(isub),:);
    behav.modelfree(icond,isub,1)   = median(subjdat.rt);
    behav.modelfree(icond,isub,2)   = std(subjdat.rt);
    
    behav.modelfree(icond,isub,3)   = mean(subjdat.rt(subjdat.response == 1));
    behav.modelfree(icond,isub,4)   = mean(subjdat.rt(subjdat.response == 0));
    behav.modelfree(icond,isub,5)   = mean(subjdat.rt(subjdat.stimulus == subjdat.response));
    behav.modelfree(icond,isub,6)   = mean(subjdat.rt(subjdat.stimulus == ~subjdat.response));
    behav.modelfree(icond,isub,7)   = mean(subjdat.rt(subjdat.stimulus == 1 & subjdat.response == 1));
    behav.modelfree(icond,isub,8)   = mean(subjdat.rt(subjdat.stimulus == 0 & subjdat.response == 0));
    
    behav.modelfree(icond,isub,9) = sum(subjdat.stimulus == subjdat.response) / ...
      numel(subjdat.stimulus == subjdat.response);
    
    behav.modelfree(icond,isub,10) = sum(subjdat.stimulus == 1 & subjdat.response == 1) / ...
       sum(subjdat.stimulus == 1);
     if behav.modelfree(icond,isub,10) == 1
       behav.modelfree(icond,isub,10) = 0.99;
     end
     behav.modelfree(icond,isub,11) = sum(subjdat.stimulus == 0 & subjdat.response == 1) / ...
       sum(subjdat.stimulus == 0);
     if behav.modelfree(icond,isub,11) == 0
       behav.modelfree(icond,isub,11) = 0.01;
     end
     
     behav.modelfree(icond,isub,12) = 0.5 * (behav.modelfree(icond,isub,10) - behav.modelfree(icond,isub,11)) + 0.5;  % proportion correct

     behav.modelfree(icond,isub,13) = norminv(behav.modelfree(icond,isub,10)) - norminv(behav.modelfree(icond,isub,11));
     behav.modelfree(icond,isub,14) = -0.5*(norminv(behav.modelfree(icond,isub,10))+norminv(behav.modelfree(icond,isub,11)));
     behav.modelfree(icond,isub,15) = sum(subjdat.response == 1) / size(subjdat,1);

     % accuracy for yes responses
     behav.modelfree(icond,isub,16) = sum(subjdat.stimulus == 1 & subjdat.response == 1 ) / ...
       sum( subjdat.stimulus == 1 );
     % accuracy for no responses
     behav.modelfree(icond,isub,17) = sum(subjdat.stimulus == 0 & subjdat.response == 0 ) / ...
       sum( subjdat.stimulus == 0 );
     
     % accuracy for yes correct responses
     behav.modelfree(icond,isub,18)   = mean(subjdat.rt(subjdat.stimulus == 1 & subjdat.response == 1));
     behav.modelfree(icond,isub,19)   = mean(subjdat.rt(subjdat.stimulus == 0 & subjdat.response == 0));

     behav.COBRA_ID(:,isub) = subjdat.COBRA_ID(1);
     
     
  end
end

behav.modelfree(4,:,:) = behav.modelfree(2,:,:) - behav.modelfree(1,:,:);
behav.modelfree(5,:,:) = behav.modelfree(3,:,:) - behav.modelfree(2,:,:);

inc_subj = behav.modelfree(1,:,13) > 1; % 4 dropped
lowdprimesubj = find(behav.modelfree(1,:,13) < 1); % 4 dropped, 
if ~isempty(lowdprimesubj)
  disp 'COBRA_IDs subjects with dprime at 1-back < 1:'
  disp(behav.COBRA_ID(inc_subj == 0))
end

behav.ddm=[];
behav.ddm.pardimord = {'a' 'v' 't' 'z' 'dc'};
for icond=1:3
  dat = ddm(contains(ddm.Var1, ['(' behav.condleg{icond} ')']),:);
  % TODO match ddm and csv data using COBRA_ID, makes sure ID's match
  for isub = 1:length(subj)
    [~,a]=strtok(dat.Var1, '.');
    subjdat = dat(strcmp(a, sprintf('.%d', subj(isub))),:);
    behav.ddm.estimates(icond,isub,:) = subjdat.mean;
    %TODO add rubin gelman
  end
end
behav.ddm.estimates(4,:,:) = behav.ddm.estimates(2,:,:) - behav.ddm.estimates(1,:,:);
behav.ddm.estimates(5,:,:) = behav.ddm.estimates(3,:,:) - behav.ddm.estimates(2,:,:);

behav.modelfree_dimord = 'condition_subj_behavtype';
save COBRA_behavior.mat behav
% modelfree = permute(behav.modelfree, [2 3 1])
% modelfree(:,:)
% T = table(behav.modelfree, 'VariableNames', behav.modelfree_behavior)


%% % plotting modelfree
close all
plotmeas = {'dprime' 'criterion' 'prop_yes' 'meanRT'...
  'meanRTyes' 'meanRTno' 'meanRTcorrect' 'meanRTerror' 'sdRT' ...
  'accuracy' 'propcorrect' 'accuracy_Yes', 'accuracyNo' ...
  'RTyescorrect' 'RTnocorrect'};
f = figure; iplot=0;
ncol = length(plotmeas);
nrow = 2;
f.Position =[   680   467   125*ncol   200*nrow];
for im = 1:length(plotmeas)
  subplot(nrow,ncol,im)  
  behavind = find(strcmp(plotmeas{im}, behav.modelfree_behavior));
  data = behav.modelfree(1:3, :, behavind)';
  plotspreadfig(data, 6, behav.condleg);
  title(sprintf('%s\nN=%d', plotmeas{im}, length(data)))
%   if contains(plotmeas{im}, 'meanRT')
%     ylim([0.5 1.3])
%   end
end

%% plot ddm
for ipar = 1:5
  subplot(nrow,ncol,ipar+im)
  data = squeeze(behav.ddm.estimates(1:3,:,ipar))';
  plotspreadfig(data, 6, behav.condleg);
  title(sprintf('%s\nN=%d %s', behav.ddm.pardimord{ipar}, length(data), time))
end
saveas(f, sprintf('COBRA_SDTvsDDM_%s.png', time))
orient landscape
saveas(f, sprintf('COBRA_SDTvsDDM_%s.pdf', time))
disp 'done'

%% corr dc vs  RTs yes no error correct
plotmeas = {'dprime' 'meanRT' 'meanRTYescorrect' 'meanRTNocorrect' 'meanRTyes' 'meanRTno' 'meanRTcorrect' 'meanRTerror'};
corrtype = 'Spearman';

for iddm = 4:5
  f=figure; iplot=0
  f.Position =[   680   467  600   1100];
  for im = 1:length(plotmeas)
    for icond = 1:5
      iplot=iplot+1;
      behavind = find(strcmp(plotmeas{im}, behav.modelfree_behavior));
      d1 =behav.modelfree(icond, :, behavind)';
      d2 =behav.ddm.estimates(icond,:,iddm)';
      subplot(length(plotmeas),5,iplot)
      scatter(d1, d2, 'filled', 'MarkerFaceColor', 'k' , 'MarkerEdgeColor', 'w', 'sizedata', 30)
      [r,p] = corr(d1, d2, 'type', corrtype);
      title(sprintf('%s %s r= %1.2f', plotmeas{im}, behav.condleg{icond}, r))
      box on; axis square; axis tight; lsline;
      xlabel(plotmeas{im})
      ylabel(behav.ddm.pardimord{iddm})
      ax=gca;
      ax.FontSize = 6;
    end
  end
  saveas(f, sprintf('COBRA_meanRTvs%s_%s.pdf', behav.ddm.pardimord{iddm}, corrtype ))
  saveas(f, sprintf('COBRA_meanRTvs%s_%s.png', behav.ddm.pardimord{iddm}, corrtype ))  
end


%% corr criterion vs z and dc
plotmeas = {'criterion'};
im=1;

f=figure; iplot=0
f.Position =[   680   467  600   200];
for iddm = 4:5
  for icond = 1:length(behav.condleg)
    iplot=iplot+1;
    behavind = find(strcmp(plotmeas{im}, behav.modelfree_behavior));
    d1 =behav.modelfree(icond, :, behavind)';
    d2 =behav.ddm.estimates(icond,:,iddm)';
    subplot(2,5,iplot)
    scatter(d1, d2, 'filled', 'MarkerFaceColor', 'k' , 'MarkerEdgeColor', 'w', 'sizedata', 30)
    [r,p] = corr(d1, d2);
    title(sprintf('%s r=%1.2f', behav.condleg{icond}, r))
    box on; axis square; axis tight; lsline; 
    xlabel(plotmeas{im})
    ylabel(behav.ddm.pardimord{iddm})
    ax=gca;
    ax.FontSize = 6;
  end
end
saveas(f, sprintf('COBRA_%svsDDMbias.pdf', plotmeas{im}))
saveas(f, sprintf('COBRA_%svsDDMbias.png', plotmeas{im}))
% saveas(f,'COBRA_meanRTvsDDMbias.png')

%% corr dprime vs criterion ALSO in 3-2back chch
behav.dprime(4,:) = behav.dprime(3,:) - behav.dprime(2,:);
behav.dprime(5,:) = behav.dprime(2,:);
behav.dprime(6,:) = behav.dprime(3,:);

behav.criterion(4,:) = behav.criterion(3,:) - behav.criterion(2,:);
behav.criterion(5,:) = behav.criterion(3,:) - behav.criterion(2,:);
behav.criterion(6,:) = behav.criterion(3,:) - behav.criterion(2,:);
behav.condleg{4} = '3?2back';
behav.condleg{5} = '3?2back crit vs 2back dprime';
behav.condleg{6} = '3?2back crit vs 3back dprime';
f=figure; iplot=0
f.Position =[   680   467  450   300];
for icond = 1:6
  iplot=iplot+1;
  d1 = behav.dprime(icond,:)';
  d2 = behav.criterion(icond,:)';
  subplot(2,3,iplot)
  scatter(d1, d2, 'filled', 'MarkerFaceColor', 'k' , 'MarkerEdgeColor', 'w', 'sizedata', 30)
  [r,p] = corr(d1, d2);
  title(sprintf('%s r=%1.2f', behav.condleg{icond}, r))
  box on; axis square; axis tight; lsline;
  xlabel('Dprime')
  ylabel('Criterion')
  ax=gca;
  ax.FontSize = 6;
end
saveas(f,'COBRA_CritvsDprime.pdf')
saveas(f,'COBRA_CritvsDprime.png')

%% plot bars + lines: plotspreadfig
