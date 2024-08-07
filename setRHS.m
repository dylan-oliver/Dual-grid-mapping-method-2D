function [u,b] = setRHS(u,b,t,grid,parameters)

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

u(dirichlet) = 0;

for E = 1:numLines
    line = lines(E,:);

    switch bcond(line(3))
        case 1
            for sig = 1:2
                if flag(E,sig)
                    gj = parameters.g{line(3)};
                    u(line(sig)) = u(line(sig)) + gj(x(line(sig)),y(line(sig)),t);
                end
            end
        case 2
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
        case 3
            gj = parameters.g{line(3)};
            for sig = 1:2
                Lj = LBnd(sig,E);
                b(line(sig)) = b(line(sig)) + gj(xBnd(sig,E),yBnd(sig,E),t) * Lj;
            end
    end
end

u = u ./ count;
switch isempty(parameters.points)
    case true
        b = b ./ V + parameters.S(x,y,t) ./ R; % Delta function in S, do not divide by V.
    case false
        b = (b + parameters.S(x,y,t) ./ R) ./ V; % No delta function in S, divide by V.
end
b(dirichlet) = 0;

end