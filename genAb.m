function [A,b] = genAb(grid,parameters)

elmnts     = grid.elmnts;
lines     = grid.lines;

numNodes = size(grid.nodes,1);
numElmnts  = size(elmnts,1);
numLines  = size(lines,1);

V     = grid.V;
L  = grid.L;
n = grid.n;
N = grid.N;
Nx = grid.Nx;
Ny = grid.Ny;
R = grid.R;
D = grid.D;
v = grid.v;
mu    = grid.mu;

DBnd = grid.DBnd;
vBnd = grid.vBnd;
LBnd = grid.LBnd;
nBnd = grid.nBnd;
NBnd = grid.NBnd;

dirichlet = grid.dirichlet;

bcond = parameters.bcond;

A = zeros(numNodes,numNodes);
b = zeros(numNodes,1);

for E = 1:numElmnts

    elmnt = elmnts(E,:);

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

        A(elmnt(sig),elmnt(1)) = A(elmnt(sig),elmnt(1)) + qn1;
        A(elmnt(sig),elmnt(2)) = A(elmnt(sig),elmnt(2)) + qn2;
        A(elmnt(sig),elmnt(3)) = A(elmnt(sig),elmnt(3)) + qn3;

        A(elmnt(nbr),elmnt(1)) = A(elmnt(nbr),elmnt(1)) - qn1;
        A(elmnt(nbr),elmnt(2)) = A(elmnt(nbr),elmnt(2)) - qn2;
        A(elmnt(nbr),elmnt(3)) = A(elmnt(nbr),elmnt(3)) - qn3;

    end

end

for E = 1:numLines
    line = lines(E,:);

    switch bcond(line(3))
        case 2
            elmnt = elmnts(line(4),:);
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

                A(elmnt(pnt),elmnt(1)) = A(elmnt(pnt),elmnt(1)) + qn1;
                A(elmnt(pnt),elmnt(2)) = A(elmnt(pnt),elmnt(2)) + qn2;
                A(elmnt(pnt),elmnt(3)) = A(elmnt(pnt),elmnt(3)) + qn3;
            end
    end
end

A = A ./ (R .* V);
for i = 1:numNodes
    A(i,i) = A(i,i) - mu(i)/R(i);
end
A(dirichlet,:) = 0;
A = sparse(A);

end
