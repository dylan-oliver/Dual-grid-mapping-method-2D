function grid = setGridProperties(grid,parameters)

nodes     = grid.nodes;
elmnts      = grid.elmnts;
lines     = grid.lines;
corners   = grid.corners;
numNodes  = size(nodes,1);
numElmnts   = size(elmnts,1);
numLines  = size(lines,1);
numStrips = grid.numStrips;

Rf = parameters.R;
Df = parameters.D;
vf = parameters.v;
muf = parameters.mu;

V     = zeros(numNodes,1);
x    = zeros(3,numElmnts);
y    = zeros(3,numElmnts);
R = zeros(numNodes,1);
D = zeros(2,2,3,numElmnts);
v = zeros(2,3,numElmnts);
mu = zeros(numNodes,1);
L = zeros(3,numElmnts);
n = zeros(2,3,numElmnts);
C = zeros(3,3,numElmnts);
det = zeros(numElmnts,1);
N = zeros(3,3,numElmnts);
Nx = zeros(3,numElmnts);
Ny = zeros(3,numElmnts);

svCentroid = zeros(3,2);

xBnd = zeros(2,numLines);
yBnd = zeros(2,numLines);
DBnd = zeros(2,2,2,numLines);
vBnd = zeros(2,2,numLines);
LBnd = zeros(2,numLines);
nBnd = zeros(2,numLines);
NBnd = zeros(3,2,numLines);

bcond = parameters.bcond;

dirichlet = false(numNodes,1);

for E = 1:numElmnts
    elmnt = elmnts(E,1:3);

    xv = nodes(elmnt,1);
    yv = nodes(elmnt,2);

    mid1 = [(xv(1) + xv(2))/2,(yv(1) + yv(2))/2];
    mid2 = [(xv(2) + xv(3))/2,(yv(2) + yv(3))/2];
    mid3 = [(xv(1) + xv(3))/2,(yv(1) + yv(3))/2];

    centroid = [xv(1) + xv(2) + xv(3),yv(1) + yv(2) + yv(3)]/3;

    x(1,E) = (centroid(1) + mid1(1))/2;
    x(2,E) = (centroid(1) + mid2(1))/2;
    x(3,E) = (centroid(1) + mid3(1))/2;

    y(1,E) = (centroid(2) + mid1(2))/2;
    y(2,E) = (centroid(2) + mid2(2))/2;
    y(3,E) = (centroid(2) + mid3(2))/2;

    D(:,:,1,E) = Df(x(1,E),y(1,E));
    D(:,:,2,E) = Df(x(2,E),y(2,E));
    D(:,:,3,E) = Df(x(3,E),y(3,E));

    v(:,1,E) = vf(x(1,E),y(1,E));
    v(:,2,E) = vf(x(2,E),y(2,E));
    v(:,3,E) = vf(x(3,E),y(3,E));

    edge1 = centroid - mid1;
    edge2 = centroid - mid2;
    edge3 = centroid - mid3;

    L(1,E) = norm(edge1,2);
    L(2,E) = norm(edge2,2);
    L(3,E) = norm(edge3,2);

    vertex2centroid = centroid - [xv,yv];
    mid2mid = [mid1;mid2;mid3] - [mid3;mid1;mid2];

    triArea1 = 0.5 * (mid2mid(1,1)*vertex2centroid(1,2) - mid2mid(1,2)*vertex2centroid(1,1));
    triArea2 = 0.5 * (mid2mid(2,1)*vertex2centroid(2,2) - mid2mid(2,2)*vertex2centroid(2,1));
    triArea3 = 0.5 * (mid2mid(3,1)*vertex2centroid(3,2) - mid2mid(3,2)*vertex2centroid(3,1));

    svCentroid(1,:) = ( [xv(1),yv(1)] + mid1 + mid3 + centroid )/4;
    svCentroid(2,:) = ( [xv(2),yv(2)] + mid1 + mid2 + centroid )/4;
    svCentroid(3,:) = ( [xv(3),yv(3)] + mid2 + mid3 + centroid )/4;

    R(elmnt(1)) = R(elmnt(1)) + Rf(svCentroid(1,1),svCentroid(1,2)) * triArea1;
    R(elmnt(2)) = R(elmnt(2)) + Rf(svCentroid(2,1),svCentroid(2,2)) * triArea2;
    R(elmnt(3)) = R(elmnt(3)) + Rf(svCentroid(3,1),svCentroid(3,2)) * triArea3;

    mu(elmnt(1)) = mu(elmnt(1)) + muf(svCentroid(1,1),svCentroid(1,2)) * triArea1;
    mu(elmnt(2)) = mu(elmnt(2)) + muf(svCentroid(2,1),svCentroid(2,2)) * triArea2;
    mu(elmnt(3)) = mu(elmnt(3)) + muf(svCentroid(3,1),svCentroid(3,2)) * triArea3;

    V(elmnt(1)) = V(elmnt(1)) + triArea1;
    V(elmnt(2)) = V(elmnt(2)) + triArea2;
    V(elmnt(3)) = V(elmnt(3)) + triArea3;

    n(1,1,E) = edge1(2)/L(1,E);
    n(1,2,E) = edge2(2)/L(2,E);
    n(1,3,E) = edge3(2)/L(3,E);

    n(2,1,E) = -edge1(1)/L(1,E);
    n(2,2,E) = -edge2(1)/L(2,E);
    n(2,3,E) = -edge3(1)/L(3,E);

    C(:,:,E) = [
           (yv(2) - yv(3)), -(xv(2) - xv(3)),  (xv(2)*yv(3) - xv(3)*yv(2))
          -(yv(1) - yv(3)),  (xv(1) - xv(3)), -(xv(1)*yv(3) - xv(3)*yv(1))
           (yv(1) - yv(2)), -(xv(1) - xv(2)),  (xv(1)*yv(2) - xv(2)*yv(1))
         ];

    det(E) = xv(1)*(yv(2) - yv(3)) - yv(1)*(xv(2) - xv(3)) + (xv(2)*yv(3) - xv(3)*yv(2));

    N(:,1,E) = [x(1,E) y(1,E) 1] * C(:,:,E)' / det(E);
    N(:,2,E) = [x(2,E) y(2,E) 1] * C(:,:,E)' / det(E);
    N(:,3,E) = [x(3,E) y(3,E) 1] * C(:,:,E)' / det(E);

    Nx(:,E) = C(:,1,E) / det(E);

    Ny(:,E) = C(:,2,E) / det(E);
end

R = R ./ V;
mu = mu ./ V;

for E = 1:numLines
    line = lines(E,:);
    elmnt = line(4);

    vertices = nodes(line(1:2),:);

    edgeMid = sum(vertices)/2;

    LBnd(1,E) = norm(vertices(1,:) - edgeMid,2);
    LBnd(2,E) = norm(vertices(2,:) - edgeMid,2);

    xBnd(1,E) = (vertices(1,1) + edgeMid(1))/2;
    xBnd(2,E) = (vertices(2,1) + edgeMid(1))/2;

    yBnd(1,E) = (vertices(1,2) + edgeMid(2))/2;
    yBnd(2,E) = (vertices(2,2) + edgeMid(2))/2;

    DBnd(:,:,1,E) = Df(xBnd(1,E),yBnd(1,E));
    DBnd(:,:,2,E) = Df(xBnd(2,E),yBnd(2,E));

    vBnd(:,1,E) = vf(xBnd(1,E),yBnd(1,E));
    vBnd(:,2,E) = vf(xBnd(2,E),yBnd(2,E));

    if bcond(line(3)) == 1
        dirichlet(line(1:2)) = true;
    end

    edge1 = edgeMid - vertices(1,:);
    edge2 = edgeMid - vertices(2,:);

    nBnd(1,1,E) = edge1(2)/LBnd(1,E);
    nBnd(2,1,E) = -edge1(1)/LBnd(1,E);

    nBnd(1,2,E) = edge2(2)/LBnd(2,E);
    nBnd(2,2,E) = -edge2(1)/LBnd(2,E);

    NBnd(:,1,E) = [xBnd(1,E) yBnd(1,E) 1] * C(:,:,elmnt)' / det(elmnt);
    NBnd(:,2,E) = [xBnd(2,E) yBnd(2,E) 1] * C(:,:,elmnt)' / det(elmnt);
end

edges = [
         lines(:,1)
         lines(:,2)
        ];
idx = ismember(edges(:,1),corners(:,1));
edges(idx,:) = [];
edges = unique(edges,'rows');

count = zeros(numNodes,1);
nodeFlag = zeros(numNodes,2);
lineFlag = false(numLines,2);

for E = 1:numLines
    line = lines(E,:);
    for j = 1:2
        if ismember(line(j),edges)
            if ~ismember(line(3),nodeFlag(line(j),:)) && count(line(j)) < 1 && bcond(line(3)) == 1
                count(line(j)) = count(line(j)) + 1;
                nodeFlag(line(j),count(line(j))) = line(3);
                lineFlag(E,j) = true;
            end
        end

        if ismember(line(j),corners(:,1))
            if ~ismember(line(3),nodeFlag(line(j),:)) && count(line(j)) < 2 && bcond(line(3)) == 1
                count(line(j)) = count(line(j)) + 1;
                nodeFlag(line(j),count(line(j))) = line(3);
                lineFlag(E,j) = true;
            end
        end
    end
end

count(count == 0) = 1;

grid.R = R;
grid.D = D;
grid.v = v;
grid.mu = mu;
grid.V = V;
grid.x = x;
grid.y = y;
grid.L = L;
grid.n = n;
grid.N = N;
grid.Nx = Nx;
grid.Ny = Ny;
grid.DBnd = DBnd;
grid.vBnd = vBnd;
grid.xBnd = xBnd;
grid.yBnd = yBnd;
grid.LBnd = LBnd;
grid.nBnd = nBnd;
grid.NBnd = NBnd;
grid.dirichlet = dirichlet;
grid.flag = lineFlag;
grid.count = count;

for p = 1:numStrips
    idxNodes = grid.subgrid{p}.idxNodes;
    idxElmnts = grid.subgrid{p}.idxElmnts;
    grid.subgrid{p}.R = grid.R(idxNodes);
    grid.subgrid{p}.D = grid.D(:,:,:,idxElmnts);
    grid.subgrid{p}.v = grid.v(:,:,idxElmnts);
    grid.subgrid{p}.mu = mu(idxNodes);
    grid.subgrid{p}.V = V(idxNodes);
    grid.subgrid{p}.x = x(:,idxElmnts);
    grid.subgrid{p}.y = y(:,idxElmnts);
    grid.subgrid{p}.L = L(:,idxElmnts);
    grid.subgrid{p}.n = n(:,:,idxElmnts);
    grid.subgrid{p}.N = N(:,:,idxElmnts);
    grid.subgrid{p}.Nx = Nx(:,idxElmnts);
    grid.subgrid{p}.Ny = Ny(:,idxElmnts);
    grid.subgrid{p}.DBnd = [];
    grid.subgrid{p}.vBnd = [];
    grid.subgrid{p}.xBnd = [];
    grid.subgrid{p}.yBnd = [];
    grid.subgrid{p}.LBnd = [];
    grid.subgrid{p}.nBnd = [];
    grid.subgrid{p}.NBnd = [];
end
end