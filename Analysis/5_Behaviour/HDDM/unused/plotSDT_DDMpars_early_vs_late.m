function behav = plotSDT_DDMpars_early_vs_late()

addpath('/tardis_code/MATLAB/tools/custom_tools/plotting/plotSpread')

PREIN = '/HDDM/123back_bias_novelvsfam/data/';
cd(PREIN)
time = {'early' 'late'};
timename = {'early_no_z' 'late_no_z'};

% behav_earlylate;
for itime = 1:2
  csv = readtable(fullfile(PREIN, 'COBRA_DDMdata_drop_lowdprime.csv'));
  csv = csv(csv.(time{itime})==1, :); % select early or late trials
  
  ddm = readtable(fullfile(PREIN, sprintf('params_run_biasmodel_%s_drop_lowdprime.csv', timename{itime})));
  
  disp 'remove NaN trials'
  csv = rmmissing(csv);
  
  subj = transpose(unique(csv.subj_idx));
  nsub = length(subj);
  behav=[];
  behav.condleg = { '1'  '2'  '3' '2-1' '3-2'};
  behav.modelfree_behavior = {'meanRT' 'sdRT' 'meanRTyes' 'meanRTno' 'meanRTcorrect' 'meanRTerror' 'meanRTYescorrect' 'meanRTNocorrect' 'accuracy' 'H' 'FA' 'propcorrect' 'dprime' 'criterion' 'prop_yes' };
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
%   behav.ddm.pardimord = {'a' 'v' 't' 'z' 'dc'};
  behav.ddm.pardimord = {'a' 'v' 't' 'dc'};
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
  
  behav_earlylate(itime) = behav;
end
behav = behav_earlylate;
clear behav_earlylate

save COBRA_behavior_earlylate.mat behav

%% % plotting modelfree
close all
plotmeas = {'dprime' 'criterion' 'prop_yes' 'meanRT' 'meanRTyes' 'meanRTno' 'meanRTcorrect' 'meanRTerror' 'sdRT' 'accuracy' 'propcorrect' };
f = figure; iplot=0;
ncol = length(plotmeas);
nrow = 2;
f.Position =[   680   467   125*ncol   200*nrow];
for itime=1:2
  for im = 1:length(plotmeas)
    iplot=iplot+1;
    subplot(nrow,ncol,iplot)
    behavind = find(strcmp(plotmeas{im}, behav(itime).modelfree_behavior));
    data = behav(itime).modelfree(1:3, :, behavind)';
    plotspreadfig(data, 6, behav.condleg);
    title(sprintf('%s\nN=%d %s', plotmeas{im}, length(data), time{itime}))
    %   if contains(plotmeas{im}, 'meanRT')
    %     ylim([0.5 1.3])
    %   end
  end
end
saveas(f, sprintf('COBRA_SDT_earlylate.png'))


%% plot ddm
f = figure; f.Position = [0         0         664        1223];
iplot=0; nrow = 3; ncol = 2;
data=cat(4,behav(1).ddm.estimates, behav(2).ddm.estimates);
% condcolors = [1 0.5 0.5; 0.5 0.5 1; 0.5 1 0.5; 0.5 0.5 0.5];
% cols = {'r' 'r' 'b' 'b' 'g' 'g' 'k' 'k' };
condcolors = [1 0.5 0.5; 0.5 0.5 1; 0.5 1 0.5;];
cols = {'r' 'r' 'b' 'b' 'g' 'g' };
lab = {'1back early' '1back late' '2back early' '2back late' '3back early' '3back late' };
for ipar = 1:4
  %   for itime=1:2
  subplot(nrow,ncol,ipar)
%   plotdat = squeeze(data([1:3,5],:,ipar,:));
  plotdat = squeeze(data(1:3,:,ipar,:));
  plotdat = permute(plotdat, [3 1 2]);
  plotdat = reshape(plotdat, [], nsub)';
  h = plotSpread(num2cell(plotdat,1), 'distributionMarkers', 'o', 'distributionColors', cols, 'categoryLabels', lab'); 
  h{3}.XTickLabelRotation=45;
  h{3}.XTickLabel = lab;
  [~,p1] = ttest(plotdat(:,1), plotdat(:,2));
  [~,p2] = ttest(plotdat(:,3), plotdat(:,4));
  [~,p3] = ttest(plotdat(:,5), plotdat(:,6));
  title(sprintf('N=%d pvals %1.3f %1.3f %1.3f \n%s',  length(data), p1, p2, p3, behav(itime).ddm.pardimord{ipar}))
  width = 0.7;
  
  for i=1:size(plotdat,2)
    line([i-width/2 i+width/2]', [nanmean(plotdat(:,i)) nanmean(plotdat(:,i))]',  'Color', 'w', 'Linewidth', 3)
  end
  %   end
end
saveas(f, sprintf('COBRA_SDTvsDDM_early_vs_late.png'))
orient landscape
% saveas(f, sprintf('COBRA_SDTvsDDM_%s.pdf', time{itime}))
% disp 'done'

