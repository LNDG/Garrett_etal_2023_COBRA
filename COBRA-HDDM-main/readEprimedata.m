function T = readEprimedata()

PREIN = '/Users/kloosterman/Dropbox/PROJECTS/COBRA/hddm/123back_bias_novelvsfam/data/Eprime_behav_data';
cd(PREIN)

subjlist = dir('*.txt');
dropinvalids = 1; %first N trials per Nback

subjectpool = 'drop_lowdprime'; % see options below
drop_lowdprime = 1; %  compute d' of each subject and drop if 1back < 1
drop_lowdprime_and_gelman_rubin = 0;
drop_lowdprime_and_gelman_rubin2 = 0;

% N=156 list, hand-repaired 015 filename
switch subjectpool
  case 'N156'
    subjlist = ["001","003","006","007","008","009","010","013","014","015","016","017","018","019","021","022","024","025", ...
      "027","028","029","030","032","034","035","038","040","041","043","045","046","049","050","051","052","053","056","057", ...
      "058","059","060","061","063","064","065","066","067","068","069","071","072","073","075","079","080","081","082","084", ...
      "085","087","090","091","092","093","094","095","097","099","104","105","106","107","108","109","110","112","114", ...
      "116","117","118","119","120","121","122","123","126","127","130","131","133","134","135","136","137","138","139", ...
      "140","143","144","146","148","149","150","152","153","154","155","156","158","159","160","161","162","163","164", ...
      "165","168","169","170","172","173","174","176","177","178","180","181","183","184","185","186","188","190","191", ...
      "192","193","194","195","196","197","198","199","200","201","203","204","206","208","210","211","212","213","214", ...
      "216","217","219"];
    
  case 'drop_lowdprime'
    % N=152 list, 28, 91 137 and 198 dropped: drop if 1back d' < 1
    subjlist = ["001","003","006","007","008","009","010","013","014","015","016","017","018","019","021","022","024","025", ...
      "027","029","030","032","034","035","038","040","041","043","045","046","049","050","051","052","053","056","057", ...
      "058","059","060","061","063","064","065","066","067","068","069","071","072","073","075","079","080","081","082","084", ...
      "085","087","090","092","093","094","095","097","099","104","105","106","107","108","109","110","112","114", ...
      "116","117","118","119","120","121","122","123","126","127","130","131","133","134","135","136","138","139", ...
      "140","143","144","146","148","149","150","152","153","154","155","156","158","159","160","161","162","163","164", ...
      "165","168","169","170","172","173","174","176","177","178","180","181","183","184","185","186","188","190","191", ...
      "192","193","194","195","196","197","199","200","201","203","204","206","208","210","211","212","213","214", ...
      "216","217","219"];
    
    %     subjlist = ["028" "091" "137" "198"] % dropped ones
    
  case 'drop_lowdprime_and_gelman_rubin' % after running HDDM on droplowdprime data: COBRAids 41    82   162   181 are too high
    % N=148 list,
    subjlist = ["001","003","006","007","008","009","010","013","014","015","016","017","018","019","021","022","024","025", ...
      "027","029","030","032","034","035","038","040","043","045","046","049","050","051","052","053","056","057", ...
      "058","059","060","061","063","064","065","066","067","068","069","071","072","073","075","079","080","081","084", ...
      "085","087","090","092","093","094","095","097","099","104","105","106","107","108","109","110","112","114", ...
      "116","117","118","119","120","121","122","123","126","127","130","131","133","134","135","136","138","139", ...
      "140","143","144","146","148","149","150","152","153","154","155","156","158","159","160","161","163","164", ...
      "165","168","169","170","172","173","174","176","177","178","180","183","184","185","186","188","190","191", ...
      "192","193","194","195","196","197","199","200","201","203","204","206","208","210","211","212","213","214", ...
      "216","217","219"];
    
  case 'drop_lowdprime_and_gelman_rubin2' % 2 more subj > 1.1 after running N=148 data: COBRAids  158 176
    % N=146 list,
    subjlist = ["001","003","006","007","008","009","010","013","014","015","016","017","018","019","021","022","024","025", ...
      "027","029","030","032","034","035","038","040","043","045","046","049","050","051","052","053","056","057", ...
      "058","059","060","061","063","064","065","066","067","068","069","071","072","073","075","079","080","081","084", ...
      "085","087","090","092","093","094","095","097","099","104","105","106","107","108","109","110","112","114", ...
      "116","117","118","119","120","121","122","123","126","127","130","131","133","134","135","136","138","139", ...
      "140","143","144","146","148","149","150","152","153","154","155","156","159","160","161","163","164", ...
      "165","168","169","170","172","173","174","177","178","180","183","184","185","186","188","190","191", ...
      "192","193","194","195","196","197","199","200","201","203","204","206","208","210","211","212","213","214", ...
      "216","217","219"];
end

% [block, RunningList, LevelList, OnsetLists, OnsetList]  = dz_InterpreteEprimefile(file, TR, strOnsetTime, ProcNameOfFirstOnset, HappNameOfFirstOnset)

subj_ctr = 0;  trial_ctr = 1;
subj_idx=[];	COBRA_ID=[];	stim=[];	rt=[];	accuracy=[];	response=[];	trialno=[];	stimulus=[]; novelty=[]; early=[];late=[];
rhos=[];
nsub = length(subjlist);
dprime = NaN(nsub,2); % keep track of low dprime 1back
for isub = 1:nsub % 131 has only 27 blocks
  %   % [block, RunningList, LevelList, OnsetLists, OnsetList] = ...
  %   %   dz_InterpreteEprimefile(file, TR, strOnsetTime) % , ProcNameOfFirstOnset, HappNameOfFirstOnset
  %   block = dz_InterpreteEprimefile(subjlist(isub).name, 2, []); % , ProcNameOfFirstOnset, HappNameOfFirstOnset
  
  file = dir(sprintf('*-%s-*.txt', subjlist(isub)));
  block = dz_InterpreteEprimefile(file.name, 2, []); % , ProcNameOfFirstOnset, HappNameOfFirstOnset
  
  if length(block) < 28
    fprintf('%s has fewer than 28 blocks\n', file.name)
    %     continue
  end
  for iblock = 1:length(block)-1 % last block has session info only
    nback_cond = block(iblock).MainBlockHapps.tasktype;
    if nback_cond==0 % 1-back is tasktype zero...
      nback_cond = 1;
    end
    
    stims = NaN(10,1);
    familiar = NaN(10,1);
    for istim = 1:10 % get stims out to figure out which ones were targets
      stims(istim,1) = block(iblock).MainBlockHapps.(sprintf('Attribute%d',istim));
      % look for same stimulus in whole block
      familiar(istim,1) = ismember(stims(istim,1), stims(1:istim-1,1) );
      % look for same stimulus Nback trials back
      hist_inds = istim-nback_cond:istim-1;
      hist_inds = hist_inds(hist_inds>0);
      if isempty(hist_inds)
        familiar(istim,1) = 0;
      else
        familiar(istim,1) = ismember(stims(istim,1), stims(hist_inds, 1) );
      end
    end
    targets = NaN(10,1); % can be removed later if invalid first N trials should go
    temp = (stims(1+nback_cond:end) - stims(1:end-nback_cond)) == 0;
    targets(1+nback_cond:end) = temp;
    
    for itrial = 1:10
      % has behavior:
      %       block(1).SubBlockHapps.TextDisplay1
      trialfield = sprintf('TextDisplay%d%d', itrial+(nback_cond-1)*10);
      if ~isfield( block(iblock).SubBlockHapps, trialfield)
        warning('Trial not found')
        continue % to next trial
      end
      
      % turn into csv, cols:  % subj_idx	COBRA_ID	stim	rt
      % accuracy	response	trialno	stimulus novelty
      subj_idx(end+1,1) = subj_ctr;
      COBRA_ID(end+1,1) = block(end).MainBlockHapps.Subject;
      stim(end+1,1)     = nback_cond; % Condition!
      stimulus(end+1,1) = targets(itrial); % target present or absent
      rt(end+1,1)       = block(iblock).SubBlockHapps.(trialfield).RT/1000;
      
      % button pressed: 1=yes, 2=no
      RESP = block(iblock).SubBlockHapps.(trialfield).RESP;
      if ~isempty(RESP)
        if strcmp(subjlist(isub), '119') || strcmp(subjlist(isub), '136') % two subj with different RESP vals
          if RESP == 2 % seems to be yes response OR 3 is no, 2 is yes for 119 and 136?
            response(end+1,1) = 1;
          elseif RESP == 3 ||  RESP == 9  % 9 is also there (1 trial)
            response(end+1,1) = 0;
          end
        else
          if RESP == 1 % Yes response
            response(end+1,1) = 1;
          elseif RESP == 2 ||  RESP == 9 % "No" response
            response(end+1,1) = 0;
          end
        end
      else
        response(end+1,1) = NaN;
      end
      
      accuracy(end+1,1) = targets(itrial) == response(end); %0=notarget, 2 = no response. nan==nan is false
      % ACC field seems broken
      %       accuracy(end+1,1) = block(iblock).SubBlockHapps.(sprintf('TextDisplay%d',itrial+(nback_cond-1)*10)).ACC; % correct?
      trialno(end+1,1)  = itrial;
      novelty(end+1,1)  = ~familiar(itrial);
      %       % has stim info:
      %       block(1).MainBlockHapps
      trial_ctr = trial_ctr + 1;

      if ismember(itrial, 1:4)
        early(end+1,1)  = 1;
        late(end+1,1) = 0;
      elseif ismember(itrial, 5:8)
        early(end+1,1) = 1;
        late(end+1,1)  = 1;      
      elseif ismember(itrial, 9:10)
        early(end+1,1) = 0;
        late(end+1,1)  = 1;
      end
            
      
    end
  end
  %   %  compute dprime 1-back, keep track of low subjects NO done in plotSDT_DDMpars
  %   subjdat = [stimulus(subj_idx == subj_ctr & stim == 1) response(subj_idx == subj_ctr & stim == 1)]; % stim=1: 1back
  %   subjdat = subjdat(all(~isnan(subjdat),2),:); % col1 stimulus, col2 response
  %   H = sum(subjdat(:,1) == 1 & subjdat(:,2) == 1) / ...
  %     sum(subjdat(:,1) == 1);
  %   if H == 1
  %     H = 0.99;
  %   end
  %   FA = sum(subjdat(:,1) == 0 & subjdat(:,2) == 1) / ...
  %     sum(subjdat(:,1) == 0);
  %   if FA == 0
  %     FA = 0.01;
  %   end
  %
  %   dprime(isub,1) = subj_ctr; %keep track of subj_idx to drop subjects in table below
  %   dprime(isub,2) = norminv(H) - norminv(FA);
  
  subj_ctr = subj_ctr+1;
end

% % % is target presence correlated with novelty? not good.
% % % seems taking the whole block for familiarity does not work r= -0.9816
% % % what about only looking Nback trials back?? Nope, only 2 lures
% corrdat = [stimulus novelty];
% corrdat = corrdat(~isnan(corrdat(:,1)),:);
% corr(corrdat(:,1), corrdat(:,2))
% figure; plot(corrdat(:,1), corrdat(:,2))

T = table(subj_idx,	COBRA_ID,	stim,	rt,	accuracy,	response,	trialno, ...
  stimulus, novelty, early, late);
if dropinvalids
  disp('Dropping invalids')
  T = T(~isnan(T.stimulus),:);
end

% if drop_lowdprime
%   disp 'Dropping low dprime subjects'
%   subj_idx_lowdprime = dprime(dprime(:,2) < 1,1);
%   disp 'subject_idx'
%   T(ismember(T.subj_idx, subj_idx_lowdprime),:) = [];
% end

disp('Dropping missed responses')
T = T(~isnan(T.response),:);

fprintf('%d subjects processed\n', length(unique(T.subj_idx)))
outfile = sprintf('COBRA_DDMdata_%s.csv', subjectpool);
writetable(T, fullfile(fileparts(PREIN), outfile))
fprintf('%s written to\n%s', outfile, fileparts(PREIN))
