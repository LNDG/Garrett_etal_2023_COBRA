function out = dz_RemoveTrailingSpaces(in)

AreNotSpaces = find(in~=32);
if length(AreNotSpaces)>0
    out = in(1:AreNotSpaces(end));
else
    out = [];
end
