function [A,b] = genAb(grid,parameters)
%GENAB - Creates coefficient matrix A and coefficients of right-hand side
% vector b^(k+1) (see Equations (10)-(12) and (15)).
%
% Syntax
%   [A,b] = GENAB(grid,parameters)
%
% Input Arguments
%   grid - 2D FVM grid object. Custom structure (see modGrid.m).
%   parameters - FVM parameters. Custom structure (see run.m).
%
% Output Arguments
%   A - Coefficient matrix on LHS from FVM discretisation. Matrix. See
%       Equations (10)-(12) and (15).
%   b - Coefficient vector on RHS from FVM discretisation. Vector. See
%       Equations (10)-(12) and (15).

elmnts = grid.elmnts;
lines  = grid.lines;

numNodes  = size(grid.nodes,1);
numElmnts = size(elmnts,1);
numLines  = size(lines,1);

V  = grid.V;
L  = grid.L;
n  = grid.n;
N  = grid.N;
Nx = grid.Nx;
Ny = grid.Ny;
R  = grid.R;
D  = grid.D;
v  = grid.v;
mu = grid.mu;

DBnd = grid.DBnd;
vBnd = grid.vBnd;
LBnd = grid.LBnd;
nBnd = grid.nBnd;
NBnd = grid.NBnd;

dirichlet = grid.dirichlet;

bcond = parameters.bcond;

% Pre-allocate coefficient matrix in row, column, and corresponding value
% format to allow sparse construction.
row = zeros(1,2*9*numElmnts); col = row; val = row;

for E = 1:numElmnts

    % Iterating over the triangular grid elements, take discretisation
    % coefficient contributions from the boundaries of the control volumes
    % corresponding to the current element.
    elmnt = elmnts(E,1:3);

    for sig = 1:3

        switch sig
            case 1
                nbr = 2;
            case 2
                nbr = 3;
            case 3
                nbr = 1;
        end

        % Discretisation coefficients are determined from the linear
        % interpolating polynomial in the current grid element.
        Nj = N(:,sig,E);
        Nxj = Nx(:,E);
        Nyj = Ny(:,E);

        Dj = D(:,:,sig,E);
        vj = v(:,sig,E);
        Lj = L(sig,E);
        nj = n(:,sig,E);

        qn1 = ( Dj * [Nxj(1);Nyj(1)] - vj * Nj(1) )' * nj * Lj;
        qn2 = ( Dj * [Nxj(2);Nyj(2)] - vj * Nj(2) )' * nj * Lj;
        qn3 = ( Dj * [Nxj(3);Nyj(3)] - vj * Nj(3) )' * nj * Lj;

        inc = 9*(E-1) + 3*(sig-1) + 1;
        row(inc) = elmnt(sig); row(inc+1) = elmnt(sig); row(inc+2) = elmnt(sig);
        col(inc) = elmnt(1);   col(inc+1) = elmnt(2);   col(inc+2) = elmnt(3);
        val(inc) = qn1;        val(inc+1) = qn2;        val(inc+2) = qn3;

        inc = 9*numElmnts + inc;
        row(inc) = elmnt(nbr); row(inc+1) = elmnt(nbr); row(inc+2) = elmnt(nbr);
        col(inc) = elmnt(1);   col(inc+1) = elmnt(2);   col(inc+2) = elmnt(3);
        val(inc) = -qn1;       val(inc+1) = -qn2;       val(inc+2) = -qn3;

    end

end

% Perform same process as above on the boundary of the domain.
for E = 1:numLines
    line = lines(E,:);

    switch bcond(line(3))
        case 2
            elmnt = elmnts(line(4),1:3);
            for sig = 1:2
                pnt = line(4+sig);

                Nj = NBnd(:,sig,E);
                Nxj = Nx(:,line(4));
                Nyj = Ny(:,line(4));

                Dj = DBnd(:,:,sig,E);
                vj = vBnd(:,sig,E);
                Lj = LBnd(sig,E);
                nj = nBnd(:,E);

                switch line(3)
                    case 1
                        qn1 = ( Dj * [Nxj(1);0] - vj * Nj(1) )' * nj * Lj;
                        qn2 = ( Dj * [Nxj(2);0] - vj * Nj(2) )' * nj * Lj;
                        qn3 = ( Dj * [Nxj(3);0] - vj * Nj(3) )' * nj * Lj;
                    case 2
                        qn1 = ( Dj * [0;Nyj(1)] - vj * Nj(1) )' * nj * Lj;
                        qn2 = ( Dj * [0;Nyj(2)] - vj * Nj(2) )' * nj * Lj;
                        qn3 = ( Dj * [0;Nyj(3)] - vj * Nj(3) )' * nj * Lj;
                    case 3
                        qn1 = ( Dj * [Nxj(1);0] - vj * Nj(1) )' * nj * Lj;
                        qn2 = ( Dj * [Nxj(2);0] - vj * Nj(2) )' * nj * Lj;
                        qn3 = ( Dj * [Nxj(3);0] - vj * Nj(3) )' * nj * Lj;
                    case 4
                        qn1 = ( Dj * [0;Nyj(1)] - vj * Nj(1) )' * nj * Lj;
                        qn2 = ( Dj * [0;Nyj(2)] - vj * Nj(2) )' * nj * Lj;
                        qn3 = ( Dj * [0;Nyj(3)] - vj * Nj(3) )' * nj * Lj;
                end

                row(end+1) = elmnt(pnt); row(end+1) = elmnt(pnt); row(end+1) = elmnt(pnt); 
                col(end+1) = elmnt(1);   col(end+1) = elmnt(2);   col(end+1) = elmnt(3); 
                val(end+1) = qn1;        val(end+1) = qn2;        val(end+1) = qn3;
            end
    end
end

% Create sparse arrays from row, column, value triplets.
A = sparse(row,col,val);
A = A ./ (R .* V);
A(1:numNodes+1:numNodes*numNodes) = A(1:numNodes+1:numNodes*numNodes) - mu' ./ R';
A(dirichlet,:) = 0;

b = sparse(numNodes,1,0);

end
