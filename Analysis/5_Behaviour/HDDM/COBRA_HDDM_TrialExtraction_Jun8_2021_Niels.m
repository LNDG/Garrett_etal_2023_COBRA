function HDDM_data = COBRA_HDDM_TrialExtraction_Jun8_2021_Niels()

invalids = 'keep'; % remove or keep invalid trials at block start

if strcmp(invalids, 'keep')
  disp 'Keeping so-called N invalid trials at block start'
  ntrials = [90 90 90];
else
  ntrials = [81 72 63];
end

cd '/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/Niels_edits';

block_onsets = [0 44 66 142 164 197 240 262 295; ...%1back
 11 33 88 109 131 186 229 284 306;  ... %2back
 22 55 77 120 153 175 208 251 273]; % 3back
conds = zeros(size(block_onsets));
conds(1,:) = 1;
conds(2,:) = 2;
conds(3,:) = 3;
block_order = [block_onsets(:) conds(:)];
[~,ind] = sort(block_order(:,1));
block_order_sorted = block_order(ind,:);
% figure; plot(block_order_sorted(:,2))
%TODO add colum with trial number
trialind = transpose(reshape(1:270, [], 27)); % dimord blocks_ntrls
block_order_sorted = [block_order_sorted trialind];
[~,ind] = sort(block_order_sorted(:,2));
block_order_sorted = block_order_sorted(ind,:); % trialinds sorted wrt nback, just like data

%load table data. Data were previously saved in .mat after loading COBRA_HDDM_data.xlsx
load('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/COBRA_HDDM_data_n162_June26_2018.mat');
%convert to cell for manipulation
data = table2cell(COBRAHDDMdata_n162);

% data = cell2table(transpose(data))
%HDDM_data = zeros(x,y);%need ID, condition, stimulus, acc, and RT as only column vectors. All must start count from 0.

HDDM_data = cell((length(data)-1)*(sum(ntrials)),5); % initialise data array

% subj idx
subj_idx = [0:length(data)-2]; %0 start for n=162 for this sample; ignore first column in 'data'.
subj_idx = repmat(subj_idx,[sum(ntrials),1]); %1-back = 81 trials, 2-back = 72 trials, 3-back = 63 trials.
subj_idx = reshape(subj_idx,[numel(subj_idx),1]);
subj_idx = num2cell(subj_idx);

HDDM_data(:,1)=subj_idx; % store subject_idx in first column of data array

%COBRA ID
COBRA_ID = data(1,2:end);%ignore variable name in first column in 'data'.
COBRA_ID = repmat(COBRA_ID,[sum(ntrials),1]); %1-back = 81 trials, 2-back = 72 trials, 3-back = 63 trials.
COBRA_ID = reshape(COBRA_ID,[numel(COBRA_ID),1]);

HDDM_data(:,2)=COBRA_ID; % store COBRA ID in second column of data array

%Stim
stim=cell(1,sum(ntrials));
% [stim{1:81}]=deal('1-back');
% [stim{82:153}]=deal('2-back');
% [stim{154:end}]=deal('3-back');
[stim{1:ntrials(1)}]=deal('1-back');
[stim{ntrials(1)+1:sum(ntrials(1:2))}]=deal('2-back');
[stim{sum(ntrials(1:2))+1:end}]=deal('3-back');
stim=repmat(stim',[(length(data)-1),1]);

HDDM_data(:,3)=stim; % store stimulus condition in third column of data array

%Acc, RT

%initialise data vectors

Acc_new=[];
RT_new=[];
resp_new=[];
trlorder_new=[];

RTinvalid=cell(1,3);
respinvalid=cell(1,3);
for i = 2:length(data) %skip first column
   
    % read in subject RT, Acc and response vector for each condition
    Acc = str2num(data{3,i});
    RT = str2num(data{4,i});
    resp = str2num(data{2,i});
    
    Acc_n1=Acc(1,:);
    Acc_n2=Acc(2,:);
    Acc_n3=Acc(3,:);
    
    resp_n1=resp(1,:);
    resp_n2=resp(2,:);
    resp_n3=resp(3,:);

    % 1back
    resp_n1 = reshape(resp_n1, [], 9); %dimord rpt_run
    Acc_n1 = reshape(Acc_n1, [], 9); %dimord rpt_run
    noresptoinval = squeeze(resp_n1(1, :) == 0);     
    Acc_n1(1, noresptoinval) = 1;
    resp_n1 = reshape(resp_n1, 1, []);
    Acc_n1 = reshape(Acc_n1, 1, []);

    % 2back
    resp_n2 = reshape(resp_n2, [], 9); %dimord rpt_run
    Acc_n2 = reshape(Acc_n2, [], 9); %dimord rpt_run
    noresptoinval = resp_n2 == 0;
    noresptoinval(3:end,:) = 0;
    Acc_n2(noresptoinval) = 1;
    resp_n2 = reshape(resp_n2, 1, []);
    Acc_n2 = reshape(Acc_n2, 1, []);

    % 3back
    resp_n3 = reshape(resp_n3, [], 9); %dimord rpt_run
    Acc_n3 = reshape(Acc_n3, [], 9); %dimord rpt_run
    noresptoinval = resp_n3 == 0;
    noresptoinval(4:end,:) = 0;
    Acc_n3(noresptoinval) = 1;
    resp_n3 = reshape(resp_n3, 1, []);
    Acc_n3 = reshape(Acc_n3, 1, []);

    RT_n1=RT(1,:);
    RT_n2=RT(2,:);
    RT_n3=RT(3,:);    
    
    trlorder_n1 = reshape(block_order_sorted(1:9, 3:end)', 1, []);
    trlorder_n2 = reshape(block_order_sorted(10:18, 3:end)', 1, []);
    trlorder_n3 = reshape(block_order_sorted(19:end, 3:end)', 1, []);
    
    % find and remove "invalid" trials for each n-back condition
    switch invalids % TODO fix this for trlorder_nX
      case 'remove'
        invalid_n1=1:length(Acc_n1);    % 1:90
        invalid_n1=find(mod(invalid_n1, 10)==1);
        Acc_n1(invalid_n1)=[];
        RTinvalid{1}(i,:) = RT_n1(invalid_n1);
        respinvalid{1}(i,:) = resp_n1(invalid_n1);
        RT_n1(invalid_n1)=[];
        resp_n1(invalid_n1)=[];
        
        invalid_n2=1:length(Acc_n2);
        invalid_n2=find(mod(invalid_n2, 10)==1 | mod(invalid_n2, 10)==2);
        RTinvalid{2}(i,:) = RT_n2(invalid_n2);
        respinvalid{2}(i,:) = resp_n2(invalid_n2);
        Acc_n2(invalid_n2)=[];
        RT_n2(invalid_n2)=[];
        resp_n2(invalid_n2)=[];
        
        invalid_n3=1:length(Acc_n3);
        invalid_n3=find(mod(invalid_n3, 10)==1 | mod(invalid_n3, 10)==2 | mod(invalid_n3, 10)==3);
        RTinvalid{3}(i,:) = RT_n3(invalid_n3);
        respinvalid{3}(i,:) = resp_n3(invalid_n3);
        Acc_n3(invalid_n3)=[];
        RT_n3(invalid_n3)=[];
        resp_n3(invalid_n3)=[];
    end
    
    Acc_new=[Acc_new Acc_n1 Acc_n2 Acc_n3]; % leave out 1-back for now
    RT_new=[RT_new RT_n1 RT_n2 RT_n3];
    resp_new=[resp_new resp_n1 resp_n2 resp_n3];
    trlorder_new = [trlorder_new trlorder_n1 trlorder_n2 trlorder_n3];
    
end

if strcmp(invalids, 'remove')
  f=figure; hold on
  for i=1:3
    %   plot(sum(~isnan(RTinvalid{i})))
    dat= sum(~isnan(RTinvalid{i}));
    plot(dat(1:i:end))
  end
  xlabel('block #')
  ylabel('N subjects that responded on first trial of block')
  ylim([0 163])
  legend({'1-back' '2-back' '3-back'}); legend boxoff; box on
  saveas(f, 'Nresponses_firsttrialofblock.png')
end
Acc_new = num2cell(Acc_new');
RT_new = num2cell(RT_new');
resp_new = num2cell(resp_new');
trlorder_new = num2cell(trlorder_new');
HDDM_data(:,4:7)=[RT_new Acc_new resp_new trlorder_new]; % store RT and Acc in fourth and fifth column of data array respectively

% Save data as csv file

HDDM_data = cell2table(HDDM_data);

HDDM_data.Properties.VariableNames = {'subj_idx','COBRA_ID', 'stim', 'rt','trial_accuracy', 'response', 'trialno'};

writetable(HDDM_data, sprintf('COBRA_HDDM_May26_2021_response-button_press_invalids%s.csv', invalids));
height(HDDM_data)

% %write header
% fid = fopen(['COBRA_HDDM_June25_2018.csv'], 'w');
% fprintf(fid, '%s, %s, %s, %s, %s\n', 'subj_idx','COBRA_ID', 'stim', 'rt','response');
% fclose(fid) ;
% 
% %write data
% dlmwrite(['COBRA_HDDM_June25_2018.csv'], HDDM_data, 'delimiter', ',' , '-append');


% exp_path = fullfile('/Users/kloosterman/Dropbox/PROJECTS/CriterionEEG/DDMexport');
% mkdir(exp_path)
% trl_outfile = sprintf('critEEG_data_binby%s_overlap%s.csv', binmethod, binoverlap);
% fid = fopen(fullfile(exp_path, trl_outfile), 'w') ;
% %     fprintf(fid, 'subj_idx,cond,stimulus,response,rt,alpha10bins,alpha5bins\n');
%     fprintf(fid, 'subj_idx,cond,stimulus,response,rt,alpha10bins\n');
%     dlmwrite(fullfile(exp_path, trl_outfile), outmat, '-append', 'precision', 10)
%     fclose(fid);