function check = checkStrips(lines,mask,x,y)
%CHECKSTRIPS - Determines which material region an input point is inside.
%
% Syntax
%   check = CHECKSTRIPS(lines,mask,x,y)
%
% Input Arguments
%   lines - The x coordinates of vertical line interfaces between layers in
%           domain. Vector.
%   mask - A list of indicators corresponding to material type for each
%          subdomain strip. Vector. Has length (no. subdomain strips).
%
% Output Arguments
%   check - Indicator specifying material type. Logical. True corresponds
%           to material type 2, false corresponds to material type 1.

check = x - lines >= 0;
idx = find(check,1,'last');
if idx < length(lines)
    check = mask(idx);
else
    check = mask(end);
end
end