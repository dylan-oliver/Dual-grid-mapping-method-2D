function [c,C] = DM(grid,parameters)
%DM - Basic implementation of the Dual-grid Mapping method.
%
% Syntax
%   [c,C] = DM(grid,parameters)
%
% Input Arguments
%   grid - 2D FVM grid object. Custom structure (see modGrid.m).
%   parameters - FVM parameters. Custom structure (see run.m).
%
% Output Arguments
%   c - Approximate fine-grid solution constructed using the DGMM. Matrix.
%       Has format [c^(0),c^(1),c^(2),...,c^(K)], where c^(k) is an Nx1
%       vector containing approximate solution values on the fine grid at
%       time step k.
%   C - Approximate coarse-grid solution obtained using the DGMM. Matrix.
%       Has format [C^(0),C^(1),C^(2),...,C^(K)], where C^(K) is an Mx1
%       vector containing approximate solution values on the coarse grid at
%       time step k.

nodes = grid.nodes;
coarseNodes = grid.nodes(grid.coarseNodes,:);
numNodes = size(nodes,1);
numCoarseNodes = size(coarseNodes,1);
numStrips = grid.numStrips;

rows = grid.doubleUpRows;
cols = grid.doubleUpCols;

T = parameters.T;
K = parameters.K;
tau = T/K;

% Find coefficient matrix of full FVM discretisation (used to determine
% coarse-grid coefficient matrix).
[AFull,bFull] = genAb(grid,parameters);
IFull = grid.I;
itMatFull = IFull - tau*AFull;

itMatStrip = cell(numStrips,1);

% Estimate number of entries in the mapping matrix G.
nz = 0;
for p = 1:numStrips
    nz = nz + length(rows{p}) * length(cols{p});
end

% Pre-allocate and define the mapping matrix G using Equation (21).
G = spalloc(numNodes,numCoarseNodes,nz);

for p = 1:numStrips
    ATmp = genAb(grid.subgrid{p},parameters);
    itMatStrip{p}.itMat = grid.subgrid{p}.I - tau*ATmp;

    G(rows{p},cols{p}) = itMatStrip{p}.itMat \ grid.subgrid{p}.Hp;
end

% Pre-allocate coarse-grid coefficient matrix from Equation (15)
itMatCoarse = G' * itMatFull * G;

c = zeros(numNodes,K+1); c(:,1) = parameters.f(nodes(:,1),nodes(:,2));

C = zeros(numCoarseNodes,K+1); C(:,1) = parameters.f(coarseNodes(:,1),coarseNodes(:,2));

phim = zeros(numNodes,1);

% Time stepping
for k = 1:K

    t = k*tau;

    % Set the right-hand side vectors: (c^(k) + tau*b^(k+1))
    [cTmp,bTmp] = setRHS(c(:,k),bFull,t,grid,parameters);
    rhs = cTmp + tau*bTmp;
    rpk = rhs;
    rpk(grid.dirichletDM) = 0;

    % Find phi_p^(k+1) vector from Equation (22).
    for p = 1:numStrips
        phim(rows{p}) = itMatStrip{p}.itMat \ rpk(rows{p});
    end

    % Modify RHS to match RHS of Equation (15).
    rhs = rhs - itMatFull*phim;
    rhs = G' * rhs;

    % Find coarse-grid solution.
    C(:,k+1) = itMatCoarse \ rhs;

    % Reconstruct fine-grid solution.
    c(:,k+1) = G * C(:,k+1) + phim;

end

end