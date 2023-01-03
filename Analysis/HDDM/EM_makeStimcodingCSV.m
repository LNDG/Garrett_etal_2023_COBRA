function EM_makeStimcodingCSV()
csv = readtable('/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias/COBRA_HDDM_May26_2021_response-button_press_incsubj.csv');
% go back to response indicating actual button
csv.Properties.VariableNames = {'subj_idx' 'COBRA_ID' 'stim' 'rt' 'accuracy', 'response'};

disp 'remove NaN trials'
csv = rmmissing(csv);
unique(csv.response)
csv(13490,:) = []; % weird: one response was -7
unique(csv.response)

csv(1:10,:)
csv.stimulus = csv.response;
csv.stimulus(csv.accuracy == false) = ~csv.stimulus(csv.accuracy == false); % swap stim for incorrects:  

writetable(csv, 'COBRA_HDDM_May26_2021_response-button_press_incsubj_stimcoding.csv');
disp 'done'