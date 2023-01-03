function [block, RunningList, LevelList, OnsetLists, OnsetList]  = dz_InterpreteEprimefile(file, TR, strOnsetTime, ProcNameOfFirstOnset, HappNameOfFirstOnset, StartOnset)

% [block, RunningList, LevelList, OnsetLists, OnsetList]  = dz_InterpreteEprimefile(file, TR, strOnsetTime, ProcNameOfFirstOnset, HappNameOfFirstOnset)

% parameter med undernamn som ska med, exvis .

% l?gg in koll om det finns en "onsetTime" som ?r l?gre ?n den som anges som starttid
if ~exist('ProcNameOfFirstOnset', 'var')
    ProcNameOfFirstOnset='';
end
if ~exist('HappNameOfFirstOnset', 'var')
    HappNameOfFirstOnset='';
end

if ~exist('StartOnset', 'var')
	StartOnset = 0;
end

DisplayWarnings = 0;
fid = fopen(file, 'r');
LineCounter = 0;
while 1==1
	sTemp = fgetl(fid);
	if sTemp==-1,   break;   end
	if isempty(sTemp),    break;   end
	if all(sTemp==0)
		continue
	end
	sTemp = strrep(sTemp, ' ', ''); sTemp = strrep(sTemp, char(9), ''); sTemp = strrep(sTemp, char(0), '');
	LineCounter = LineCounter+1;
	strLine{LineCounter} = sTemp;
end
fclose(fid);

bl = 0;
hc = 0;
FirstOnset = inf;
InBlock = 0;
for row=1:LineCounter
	str = strLine{row};
	%str = strrep(str, ' ', ''); str = strrep(str, char(9), ''); str = strrep(str, char(0), '');
	if strcmpi(str, '***LogFrameStart***')
		InBlock = 1;
		bl = bl+1;
		OnsetList(bl) = inf;
		if row>1
			tstr = strLine{row-1};
% 			tstr = strrep(tstr, ' ', '');	tstr = strrep(tstr, char(9), '');
			ind = strfind(tstr, 'Level:');
			if numel(ind)==1
				block(bl).level = str2double(tstr(ind+6:end)); % strtok(tstr, 'Level:');
				continue
			end
		end
	end
	if strcmpi(str, '***LogFrameEnd***')
		InBlock = 0;
		hc = 0;
		continue
	end
	if InBlock
		[f,s,v] = InterpreteLine(str);
		if isempty(s) && f(1)~='"' % main
			block(bl).MainBlockHapps.(f) = v;
% 			if strcmp(f, 'OnsetTime') %if onsettime
% 				OnsetTime = block(bl).MainBlockHapps.OnsetTime;
% 				OnsetList(bl) = min([OnsetList(bl) OnsetTime]);
% 				% if only procname specified
% 				if ~isempty(ProcNameOfFirstOnset) && isempty(HappNameOfFirstOnset)
% 					if strcmpi(block(bl).MainBlockHapps.Procedure, ProcNameOfFirstOnset)
% 						if ~isinf(FirstOnset)
% 							disp(sprintf('Warning, found more than one occurence of %s use the earliest', ProcNameOfFirstOnset));
% 						end
% 						if OnsetTime<FirstOnset
% 							FirstOnset = OnsetTime;
% 						end
% 					end
% 				elseif isempty(ProcNameOfFirstOnset) && isempty(HappNameOfFirstOnset)
% 					if OnsetTime<FirstOnset
% 						FirstOnset = OnsetTime;
% 					end
% 				end
% 			end
			% 		ind = strfind(str, 'Procedure:');
			% 		if numel(ind)==1
			% 			block(bl).procedure = str(ind+10:end);
			% 			continue
			% 		end
			% 		ind = strfind(str, 'Running:');
			% 		if numel(ind)==1
			% 			block(bl).running = str(ind+8:end);
			% 			continue
			% 		end
			% 		ind = strfind(str, 'Condition:');
			% 		if numel(ind)==1
			% 			block(bl).condition = str(ind+10:end);
			% 			continue
			% 		end
			% 		ind = strfind(str, 'Item:');
			% 		if numel(ind)==1
			% 			block(bl).item = str(ind+5:end);
			% 			continue
			% 		end
		else % subhapp
			if s(1)~='"' && f(1)~='"'
				if isfield(block(bl), 'SubBlockHapps') && isfield(block(bl).SubBlockHapps, f)
					if isfield(block(bl).SubBlockHapps.(f), s)
						disp('RRERERRROR');
						bl, f, s
						asfasfasfsa;
					end
				end
				block(bl).SubBlockHapps.(f).(s) = v;
				if strcmp(s, strOnsetTime) %if onsettime
					%OnsetTime = block(bl).SubBlockHapps.(f).OnsetTime;
					eval(sprintf('OnsetTime = block(bl).SubBlockHapps.(f).%s;', strOnsetTime));
					OnsetList(bl) = min([OnsetList(bl) OnsetTime]);
					% if procname specified and happname specified
					if isfield(block(bl).MainBlockHapps, 'Procedure') && ~isempty(ProcNameOfFirstOnset) && isempty(HappNameOfFirstOnset)
						if strcmpi(block(bl).MainBlockHapps.Procedure, ProcNameOfFirstOnset)
							if ~isinf(FirstOnset) && DisplayWarnings
								disp(sprintf('  Warning, found more than one occurence of %s use the earliest', ProcNameOfFirstOnset));
							end
							if OnsetTime<FirstOnset
								FirstOnset = OnsetTime;
							end
						end
					elseif isfield(block(bl).MainBlockHapps, 'Procedure') && ~isempty(ProcNameOfFirstOnset) && ~isempty(HappNameOfFirstOnset)
						if strcmpi(block(bl).MainBlockHapps.Procedure, ProcNameOfFirstOnset) && strcmpi(f, HappNameOfFirstOnset)
							if ~isinf(FirstOnset) && DisplayWarnings
								disp(sprintf('  Warning, found more than one occurence of %s - %s use the earliest', ProcNameOfFirstOnset, HappNameOfFirstOnset));
							end
							if OnsetTime<FirstOnset
								FirstOnset = OnsetTime;
							end
						end
					elseif isempty(ProcNameOfFirstOnset) && ~isempty(HappNameOfFirstOnset)
						if strcmpi(f, HappNameOfFirstOnset)
							if ~isinf(FirstOnset) && DisplayWarnings
								disp(sprintf('  Warning, found more than one occurence of %s use the earliest', HappNameOfFirstOnset));
							end
							if OnsetTime<FirstOnset
								FirstOnset = OnsetTime;
							end
						end
					elseif isempty(ProcNameOfFirstOnset) && isempty(HappNameOfFirstOnset)
						if OnsetTime<FirstOnset
							FirstOnset = OnsetTime;
						end
					end
				end
			end
		end
		% 		ind = strfind(str, 'OnsetTime:');
		% 		if numel(ind)==1
		% 			hc = hc+1;
		% 			block(bl).happ(hc).name = str(1:ind-2);
		% 			block(bl).happ(hc).OnsetTime = str2double(str(ind+10:end));
		% 			continue
		% 		end
	end
end
% for b=bl:-1:1
%     if isempty(block(b).happ)
%         block(b) = [];
%     end
% end
% bl = numel(block);
% for b=1:bl
% 	for h=1:numel(block(b).happ)
% 		OnsetList(b,h) = block(b).happ(h).OnsetTime;
%         if ~isempty(ProcNameOfFirstOnset) && strcmpi(block(b).procedure, ProcNameOfFirstOnset) && h==1
%             if ~isinf(FirstOnset)
%                 disp(sprintf('Warning, found more than one occurence of %s use the earliest', ProcNameOfFirstOnset));
%             end
%             if OnsetList(b,h)<FirstOnset
%                 FirstOnset = OnsetList(b,h);
%             end
%         elseif ~isempty(HappNameOfFirstOnset) && strcmpi(block(b).happ(h).name, HappNameOfFirstOnset)
%             if ~isinf(FirstOnset)
%                 disp(sprintf('Warning, found more than one occurence of %s use the earliest', HappNameOfFirstOnset));
%             end
%             if OnsetList(b,h)<FirstOnset
%                 FirstOnset = OnsetList(b,h);
%             end
%         elseif isempty(HappNameOfFirstOnset) && isempty(ProcNameOfFirstOnset)
%             if OnsetList(b,h)<FirstOnset
%                 FirstOnset = OnsetList(b,h);
%                 disp(sprintf('First onset (%f) found at %d %d (%s)', FirstOnset, b, h, block(b).happ(h).name));
%             end
%         end
% 	end
% end

if isinf(FirstOnset)
    disp(sprintf('ERROR, no first onset found for %s', file));
    RunningList = [];
    LevelList = [];
	 OnsetList = [];
	 OnsetLists = [];
    return
end
% block(1)
% block(1).happ(1)

FirstOnset = FirstOnset-StartOnset; % if start is not logged

NofBl = numel(block);
for bl=1:NofBl
	if isfield(block(bl).MainBlockHapps, 'Running')
		RunningList{bl} = block(bl).MainBlockHapps.Running;
	else
		RunningList{bl} = '';
	end
	fn = fieldnames(block(bl).SubBlockHapps);
	for h=1:numel(fn)
		% 		RunningList{bl} = [RunningList{bl} ' ' block(bl).SubBlockHapps.(fn{h}).name];
		if isfield(block(bl).SubBlockHapps.(fn{h}), strOnsetTime)
			eval(sprintf('block(bl).SubBlockHapps.(fn{h}).RelativeOnsetTime = (block(bl).SubBlockHapps.(fn{h}).%s-FirstOnset)/1000/TR;', strOnsetTime));
			eval(sprintf('block(bl).SubBlockHapps.(fn{h}).RelativeOnsetTimes = (block(bl).SubBlockHapps.(fn{h}).%s-FirstOnset)/1000;', strOnsetTime));
		end
	end
	LevelList(bl) = block(bl).level;
	if bl==1 || LevelList(bl-1)~=LevelList(bl)
		block(bl).NewLevel = 1;
	else
		block(bl).NewLevel = 0;
	end
end
OnsetList = (OnsetList-FirstOnset)/1000/TR;
OnsetLists = OnsetList.*TR;
end
% [OnsetList, order] = sort(OnsetList);
% block = block(order);
% RunningList = RunningList(order);
% LevelList = LevelList(order);
% order

function [f,s,v] = InterpreteLine(str)
[k,v] = strtok(str, ':');
v = v(2:end);
if isnan(str2double(v))
	v = dz_RemoveTrailingSpaces(dz_RemoveLeadingSpaces(v));
else
	v = str2double(v);
end
k = dz_RemoveTrailingSpaces(dz_RemoveLeadingSpaces(k));
if any(strfind(k, '.'))
	[f,r] = strtok(k, '.');
	s = r(2:end);
else
	f = k;
	s = '';
end
end

