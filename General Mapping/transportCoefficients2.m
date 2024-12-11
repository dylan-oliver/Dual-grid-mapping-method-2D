function coef = transportCoefficients2(coefType,circles,radii,x,y)
% The domain is partitioned into strips of one material type or another.
% The material type is thus determined from the corresponding strip.
check = checkCircles(circles,radii,x,y);
if check
    % If the current point is inside one of the circular regions, assign
    % the following coefficient value:
    switch coefType
        case 1
            coef = 45 + 0.*x; % R(x)
        case 2
            coef = [0.75,0;0,0.005]; % D(x)
        case 3
            coef = [0.95;0]; % v(x)
        case 4
            coef = 0.003 + 0.*x; % mu(x)
    end
else
    % Otherwise, the current point is outside the circular regions. Assign
    % the following coefficient value:
    switch coefType
        case 1
            coef = 20 + 0.*x; % R(x)
        case 2
            coef = [4.5,0;0,0.015]; % D(x)
        case 3
            coef = [1.25;0]; % v(x)
        case 4
            coef = 0.007 + 0.*x; % mu(x)
    end
end
end
