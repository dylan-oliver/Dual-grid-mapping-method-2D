function [c,C] = DM2(grid,parameters)

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

[AFull,bFull] = genAb(grid,parameters);
IFull = grid.I;
itMatFull = IFull - tau*AFull;

itMatBlock = cell(numStrips,1);

nz = 0;
for i = 1:numStrips
    nz = nz + length(rows{i}) * length(cols{i});
end

G = spalloc(numNodes,numCoarseNodes,nz);

for i = 1:numStrips
    ATmp = genAbSubgrid(grid.subgrid{i});
    itMatBlock{i}.itMat = grid.subgrid{i}.I - tau*ATmp;

    G(rows{i},cols{i}) = itMatBlock{i}.itMat \ grid.subgrid{i}.map;
end

itMatCoarse = G' * itMatFull * G;

c = zeros(numNodes,K+1); c(:,1) = parameters.f(nodes(:,1),nodes(:,2));

C = zeros(numCoarseNodes,K+1); C(:,1) = parameters.f(coarseNodes(:,1),coarseNodes(:,2));

phim = zeros(numNodes,1);

for k = 1:K

    t = k*tau;

    [cTmp,bTmp] = setRHS(c(:,k),bFull,t,grid,parameters);
    rhs = cTmp + tau*bTmp;
    um = rhs;
    um(grid.dirichletDM) = 0;

    for i = 1:numStrips
        phim(rows{i}) = itMatBlock{i}.itMat \ um(rows{i});
    end

    rhs = rhs - itMatFull*phim;
    rhs = G' * rhs;

    C(:,k+1) = itMatCoarse \ rhs;

    c(:,k+1) = G * C(:,k+1) + phim;

end

end