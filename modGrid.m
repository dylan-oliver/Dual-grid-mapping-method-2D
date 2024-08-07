function grid = modGrid(parameters)

Lx = parameters.Lx;
Ly = parameters.Ly;
points = parameters.points;
numStrips = parameters.numStrips;

if isempty(points)
elseif any(points(:,1) >= Lx) || any(points(:,1) <= 0) || any(points(:,2) >= Ly) || any(points(:,2) <= 0)
    error('Exact points must be placed strictly inside the problem domain.')
end

% Set options for partition algorithm in GMSH.
parameters.domainTopology = 1;
parameters.ghostCells = 0;
parameters.physicalGroups = 1;
parameters.compatibility = 0;

genMesh(parameters)
mesh

% Sort the strip labels on the grid in order from left to right (if there
% are 10 strips, the labels should progress from 1 on the far-left to 10 on
% the far-right).
mins = zeros(numStrips,1);
for i = 1:numStrips
    tmpStrip = msh.TRIANGLES(msh.TRIANGLES(:,4) == i,1:3);
    tempNodes = msh.POS(tmpStrip,1);
    mins(i) = min(tempNodes);
end
[~,idx] = sort(mins,1); % Corrected indices for each strip layer.

% Update the labels in the generated grid, adding numStrips so that strips
% with the same label aren't lumped together (if the first strip is
% labelled 1, and the second strip is labelled 5, then renaming strip 5 as
% strip 2 will cause strip 5 to be joined with another strip that is
% currently labelled as strip 2, and later renaming strip 2 would instead
% rename both strips 2 and the previous strip 5).
for i = 1:numStrips
    msh.TRIANGLES(msh.TRIANGLES(:,4) == idx(i),4) = i + numStrips;
end
% Adjust label numbering after correction.
msh.TRIANGLES(:,4) = msh.TRIANGLES(:,4) - numStrips;

nodes = msh.POS;
elmnts = msh.TRIANGLES;
lines = msh.LINES;
corners = msh.PNT(1:4,1);

interface = cell(numStrips-1,1);
numStripNodes = zeros(1,numStrips);
numInterfaceNodes = zeros(1,numStrips-1);

% Find interfaces based on where strips intersect.
for i = 1:numStrips-1
    tmpNodes0 = unique(elmnts(elmnts(:,4)==i,1:3));
    tmpNodes1 = unique(elmnts(elmnts(:,4)==i+1,1:3));
    tmpInterface = intersect(nodes(tmpNodes0,:),nodes(tmpNodes1,:),'rows');
    interface{i} = reshape(find(ismember(nodes,tmpInterface,'rows')),1,'');
    numInterfaceNodes(i) = length(interface{i});
    if i == 1
        numStripNodes(i) = length(tmpNodes0) - numInterfaceNodes(i);
        if numStrips == 2
            numStripNodes(i+1) = length(tmpNodes1) - length(interface{i});
        end
    elseif i == numStrips-1
        numStripNodes(i) = length(tmpNodes0) - numInterfaceNodes(i) - numInterfaceNodes(i-1);
        numStripNodes(i+1) = length(tmpNodes1) - length(interface{i});
    else
        numStripNodes(i) = length(tmpNodes0) - numInterfaceNodes(i) - numInterfaceNodes(i-1);
    end
end
% Save a copy of the node numbers for nodes along each interface.
interfaceNodes = unique([interface{:}]);

% Prepare to renumber nodes.
nodesTmp = zeros(size(nodes));
elmntsTmp = zeros(size(elmnts));
linesTmp = zeros(size(lines,1),size(lines,2)+3);
cornersTmp = zeros(size(corners));
idx = zeros(size(nodes,1),1); % Redefine idx as index from relabelled nodes to original nodes

% A counter is pre-allocated to keep track of the current node number.
count = 1;
for i = 1:numStrips-1
    % Select node numbers from current strip.
    tmpStrip = unique(elmnts(elmnts(:,4) == i,1:3));

    % If we are in strip 1, there is only 1 interface to the right. Every
    % other strip besides the last has an interface to the left and to the
    % right. Increment the node number counter by the number of nodes on
    % the left-hand interface so that they are not overwritten when
    % starting to renumber the nodes in the following strip.
    if i == 1
        tmpInterface0 = [];
        tmpInterface = interface{i};
    else
        count = count + numInterfaceNodes(i-1);
        tmpInterface0 = interface{i-1};
        tmpInterface = interface{i};
    end

    % If the current node is NOT on an interface, renumber it according to
    % the counter.
    for jj = 1:length(tmpStrip)
        tmpNode = tmpStrip(jj);
        if ~ismember(tmpNode,tmpInterface) && ~ismember(tmpNode,tmpInterface0)
            elmntsTmp(elmnts == tmpNode) = count;
            linesTmp(lines == tmpNode) = count;
            cornersTmp(corners == tmpNode) = count;
            nodesTmp(count,:) = nodes(tmpNode,:);
            idx(tmpNode) = count;
            count = count + 1;
        end
    end
end

% Same as above, applied to the final strip.
tmpStrip = unique(elmnts(elmnts(:,4) == numStrips,1:3));
count = count + numInterfaceNodes(numStrips-1);
for jj = 1:length(tmpStrip)
    tmpNode = tmpStrip(jj);
    if ~ismember(tmpNode,interfaceNodes)
        elmntsTmp(elmnts == tmpNode) = count;
        linesTmp(lines == tmpNode) = count;
        cornersTmp(corners == tmpNode) = count;
        nodesTmp(count,:) = nodes(tmpNode,:);
        idx(tmpNode) = count;
        count = count + 1;
    end
end

% Renumber the nodes on the interfaces.
for i = 1:numStrips-1
    tmpInterface = interface{i};
    for jj = 1:numInterfaceNodes(i)
        count = sum(numStripNodes(1:i)) + sum(numInterfaceNodes(1:i-1)) + jj;
        elmntsTmp(elmnts == tmpInterface(jj)) = count;
        linesTmp(lines == tmpInterface(jj)) = count;
        cornersTmp(corners == tmpInterface(jj)) = count;
        nodesTmp(count,:) = nodes(tmpInterface(jj),:);
        idx(tmpInterface(jj)) = count;
    end
end

% Since nodes have only been relabelled in the element array, the
% corresponding set/strip they belong to remains unchanged.
elmntsTmp(:,4) = elmnts(:,4);

% Reset boundary labels
for i = 1:size(linesTmp,1)
    tmpLine = nodesTmp(linesTmp(i,1:2),:);

    % South
    if (tmpLine(1,2) == 0) && (tmpLine(2,2) == 0)
        linesTmp(i,3) = 1;

    % East
    elseif (tmpLine(1,1) == Lx) && (tmpLine(2,1) == Lx)
        linesTmp(i,3) = 2;

    % North
    elseif (tmpLine(1,2) == Ly) && (tmpLine(2,2) == Ly)
        linesTmp(i,3) = 3;

    % West
    elseif (tmpLine(1,1) == 0) && (tmpLine(2,1) == 0)
        linesTmp(i,3) = 4;
        
    else
        linesTmp(i,3) = 0;
    end
end
linesTmp(linesTmp(:,3) == 0,:) = [];

% Link boundary edges to corresponding elements
for i = 1:size(linesTmp,1)
    line = linesTmp(i,1:2);

    for sig = 1:3
        switch sig
            case 1
                nbr = 2;
            case 2
                nbr = 3;
            case 3
                nbr = 1;
        end

        [chk,idx] = ismember(line,elmntsTmp(:,[sig,nbr]),'rows');
        if chk
            linesTmp(i,4) = idx;
            linesTmp(i,5) = find(elmntsTmp(idx,[nbr,sig]) == line(1));
            linesTmp(i,6) = find(elmntsTmp(idx,[nbr,sig]) == line(2));
        end

        [chk,idx] = ismember(line,elmntsTmp(:,[nbr,sig]),'rows');
        if chk
            linesTmp(i,4) = idx;
            linesTmp(i,5) = find(elmntsTmp(idx,[nbr,sig]) == line(1));
            linesTmp(i,6) = find(elmntsTmp(idx,[nbr,sig]) == line(2));
        end
    end
end

% Set up storage for interface nodes
interface = cell(numStrips-1,1);

% Re-define the interface arrays (the number of nodes in each strip and
% along each interface remain unchanged, so there's no need to recompute
% these values).
for i = 1:numStrips-1
    tmpStrip0 = elmntsTmp(elmntsTmp(:,4)==i,1:3);
    tmpStrip1 = elmntsTmp(elmntsTmp(:,4)==i+1,1:3);
    tmpNodes0 = unique(tmpStrip0);
    tmpNodes1 = unique(tmpStrip1);
    tmpInterface = intersect(nodesTmp(tmpNodes0,:),nodesTmp(tmpNodes1,:),'rows');
    interface{i} = reshape(find(ismember(nodesTmp,tmpInterface,'rows')),1,'');
end
% Re-define the copy of the nodes along each interface (allowing us to
% determine the boundary nodes surrounding each strip).
interfaceNodes = unique([interface{:}]);

% Set indices for boundary nodes
boundaryNodes = unique(linesTmp(:,1:2));

% Extract and save the boundary nodes surrounding each strip (nodes that
% are located on the boundary of the domain or on an interface between
% strips).
stripBoundary = cell(numStrips,1);
numStripBoundaryNodes = zeros(1,numStrips);
for i = 1:numStrips
    tmpStrip = unique(elmntsTmp(elmntsTmp(:,4) == i,1:3))';
    for jj = 1:length(tmpStrip)
        if ismember(tmpStrip(jj),boundaryNodes) || ismember(tmpStrip(jj),interfaceNodes)
            stripBoundary{i}(end+1) = tmpStrip(jj);
        end
    end
    numStripBoundaryNodes(i) = length(stripBoundary{i});
end

% Define coarse-grid node indices
coarseNodes = unique([stripBoundary{:}]);

% Set coarse-grid dirichlet node locations (for use with DM method)
dirichletDM = ismember(unique(elmntsTmp(:,1:3)),coarseNodes);

% Set indices for double-up rows/columns (for use with definition of
% mapping matrices in DM method)
doubleUpRows = cell(numStrips,1);
doubleUpCols = cell(numStrips,1);
for i = 1:numStrips
    if i == 1
        doubleUpRows{i} = ( sum(numStripNodes(1:i-1)) + 1 ):( sum(numStripNodes(1:i)) + sum(numInterfaceNodes(i)) );
    elseif i == numStrips
        doubleUpRows{i} = ( sum(numStripNodes(1:i-1)) + sum(numInterfaceNodes(1:i-2)) + 1 ):( sum(numStripNodes(1:i)) + sum(numInterfaceNodes(1:i-1)) );
    else
        doubleUpRows{i} = ( sum(numStripNodes(1:i-1)) + sum(numInterfaceNodes(1:i-2)) + 1 ):( sum(numStripNodes(1:i)) + sum(numInterfaceNodes(1:i)) );
    end
    doubleUpCols{i} = ( sum(numStripBoundaryNodes(1:i-1)) - sum(numInterfaceNodes(1:i-1)) + 1 ):( sum(numStripBoundaryNodes(1:i)) - sum(numInterfaceNodes(1:i-1)) );
end

linesTmp(linesTmp(:,3)>4,:) = [];

% Assemble modified grid for use with finite volume and DM methods.
grid.Lx = Lx;
grid.Ly = Ly;
grid.numStrips = numStrips;
grid.nodes = nodesTmp;
grid.elmnts = elmntsTmp;
grid.lines = linesTmp;
grid.corners = cornersTmp;
grid.coarseNodes = coarseNodes;
grid.dirichletDM = dirichletDM;
grid.I = speye(size(nodesTmp,1));
grid.doubleUpRows = doubleUpRows;
grid.doubleUpCols = doubleUpCols;
%grid.idx = idx;

% Assemble sub-grids for use with DM method
for p = 1:numStrips
    nodeOffset = sum(numStripNodes(1:p-1)) + sum(numInterfaceNodes(1:p-2));
    tmpStrip = elmntsTmp(elmntsTmp(:,4)==p,:);
    tmpNodes = unique(tmpStrip(:,1:3));
    grid.subgrid{p}.nodes = nodesTmp(tmpNodes,:);
    grid.subgrid{p}.elmnts = [tmpStrip(:,1:3) - nodeOffset,tmpStrip(:,4)];
    grid.subgrid{p}.lines = [];
    grid.subgrid{p}.dirichlet = ismember(tmpNodes,stripBoundary{p});
    map = diag(grid.subgrid{p}.dirichlet);
    grid.subgrid{p}.map = sparse(map(:,any(map)));
    grid.subgrid{p}.I = speye(size(tmpNodes,1));
    grid.subgrid{p}.idxNodes = tmpNodes;
    grid.subgrid{p}.idxElmnts = ismember(elmntsTmp(:,1:3),tmpStrip(:,1:3),'rows');
end
end
