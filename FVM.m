function sols = FVM(grid,parameters)

nodes = grid.nodes;
numNodes = size(nodes,1);

store = parameters.store;

f = parameters.f;

T = parameters.T;
K = parameters.K;
tau = T/K;

I = grid.I;

[A,b0] = genAb(grid,parameters);
itMat = I - tau * A;
%[L,U] = ilu(itMat);

c = f(nodes(:,1),nodes(:,2));

sols = zeros(numNodes,3);

for k = 1:K

    t = k*tau;
    [uTmp,bTmp] = setRHS(c,b0,t,grid,parameters);

    %u(:,k+1) = gmres(itMat,uTmp + tau*bTmp,[],1e-10,25,L,U);
    c = itMat \ (uTmp + tau*bTmp);

    switch k
        case store(1)
            sols(:,1) = c;
        case store(2)
            sols(:,2) = c;
        case store(3)
            sols(:,3) = c;
    end

end

end