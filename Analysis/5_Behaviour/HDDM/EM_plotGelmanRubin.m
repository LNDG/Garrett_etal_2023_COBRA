%% 1st HDDM, 4 low-dprime subjects removed
rub = readtable('/HDDM/123back_bias_novelvsfam/data/gelman_rubin_vals.csv');

paramsoi = {'a(1)' 'v(1)' 't(1)' 'z(1)' 'dc(1)' 'a(2)' 'v(2)' 't(2)' 'z(2)' 'dc(2)' 'a(3)' 'v(3)' 't(3)' 'z(3)' 'dc(3)'  }
all(rub.Var2(ismember(rub.Var1, paramsoi),:) < 1.1)

vals = rub.Var2(2:end,:);
close all
f=figure;
subplot(2,1,1)
histogram(vals)
title('gelman rubin vals')
subplot(2,1,2)
histogram(vals)
ylim([0 10])
title('gelman rubin vals ZOOMED')
saveas(f,'GelmanRubin_hist.png')

abovethreshold = rub(rub.Var2 > 1.1,:)
badsubj = [27 56 112 126] % subj_idx, run after removing 4 subj with d' < 1 at 1back 

% find out COBRAIDS of the subj_idx with too high G-R
COBRA_DDMdata_lowdprimedropped = readtable('/HDDM/123back_bias_novelvsfam/data/COBRA_DDMdata_lowdprimedropped.csv');

badsubj_COBRAIDs=[];
for ib = 1:length(badsubj)
  ind = find(COBRA_DDMdata_lowdprimedropped.subj_idx == badsubj(ib), 1, 'first');
  badsubj_COBRAIDs = [badsubj_COBRAIDs; COBRA_DDMdata_lowdprimedropped.COBRA_ID(ind)];
end
badsubj_COBRAIDs

%% 2nd HDDM, 4 dprime and 4 G-R subjects removed

rub = readtable('/HDDM/123back_bias_novelvsfam/data/gelman_rubin_vals_dprimedropped_R-Gdropped.csv');

vals = rub.Var2(2:end,:);
close all
f=figure;
subplot(2,1,1)
histogram(vals)
title('gelman rubin vals')
subplot(2,1,2)
histogram(vals)
ylim([0 10])
title('gelman rubin vals ZOOMED')
saveas(f,'GelmanRubin_hist2.png')

abovethreshold = rub(rub.Var2 > 1.1,:)
badsubj = [108 122] % subj_idx, run after removing 4 subj with d' < 1 at 1back 

% find out COBRAIDS of the subj_idx with too high G-R
COBRA_DDMdata_lowdprimedropped = ...
  readtable('/HDDM/123back_bias_novelvsfam/data/COBRA_DDMdata_lowdprimedropped_R-Gdropped.csv');

badsubj_COBRAIDs=[];
for ib = 1:length(badsubj)
  ind = find(COBRA_DDMdata_lowdprimedropped.subj_idx == badsubj(ib), 1, 'first');
  badsubj_COBRAIDs = [badsubj_COBRAIDs; COBRA_DDMdata_lowdprimedropped.COBRA_ID(ind)];
end
badsubj_COBRAIDs

%% 3rd HDDM, 4 dprime, 4 G-R subjects + 2 more G-R subj removed

rub = readtable('/HDDM/123back_bias_novelvsfam/data/gelman_rubin_vals_dprimedropped_R-Gdropped2.csv');

paramsoi = {'a(1)' 'v(1)' 't(1)' 'z(1)' 'dc(1)' 'a(2)' 'v(2)' 't(2)' 'z(2)' 'dc(2)' 'a(3)' 'v(3)' 't(3)' 'z(3)' 'dc(3)'  }
all(rub.Var2(ismember(rub.Var1, paramsoi),:) < 1.1)

vals = rub.Var2(2:end,:);

close all
f=figure;
subplot(2,1,1)
histogram(vals)
title('gelman rubin vals')
subplot(2,1,2)
histogram(vals)
ylim([0 10])
title('gelman rubin vals ZOOMED')
saveas(f,'GelmanRubin_hist2.png')

abovethreshold = rub(rub.Var2 > 1.1,:)
badsubj =  % subj_idx, 1 subj @ 1.1. yay

% find out COBRAIDS of the subj_idx with too high G-R
COBRA_DDMdata_lowdprimedropped = ...
  readtable('/HDDM/123back_bias_novelvsfam/data/COBRA_DDMdata_drop_lowdprime_and_gelman_rubin2.csv');

badsubj_COBRAIDs=[];
for ib = 1:length(badsubj)
  ind = find(COBRA_DDMdata_lowdprimedropped.subj_idx == badsubj(ib), 1, 'first');
  badsubj_COBRAIDs = [badsubj_COBRAIDs; COBRA_DDMdata_lowdprimedropped.COBRA_ID(ind)];
end
badsubj_COBRAIDs

%% HDDM N152, 15 chains

rub = readtable('/HDDM/123back_bias_novelvsfam/data/gelman_rubin_vals_drop_lowdprime.csv');

paramsoi = {'a(1)' 'v(1)' 't(1)' 'z(1)' 'dc(1)' 'a(2)' 'v(2)' 't(2)' 'z(2)' 'dc(2)' 'a(3)' 'v(3)' 't(3)' 'z(3)' 'dc(3)'};
rub(ismember(rub.Var1, paramsoi),:) 
all(rub.Var2(ismember(rub.Var1, paramsoi),:) < 1.1)

vals = rub.Var2(2:end,:);

close all
f=figure;
subplot(2,1,1)
histogram(vals)
title('gelman rubin vals')
subplot(2,1,2)
histogram(vals)
ylim([0 10])
title('gelman rubin vals ZOOMED')
saveas(f,'GelmanRubin_hist2.png')

abovethreshold = rub(rub.Var2 > 1.1,:)
badsubj = [26 55 105 109 123] % subj_idx, 1 subj @ 1.1. yay

% find out COBRAIDS of the subj_idx with too high G-R
COBRA_DDMdata_lowdprimedropped = ...
  readtable('/HDDM/123back_bias_novelvsfam/data/COBRA_DDMdata_drop_lowdprime.csv');

badsubj_COBRAIDs=[];
for ib = 1:length(badsubj)
  ind = find(COBRA_DDMdata_lowdprimedropped.subj_idx == badsubj(ib), 1, 'first');
  badsubj_COBRAIDs = [badsubj_COBRAIDs; COBRA_DDMdata_lowdprimedropped.COBRA_ID(ind)];
end
badsubj_COBRAIDs




