%% quantile prob plots of observed vs simulated data

% simdata = readtable('/HDDM/123back_bias_novelvsfam/data/data_simulated_fullbiasmodel.csv');
% obsdata = readtable('/HDDM/123back_bias_novelvsfam/data/data_observed_fullbiasmodel.csv');

% simdata = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/data_simulated_basicmodel.csv');
% obsdata = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/data_observed_basicmodel.csv');

PREIN = '/HDDM/123back_bias_novelvsfam/data/';
modelnames = {'avt + dc + z model'  'avt model'  'avt + z model' 'avt + dc model' };
model_filenames = {'fullbiasmodel.csv', 'basicmodel.csv', 'biasmodel_zonly.csv', 'biasmodel_dconly.csv' };
% DIC
% full bias model:  22334
% basic model:      22681
% z_only model:    23200
% dc only:              23836

model_dic = [22334 22681 23200 23836];

%% make quantiles observed data
% quantiles = [0.5 20 40 60 80 99.5];
quantiles = [0.5 10 30 50 70 90 99.5];
% quantiles = [10 20 40 60 80 90];
% quantiles = [10 30 50 70 90];
% quantiles = [0.5 10 30 50 70 90 99.5];
nbins = length(quantiles)-1;

bindat = [];
bindat_sim = [];
for imodel = 1:length(modelnames)
  
  simdata = readtable(fullfile(PREIN, ['data_simulated_' model_filenames{imodel}] ));
  simdata = simdata(abs(simdata.rt) < 1.5,:); % rt's longer not possible
  simdata = simdata(abs(simdata.rt) > 0.2,:); % short rt's dropped
  
  obsdata = readtable(fullfile(PREIN, ['data_observed_' model_filenames{imodel}] ));
  
  SUBJ = unique(obsdata.subj_idx);
  
  % for observed data
  % includes stim non-target or target: want plots for stim present and
  % absent
  for isub = 1:length(SUBJ)
    for istim = 0:1 % non-target or target
      for icond = 2:3 % only 2 and 3 back
        line_inds = obsdata.subj_idx == SUBJ(isub) & obsdata.stim == icond & obsdata.stimulus == istim;
        dat = [abs(obsdata.rt(line_inds)) obsdata.accuracy(line_inds) ]; % we want choice (0 is no), not accuracy
        prctile_edges = prctile(dat(:,1), quantiles);       % get RT quantiles
        [~,~,bin] = histcounts(dat(:,1), prctile_edges); % get bin that each trial belongs to
        dat = [dat bin]; % append
        for ibin = 1:nbins % get proportion responses per quantile
          for icorr = 0:1 % incorrect and correct
            bindat(imodel,isub, istim+1, ibin, icond-1, icorr+1, 1 ) = mean(dat(dat(:,3)==ibin & dat(:,2) == icorr, 1)); %mean RT per bin and correct/incorrect
            bindat(imodel,isub, istim+1, ibin, icond-1, icorr+1, 2 ) = length(dat(dat(:,3)==ibin & dat(:,2) == icorr, 2)) ./ length(find(dat(:,3)==ibin)); %correctness
          end
        end
      end
    end
  end
  
  % for simulated data sets (50)
  % includes stim non-target or target: want plots for stim present and
  % absent
  datasets_sim = unique(simdata.sample);
  
  for idata = 1:length(datasets_sim)
    disp(idata)
    curdat = simdata(simdata.sample==datasets_sim(idata),:);
    for isub = 1:length(SUBJ)
      for istim = 0:1 % non-target or target
        for icond = 2:3 % only 2 and 3 back
          line_inds = strcmp( sprintf('wfpt(%d.%d).%d', icond, istim, SUBJ(isub)), simdata.node ) & simdata.sample == datasets_sim(idata);
          %         line_inds = simdata.subj_idx == SUBJ(isub) & simdata.stim == icond & simdata.stimulus == istim;
          dat = [abs(simdata.rt(line_inds )) simdata.response(line_inds) ];
          
          prctile_edges = prctile(dat(:,1), quantiles);       % get RT quantiles
          [~,~,bin] = histcounts(dat(:,1), prctile_edges); % get bin that each trial belongs to
          dat = [dat bin]; % append
          for ibin = 1:nbins % get proportion responses per quantile
            for icorr = 0:1 % incorrect and correct
              bindat_sim(imodel,isub, idata, istim+1, ibin, icond-1, icorr+1, 1 ) = mean(dat(dat(:,3)==ibin & dat(:,2) == icorr, 1)); %mean RT per bin and correct/incorrect
              bindat_sim(imodel,isub, idata, istim+1, ibin, icond-1, icorr+1, 2 ) = length(dat(dat(:,3)==ibin & dat(:,2) == icorr, 2)) ./ length(find(dat(:,3)==ibin)); %correctness
            end
          end
        end
      end
    end
  end
end


%% plot quantile prob plot
close all
simdat_plottype = 'aggregate'; % singlesims
plottype = 'errorbars';  % errorbars  ellipse
bindat_avg = squeeze(nanmean(bindat,2)); % stim bins cond incorrect/correct RT/accuracy
bindat_sim_avg = squeeze(nanmean(bindat_sim,2)); % stim bins cond incorrect/correct RT/accuracy
titnames = {'Target absent' 'Target present'};
SAV=1;
YLIM = [0.5 1.3];
f = figure; f.Position = [        1000        1115         625         160*length(modelnames)];
iplot=0;
for imodel = 1:length(modelnames)
  quantile_leg = {};
  for istim = 1:2 % absent, present
    iplot=iplot+1;
    subplot(length(modelnames),2,iplot); hold on
    title(sprintf('%s, dic %d\n%s', modelnames{imodel}, model_dic(imodel), titnames{istim}))
    xlabel('Proportion of responses');
    ylabel('Reaction time (s)')
%     ylim(YLIM)
    % plot the observed data
    colors = [];
    for ibin = 1:nbins
      
      dat_x = squeeze(bindat_avg(imodel, istim, ibin,:,:,2 )); % RT for both conditions, correct and incorrect
      dat_y = squeeze(bindat_avg(imodel, istim, ibin,:,:,1 )); % RT for both conditions, correct and incorrect
      dat_x(:,2) = flipud(dat_x(:,2)); % to get the line straight through the points
      dat_y(:,2) = flipud(dat_y(:,2));
      
      p = plot(dat_x(:), dat_y(:), '-x');
      %     quantile_leg{ibin} = sprintf('q %1.2f', quantiles(ibin+1)/100-0.1);
      colors = [colors; p.Color];
      quantile_leg{ibin} = sprintf('q %g-%g', quantiles(ibin), quantiles(ibin+1) );
    end
    switch simdat_plottype
      case 'singlesims'
        for idata = 1:size(bindat_sim_avg,2)
          % plot the sim data
          for ibin = 1:nbins
            
            dat_x = squeeze(bindat_sim_avg(imodel,idata,istim, ibin,:,:,2 )); % RT for both conditions, correct and incorrect
            dat_y = squeeze(bindat_sim_avg(imodel,idata,istim, ibin,:,:,1 )); % RT for both conditions, correct and incorrect
            dat_x(:,2) = flipud(dat_x(:,2)); % to get the line straight through the points
            dat_y(:,2) = flipud(dat_y(:,2));
            
            plot(dat_x(:), dat_y(:), '.k');
            %       quantile_leg{ibin} = sprintf('q %1.2f', quantiles(ibin+1)/100-0.1);
          end
        end
      case 'aggregate'
        bindat_sim_var = squeeze(std(bindat_sim_avg,0,2)) * 4; % ./ sqrt(size(bindat_sim_avg,2)) ; % std over simulated datasets
        for ibin = 1:nbins
          
          dat_x = squeeze(bindat_sim_avg(imodel,idata,istim, ibin,:,:,2 )); % RT for both conditions, correct and incorrect
          dat_y = squeeze(bindat_sim_avg(imodel,idata,istim, ibin,:,:,1 )); % RT for both conditions, correct and incorrect
          dat_x(:,2) = flipud(dat_x(:,2)); % to get the line straight through the points
          dat_y(:,2) = flipud(dat_y(:,2));
          dat_x = dat_x(:);
          dat_y = dat_y(:);
          
          var_x = squeeze(bindat_sim_var(imodel,istim, ibin,:,:,2 )); % RT for both conditions, correct and incorrect
          var_y = squeeze(bindat_sim_var(imodel,istim, ibin,:,:,1 )); % RT for both conditions, correct and incorrect
          var_x(:,2) = flipud(var_x(:,2)); % to get the line straight through the points
          var_y(:,2) = flipud(var_y(:,2));
          var_x = var_x(:);
          var_y = var_y(:);
          
          yneg = - 0.5.*var_y;
          ypos = + 0.5.*var_y;
          xneg = - 0.5.*var_x;
          xpos = + 0.5.*var_x;
          switch plottype
            case 'errorbars'
              er = errorbar(dat_x,dat_y,yneg,ypos,xneg,xpos, '.');
              er.Marker = 'o'; %'none'
              er.MarkerSize = 2;
              er.MarkerFaceColor = 'auto';
              er.Color = colors(ibin,:);
              er.CapSize = 0;
            case 'ellipse'
              a=1; % horizontal radius
              b=var_y; % vertical radius
              x0=dat_x; % x0,y0 ellipse centre coordinates
              y0=dat_y;
              t=-pi:0.5:pi; %0.01
              x=x0+a*cos(t);
              y=y0+b*sin(t);
              plot(x,y)
          end
          
        end
    end
    
        
    %   if istim==2
    legend(quantile_leg, 'Location', 'EastOutside'); legend boxon
    %   end
    ax=gca;
    ax.FontSize = 8;
    %   line()
  end
end

% legend off
if SAV
  PREOUT = '/HDDM/123back_bias_novelvsfam/data/plots_quantile_prob';
  saveas(f, fullfile(PREOUT, sprintf('Quantprob_%dbins_%s.pdf', nbins, simdat_plottype )))
  saveas(f, fullfile(PREOUT, sprintf('Quantprob_%dbins_%s.png', nbins, simdat_plottype )))
end

