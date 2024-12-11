function [ck,b] = setRHS(ck,b,t,grid,parameters)
%SETRHS - Defines the right-hand side vectors c^(k) and b^(k+1) in
% equations (12) and (15).
%
% Syntax
%   [ck,b] = SETRHS(ck,b,t,grid,parameters)
%
% Input Arguments
%   ck - Approximate solution at time step k. Vector.
%   b - Coefficients of RHS vector (see Sections 2 and 3 for example).
%       Vector.
%   t - Current time corresponding to time step (t = k*tau). Scalar.
%   grid - 2D FVM grid object. Custom structure (see modGrid.m).
%   parameters - FVM parameters. Custom structure (see run.m).

% Parameters used at the boundary of the current domain.
bcond = parameters.bcond;

lines    = grid.lines;
numLines = size(lines,1);

V = grid.V;
x = grid.nodes(:,1);
y = grid.nodes(:,2);
R = grid.R;

xBnd = grid.xBnd;
yBnd = grid.yBnd;
DBnd = grid.DBnd;
LBnd = grid.LBnd;
nBnd = grid.nBnd;

dirichlet = grid.dirichlet;

flag  = grid.flag;
count = grid.count;

% If a Dirichlet condition is enforced, set the value exactly on line 48.
ck(dirichlet) = 0;

for E = 1:numLines
    line = lines(E,:);

    switch bcond(line(3))
        case 1 % Dirichlet condition
            for sig = 1:2
                if flag(E,sig)
                    gj = parameters.g{line(3)};
                    ck(line(sig)) = ck(line(sig)) + gj(x(line(sig)),y(line(sig)),t);
                end
            end
        case 2 % Neumann/outward-gradient condition
            gj = parameters.g{line(3)};
            for sig = 1:2
                Dj = DBnd(:,:,sig,E);
                Lj = LBnd(sig,E);
                nj = nBnd(:,E);
                switch line(3)
                    case 1
                        b(line(sig)) = b(line(sig)) + ( Dj(:,2)' * nj ) * Lj * gj(xBnd(sig,E),yBnd(sig,E),t);
                    case 2
                        b(line(sig)) = b(line(sig)) + ( Dj(:,1)' * nj ) * Lj * gj(xBnd(sig,E),yBnd(sig,E),t);
                    case 3
                        b(line(sig)) = b(line(sig)) + ( Dj(:,2)' * nj ) * Lj * gj(xBnd(sig,E),yBnd(sig,E),t);
                    case 4
                        b(line(sig)) = b(line(sig)) + ( Dj(:,1)' * nj ) * Lj * gj(xBnd(sig,E),yBnd(sig,E),t);
                end
            end
        case 3 % Flux condition
            gj = parameters.g{line(3)};
            for sig = 1:2
                Lj = LBnd(sig,E);
                b(line(sig)) = b(line(sig)) + gj(xBnd(sig,E),yBnd(sig,E),t) * Lj;
            end
    end
end

% If two Dirichlet conditions meet at a corner, the average value of both
% sides is set at that corner.
ck = ck ./ count;

% If a delta function is used to create a point source, the volume of the
% corresponding element is already accounted for.
switch isempty(parameters.points)
    case true
        b = b ./ V + parameters.S(x,y,t) ./ R; % Delta function in S, do not divide by V.
    case false
        b = (b + parameters.S(x,y,t) ./ R) ./ V; % No delta function in S, divide by V.
end

% Dirichlet conditions have already been set exactly in ck.
b(dirichlet) = 0;

end