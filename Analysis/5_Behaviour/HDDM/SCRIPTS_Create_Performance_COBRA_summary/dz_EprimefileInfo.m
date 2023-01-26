function experiment = dz_EprimefileInfo(file, WarnBadSubjectName)
% experiment = dz_EprimefileInfo(file)

if ~exist('WarnBadSubjectName', 'var')
	WarnBadSubjectName = 1;
end
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
	sTemp(sTemp>250) = '';
	if LineCounter==0
		if ~strcmpi(sTemp, '***HeaderStart***')
			experiment = [];
			fclose(fid);
			return
		end
	end
	LineCounter = LineCounter+1;
	strLine{LineCounter} = sTemp;
	if strcmp(sTemp, '***HeaderEnd***')
		break
	end
end
fclose(fid);

if LineCounter < 3
	experiment = [];
end
	
for row=1:LineCounter
	str = strLine{row};
	s = 'Experiment:'; nof = numel(s);
	if strncmpi(str, s, nof)
		experiment.name = str((nof+1):end);
		continue
	end
	s = 'SessionDate:'; nof = numel(s);
	if strncmpi(str, s, nof)
		experiment.date = datestr(datevec(str((nof+1):end)), 'yyyy-mm-dd');
		continue
	end
	s = 'SessionTime:'; nof = numel(s);
	if strncmpi(str, s, nof)
		experiment.time = str((nof+1):end);
		continue
	end
	s = 'Subject:'; nof = numel(s);
	if strncmpi(str, s, nof)
		experiment.subject = str((nof+1):end);
		if WarnBadSubjectName && isempty(strfind(file, experiment.subject))
			disp('************* ERROR in dz_EprimefileInfo ***********');
			disp(sprintf('Filename, %s', file));
			disp(sprintf('mismatch with subject name, %s', experiment.subject));
			disp('************* ERROR ********************************');
		end
		continue
	end
	s = 'Session:'; nof = numel(s);
	if strncmpi(str, s, nof)
		experiment.session = str2double(str((nof+1):end));
		continue
	end
end
