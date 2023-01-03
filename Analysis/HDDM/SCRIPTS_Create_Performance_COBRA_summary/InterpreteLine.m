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
