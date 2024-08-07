function [sols_c,sols_C] = DM(grid,parameters)

nodes = grid.nodes;
coarseNodes = grid.nodes(grid.coarseNodes,:);
numNodes = size(nodes,1);
numCoarseNodes = size(coarseNodes,1);
numStrips = grid.numStrips;

rows = grid.doubleUpRows;
cols = grid.doubleUpCols;

store = parameters.store;

T = parameters.T;
K = parameters.K;
tau = T/K;

[AFull,bFull] = genAb(grid,parameters);
IFull = grid.I;
itMatFull = IFull - tau*AFull;

itMatStrip = cell(numStrips,1);
G = zeros(numNodes,numCoarseNodes);

%options.type = 'crout';
%options.droptol = 0.1;
for i = 1:numStrips
    ATmp = genAb(grid.subgrid{i},parameters);
    itMatStrip{i}.itMat = grid.subgrid{i}.I - tau*ATmp;
    %itMatStrip{i}.rhs = zeros(size(ATmp,1),1);
    %[itMatStrip{i}.L,itMatStrip{i}.U] = ilu(itMatStrip{i}.itMat,options);

    G(rows{i},cols{i}) = itMatStrip{i}.itMat \ grid.subgrid{i}.map;
end

G = sparse(G);

itMatCoarse = G' * itMatFull * G;
%[L,U] = ilu(itMatCoarse);

c = parameters.f(nodes(:,1),nodes(:,2));

C = parameters.f(coarseNodes(:,1),coarseNodes(:,2));

phim = zeros(numNodes,1);

sols_c = zeros(size(c,1),3);
sols_C = zeros(size(C,1),3);

for k = 1:K

    t = k*tau;

    [cTmp,bTmp] = setRHS(c,bFull,t,grid,parameters);
    rhs = cTmp + tau*bTmp;
    um = rhs;
    um(grid.dirichletDM) = 0;

    for i = 1:numStrips
        phim(rows{i}) = itMatStrip{i}.itMat \ um(rows{i});
        %[phim(rows{i}),~] = gmres(itMatStrip{i}.itMat,um(rows{i}),[],1e-8,25,itMatStrip{i}.L,itMatStrip{i}.U);
    end

    rhs = rhs - itMatFull*phim;
    rhs = G' * rhs;

    %C(:,k+1) = gmres(itMatCoarse,rhs,[],1e-10,25,L,U);
    C = itMatCoarse \ rhs;

    c = G * C + phim;

    switch k
        case store(1)
            sols_c(:,1) = c;
            sols_C(:,1) = C;
        case store(2)
            sols_c(:,2) = c;
            sols_C(:,2) = C;
        case store(3)
            sols_c(:,3) = c;
            sols_C(:,3) = C;
    end

end

end