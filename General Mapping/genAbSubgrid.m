function [A,b] = genAbSubgrid(grid)

elmnts = grid.elmnts;
index  = grid.index;

numNodes  = size(grid.nodes,1);
numElmnts = size(elmnts,1);

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

dirichlet = grid.dirichlet;

row = zeros(1,2*9*numElmnts); col = row; val = row;

for E = 1:numElmnts

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

        idx = 9*(E-1) + 3*(sig-1) + 1;
        row(idx) = index(elmnt(sig)); row(idx+1) = index(elmnt(sig)); row(idx+2) = index(elmnt(sig));
        col(idx) = index(elmnt(1));   col(idx+1) = index(elmnt(2));   col(idx+2) = index(elmnt(3));
        val(idx) = qn1;               val(idx+1) = qn2;               val(idx+2) = qn3;

        idx = 9*numElmnts + idx;
        row(idx) = index(elmnt(nbr)); row(idx+1) = index(elmnt(nbr)); row(idx+2) = index(elmnt(nbr));
        col(idx) = index(elmnt(1));   col(idx+1) = index(elmnt(2));   col(idx+2) = index(elmnt(3));
        val(idx) = -qn1;              val(idx+1) = -qn2;              val(idx+2) = -qn3;

    end

end

A = sparse(row,col,val);
A = A ./ (R .* V);
A(1:numNodes+1:numNodes*numNodes) = A(1:numNodes+1:numNodes*numNodes) - mu' ./ R';
A(dirichlet,:) = 0;

b = sparse(numNodes,1,0);

end
