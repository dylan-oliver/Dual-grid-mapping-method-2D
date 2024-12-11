function coef = transportCoefficients(coefType,lines,mask,x,y)
%TRANSPORTCOEFFICIENTS - Returns either R(x), D(x), v(x), or mu(x),
% corresponding to the governing ADR equation (1).
%
% Syntax
%   coef = TRANSPORTCOEFFICIENTS(coefType,lines,mask,x,y)
%
% Input Arguments
%   coefType - Desired transport coefficient. Scalar; R(x): 1, D(x): 2,
%              v(x): 3, mu(x): 4.
%   lines - The x coordinates of vertical line interfaces between layers in
%           domain. Vector.
%   mask - Material type indicator for subdomain strips.
%          Logical. True if strip contains material 2, false if strip
%          contains material 1.
%   x - Coordinate. Scalar or array. Used to evaluate indicated transport
%       coefficient.
%   y - Coordinate. Scalar or array. Used to evaluate indicated transport
%       coefficient.

% The domain is partitioned into strips of one material type or another.
% The material type is thus determined from the corresponding strip.
check = checkStrips(lines,mask,x,y);
if check
    % If the current point is in the second material, assign the following
    % coefficient value:
    switch coefType
        case 1
            coef = 45 + 0.*x; % R(x)
        case 2
            coef = [1.25,0;0,0.005]; % D(x)
        case 3
            coef = [1.75;0]; % v(x)
        case 4
            coef = 0.003 + 0.*x; % mu(x)
    end
else
    % Otherwise, the current point is in the first material. Assign the
    % following coefficient value:
    switch coefType
        case 1
            coef = 20 + 0.*x; % R(x)
        case 2
            coef = [8.5,0;0,0.075]; % D(x)
        case 3
            coef = [6.75;0]; % v(x)
        case 4
            coef = 0.007 + 0.*x; % mu(x)
    end
end
end
