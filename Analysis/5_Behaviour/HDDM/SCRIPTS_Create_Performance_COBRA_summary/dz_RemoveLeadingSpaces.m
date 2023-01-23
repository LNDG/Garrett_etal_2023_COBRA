function out = dz_RemoveLeadingSpaces(in)

AreNotSpaces = find(in~=32);
if length(AreNotSpaces)>0
    out = in(AreNotSpaces(1):end);
else
    out = [];
end
