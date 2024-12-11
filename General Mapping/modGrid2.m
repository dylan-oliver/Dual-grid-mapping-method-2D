function grid = modGrid2(parameters)
% Extract domain information.
xL = parameters.xL;
yH = parameters.yH;

if parameters.newGrid
    % If creating a new grid for the heterogeneous domain, set options for
    % partition algorithm in GMSH and partition into a set of sub-domain
    % meshes.
    parameters.domainTopology = 1;
    parameters.ghostCells = 0;
    parameters.physicalGroups = 1;
    parameters.compatibility = 0;

    hetMesh2(parameters)
    mesh
    save(['Data/Test_Case_',num2str(parameters.testCase),'_Mesh.mat'],'msh')
else
    % If a mesh has already been created at some point, it can be utilised
    % instead of needing to generate a new mesh.
    load(['Data/Test_Case_',num2str(parameters.testCase),'_Mesh.mat'],'msh')
end

% Extract grid information from the mesh created above.
nodes = msh.POS(:,1:2);
elmnts = msh.TRIANGLES;
lines = msh.LINES;
corners = msh.PNT(1:4,1);

% Number of partitions of the domain.
numStrips = max(elmnts(:,4));

% Reset boundary labels
for p = 1:size(lines,1)
    tmpLine = nodes(lines(p,1:2),:);

    % South
    if (tmpLine(1,2) == 0) && (tmpLine(2,2) == 0)
        lines(p,3) = 1;

    % East
    elseif (tmpLine(1,1) == xL) && (tmpLine(2,1) == xL)
        lines(p,3) = 2;

    % North
    elseif (tmpLine(1,2) == yH) && (tmpLine(2,2) == yH)
        lines(p,3) = 3;

    % West
    elseif (tmpLine(1,1) == 0) && (tmpLine(2,1) == 0)
        lines(p,3) = 4;
        
    else
        lines(p,3) = 0;
    end
end
% No special conditions are enforced anywhere that isn't a boundary (the
% coarse-grid nodes are accounted for in the lines above anyway), so the
% remaining marked points on any remaining edges can be discarded.
lines(lines(:,3) == 0,:) = [];

% Link boundary edges to corresponding elements
lines(:,4:6) = 0;
for p = 1:size(lines,1)
    line = lines(p,1:2);

    for sig = 1:3
        switch sig
            case 1
                nbr = 2;
            case 2
                nbr = 3;
            case 3
                nbr = 1;
        end

        [chk,idx] = ismember(line,elmnts(:,[sig,nbr]),'rows');
        if chk
            lines(p,4) = idx;
            lines(p,5) = find(elmnts(idx,[nbr,sig]) == line(1));
            lines(p,6) = find(elmnts(idx,[nbr,sig]) == line(2));
        end

        [chk,idx] = ismember(line,elmnts(:,[nbr,sig]),'rows');
        if chk
            lines(p,4) = idx;
            lines(p,5) = find(elmnts(idx,[nbr,sig]) == line(1));
            lines(p,6) = find(elmnts(idx,[nbr,sig]) == line(2));
        end
    end
end

% A list of nodes placed on the domain boundary.
boundary = nodes(unique(lines(:,1:2)),:);

% The counter keeps track of the global coarse-grid node labels.
counter = 1;

% The globalID variable stores the
globalID = cell(1,numStrips);

% The globalPoints variable stores the list of coarse-grid nodes that have
% been assigned a label (so that no coarse-grid nodes are mistakenly
% labelled twice during the processing of neighboring blocks/parts that
% share an interface).
globalPoints = zeros(0,2);
for id = 1:numStrips
    % The global indices of fine-grid nodes local to the current block.
    partPoints = unique(elmnts(elmnts(:,4) == id,1:3));

    % The second column is created to also store the global indices of
    % coarse-grid nodes on the boundary/boundaries of the current block.
    % The number of coarse-grid nodes is <= the number of fine-grid nodes,
    % so the second column may contain trailing zeros.
    partPoints(:,2) = 0 .* partPoints;

    % The corresponding vertices.
    partVertices = nodes(partPoints(:,1),:);

    % All other vertices that are not located in the interior of the
    % current block (vertices on the interface between the current block
    % and the rest of the domain are included here).
    otherVertices = nodes(elmnts(elmnts(:,4) ~= id,1:3),:);

    % The vertices on the interface between the current block and the rest
    % of the domain.
    interfaceVertices = intersect(partVertices,otherVertices,'rows');

    % The vertices in the current block that coincide with the domain
    % boundary.
    boundaryVertices = intersect(partVertices,boundary,'rows');

    % Combination of both vertex sets above.
    combinedVertices = unique([interfaceVertices;boundaryVertices],'rows');

    % Check if the coarse nodes on the border of the current block have
    % been labelled yet.
    for p = 1:size(partVertices,1)
        if ismember(partVertices(p,:),globalPoints,'rows')
            % If the current vertex is already accounted for in the set of
            % coarse nodes, proceed with iteration.
            continue
        elseif ismember(partVertices(p,:),combinedVertices,'rows')
            % Otherwise, the node needs to be accounted for in the coarse
            % grid. This avoids creating a label for the coarse-grid nodes 
            % in one block/part, and then creating another new label for
            % the same nodes again when they appear in a neighboring block
            % that shares an interface. 
            partPoints(p,2) = counter;
            counter = counter + 1;

            % Add the current node to the list of processed coarse-grid
            % nodes to avoid processing it again in another neighboring
            % block/part.
            globalPoints(end+1,:) = partVertices(p,:);
        end
    end

    % Store the global coarse vertex labels.
    globalID{id} = partPoints;
end

% Pre-allocate the global node label storage for each block/part.
nodeLabels = cell(1,numStrips); % Global node labels on the fine grid.
coarseLabels = nodeLabels; % Global node labels on the coarse grid.

% A general list of all the global coarse-grid node labels is created to
% allow application of the mapping method interface conditions.
coarseNodes = [];

% The index variable stores a dictionary linking the global fine-grid node
% labels to their corresponding coarse-grid node labels. For example, if
% node 10 is 
index = nodeLabels;
rIndex = nodeLabels;
for p = 1:numStrips
    for j = p+1:numStrips
        % Update node label information for all blocks/parts, starting from
        % the second block/part as the first has already been processed and
        % will already contain all necessary information.
        % Check if any of the global fine-grid node labels in the other
        % blocks/parts match the global fine-grid node labels in the
        % current one. If there are any matches, then the coarse-grid
        % of the current block/part overlaps with a neighboring
        % block/part, so assign the existing node labels to the neighboring
        % block/part.
        [idxC,idxN] = ismember(globalID{p}(:,1),globalID{j}(:,1));
        idxN = idxN(idxC);
        globalID{j}(idxN,2) = globalID{p}(idxC,2);
    end
    % The number of 
    idx = globalID{p}(:,2) > 0;
    tmpLabels = globalID{p}(idx,1);
    coarseNodes(end+1:end+length(tmpLabels)) = tmpLabels;
    nodeLabels{p} = globalID{p}(:,1);
    coarseLabels{p} = globalID{p}(idx,2);

    % Record a global -> local index for the nodes in the current block.
    dictKeys = nodeLabels{p};
    dictVals = transpose(1:length(nodeLabels{p}));
    index{p} = dictionary(dictKeys,dictVals);

    % Also record the coarse -> fine index for the coarse nodes in the
    % current block.
    reverseKeys = coarseLabels{p};
    reverseVals = tmpLabels;
    rIndex{p} = dictionary(reverseKeys,reverseVals);
end
coarseNodes = unique(coarseNodes);

dirichletDM = ismember(unique(elmnts(:,1:3)),coarseNodes);

% Assemble modified grid for use with finite volume and DM methods.
grid.Lx = xL;
grid.Ly = yH;
grid.numStrips = numStrips;
grid.nodes = nodes(:,1:2);
grid.elmnts = elmnts;
grid.lines = lines;
grid.corners = corners;
grid.coarseNodes = coarseNodes;
grid.dirichletDM = dirichletDM;
grid.I = speye(size(nodes,1));
grid.doubleUpRows = nodeLabels;
grid.doubleUpCols = coarseLabels;

% Assemble sub-grids for use with DM method
for p = 1:numStrips
    tmpStrip = elmnts(elmnts(:,4) == p,:);
    tmpNodes = unique(tmpStrip(:,1:3));
    grid.subgrid{p}.nodes = nodes(tmpNodes,:);
    grid.subgrid{p}.elmnts = tmpStrip(:,1:3);
    grid.subgrid{p}.lines = [];
    grid.subgrid{p}.dirichlet = ismember(tmpNodes,coarseNodes);
    map = diag(grid.subgrid{p}.dirichlet);
    grid.subgrid{p}.map = sparse(map(:,any(map)));
    grid.subgrid{p}.I = speye(size(tmpNodes,1));
    grid.subgrid{p}.idxNodes = tmpNodes;
    grid.subgrid{p}.idxElmnts = ismember(elmnts(:,1:3),tmpStrip(:,1:3),'rows');
    grid.subgrid{p}.index = index{p};
    grid.subgrid{p}.rIndex = rIndex{p};
end
end
