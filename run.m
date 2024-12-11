%% Grid construction
% Copy over run, hetMesh2, replace genfigs, copy over data
clearvars
close all
clc

%% Pick test case and set no. of strips for DM method
% Set test case, set no. of strips for DM method.
parameters.testCase = 6;

% Mesh partitioning parameters. xNumStrips indicates the number of
% horizontal partitions/vertical strips to make.
parameters.numStrips = 500;

% Choose to generate a new grid using GMSH. True generates a new grid,
% false attempts to load a pre-existing grid, if present. If the number of
% strips is changed, a new grid must be generated in order to correctly
% partition the domain.
parameters.newGrid = true;

% Choose to save generated mesh and corresponding solution data.
parameters.saveInfo = false;

% Choose to generate plots.
makePlots = true;

% GMSH path on your workstation.
parameters.gmshPath = 'gmsh ';

%% Construct a grid over a rectangular domain [0,Lx] x [0,Ly]
switch parameters.testCase
    case 0
        % Horizontal and vertical domain lengths.
        xL = 1; parameters.xL = xL;
        yH = 1; parameters.yH = yH;

        % Mesh refinement parameter (smaller = finer grid).
        parameters.ref = 0.05;

        % Ensure these specified vertical lines are accounted for on the
        % mesh. Specify a vertical line with end-points (px0,py0) and
        % (px1,py1) by adding a 2x2 matrix below in the form
        % [px0,py0;px1,py1].
        parameters.lines = {[0,0;0,yH],[xL,0;xL,yH]};

        % Ensure these specified points are created on the mesh. Specify a
        % point of interest at location (px0,py0) on the domain by adding a
        % 1x2 vector below in the form [px0,py0].
        parameters.points = [];

        % Generate the grid and partition using the above parameters.
        grid = modGrid(parameters);

    case 1
        % Horizontal and vertical domain lengths.
        xL = 1; parameters.xL = xL;
        yH = 1; parameters.yH = yH;

        % Mesh refinement parameter (smaller = finer grid)
        parameters.ref = 0.0115;

        % Ensure these specified vertical lines are accounted for on the
        % mesh. Specify a vertical line with end-points (px0,py0) and
        % (px1,py1) by adding a 2x2 matrix below in the form
        % [px0,py0;px1,py1].
        parameters.lines = {[0,0;0,yH],[xL,0;xL,yH]};

        % Ensure these specified points are created on the mesh. Specify a
        % point of interest at location (px0,py0) on the domain by adding a
        % 1x2 vector below in the form [px0,py0].
        parameters.points = [];

        % Generate the grid and partition using the above parameters.
        grid = modGrid(parameters);

    case 2
        % Horizontal and vertical domain lengths.
        xL = 30; parameters.xL = xL;
        yH = 20; parameters.yH = yH;

        % Mesh refinement parameter (smaller = finer grid)
        parameters.ref = 0.2825;

        % Ensure these specified vertical lines are accounted for on the
        % mesh. Specify a vertical line with end-points (px0,py0) and
        % (px1,py1) by adding a 2x2 matrix below in the form
        % [px0,py0;px1,py1].
        parameters.lines = {[0,0;0,yH],[xL,0;xL,yH]};

        % Ensure these specified points are created on the mesh. Specify a
        % point of interest at location (px0,py0) on the domain by adding a
        % 1x2 vector below in the form [px0,py0].
        parameters.points = [[5,7.5];[5,12.5];[10,10]];

        % Generate the grid and partition using the above parameters.
        grid = modGrid(parameters);

    case 3
        % Horizontal and vertical domain lengths.
        xL = 13; parameters.xL = xL;
        yH = 10; parameters.yH = yH;

        % Mesh refinement parameter (smaller = finer grid)
        parameters.ref = 0.1315;

        % Ensure these specified vertical lines are accounted for on the
        % mesh. Specify a vertical line with end-points (px0,py0) and
        % (px1,py1) by adding a 2x2 matrix below in the form
        % [px0,py0;px1,py1].
        parameters.lines = {[0,0;0,yH],[2,0;2,yH],[3,0;3,yH],[xL,0;xL,yH]};

        % Ensure these specified points are created on the mesh. Specify a
        % point of interest at location (px0,py0) on the domain by adding a
        % 1x2 vector below in the form [px0,py0].
        parameters.points = [];

        % Generate the grid and partition using the above parameters.
        grid = modGrid(parameters);

    case 4
        % Horizontal and vertical domain lengths.
        xL = 20; parameters.xL = xL;
        yH = 10; parameters.yH = yH;

        % Mesh refinement parameter (smaller = finer grid).
        parameters.ref = 0.15;

        % The domain type is heterogeneous in the x-direction only. The
        % mask variable in the data file below contains a material type for
        % each of 50 layers over the domain. The variable xLines contains
        % the x-coordinates of the interfaces between differing material
        % layers, and the modMask variable abbreviates the mask variable so
        % that each entry corresponds to one material layer. For example,
        % xLines(1) and xLines(2) bound the first material layer, and
        % modMask(1) is the corresponding material type.
        load('Data/hetDomainMask.mat','modMask','xLines');

        % Place vertical lines on the interfaces between material layers.
        parameters.lines = {};
        for i = 1:length(xLines)
            parameters.lines{end+1} = [xLines(i),0;xLines(i),yH];
        end

        % Ensure these specified points are created on the mesh. Specify a
        % point of interest at location (px0,py0) on the domain by adding a
        % 1x2 vector below in the form [px0,py0].
        parameters.points = [];

        % Generate the grid and partition using the above parameters.
        grid = modGrid(parameters);

    case 5
        % Add the general mapping functions to path.
        addpath('General Mapping')

        % Horizontal and vertical domain lengths.
        xL = 4; parameters.xL = xL;
        yH = 1; parameters.yH = yH;

        % Mesh refinement parameter (smaller = finer grid).
        parameters.ref = 0.01;%0.05;%0.01;

        % Otherwise, load a proper 2D heterogeneous domain where
        % material properties are assigned to either circular
        % regions, or an 'in-between' region, and heterogeneity may
        % vary by x- and y-direction.
        load('Data/hetDomain.mat','circles','radii');

        % Ensure these specified vertical lines are accounted for
        % on the mesh. Specify a vertical line with end-points
        % (px0,py0) and (px1,py1) by adding a 2x2 matrix below in
        % the form [px0,py0;px1,py1].
        parameters.lines = {[0,0;0,yH],[xL,0;xL,yH]};

        % Ensure these specified points are created on the mesh. Specify a
        % point of interest at location (px0,py0) on the domain by adding a
        % 1x2 vector below in the form [px0,py0].
        parameters.points = [];

        % Generate the grid and partition using the above parameters.
        grid = modGrid(parameters);

    case 6
        % Add the general mapping functions to path.
        addpath('General Mapping')

        % Horizontal and vertical domain lengths.
        xL = 4; parameters.xL = xL;
        yH = 1; parameters.yH = yH;

        % Mesh refinement parameter (smaller = finer grid).
        parameters.ref = 0.002;%0.01

        % Otherwise, load a proper 2D heterogeneous domain where
        % material properties are assigned to either circular
        % regions, or an 'in-between' region, and heterogeneity may
        % vary by x- and y-direction.
        load('Data/hetDomain.mat','circles','radii');

        % Ensure these specified vertical lines are accounted for
        % on the mesh. Specify a vertical line with end-points
        % (px0,py0) and (px1,py1) by adding a 2x2 matrix below in
        % the form [px0,py0;px1,py1].
        parameters.lines = {[0,0;0,yH],[xL,0;xL,yH]};

        % Ensure these specified points are created on the mesh. Specify a
        % point of interest at location (px0,py0) on the domain by adding a
        % 1x2 vector below in the form [px0,py0].
        parameters.points = [];

        % Generate a grid and partition into general parts, rather than
        % vertical strips.
        grid = modGrid2(parameters);
end

sprintf(['Meshing complete for test case %g with %g strips on ',char(datetime),', starting FVM/DM solvers...'],parameters.testCase,parameters.numStrips)

%% Boundary/initial conditions, time-stepping, and transport coefficients
switch parameters.testCase
    case 0
        % Time-stepping parameters
        parameters.T = 1; % Stopping time
        parameters.K = 1000; % No. of time steps
        store = parameters.K*[1/10,1/2,1];

        % Retardation factor
        parameters.R = @(x,y) 1 + 0.*x;

        % Diffusivity coefficient (tensor)
        parameters.D = @(x,y) [1,0;0,1];

        % Velocity coefficient (vector)
        parameters.v = @(x,y) [0;-1];

        % Reaction decay rate coefficient
        parameters.mu = @(x,y) 0.*x;

        % Sink/source terms
        parameters.S = @(x,y,t) 0.*x;

        % Initial condition
        parameters.f = @(x,y) 0.*x;

        % South boundary condition (y is a dummy variable)
        parameters.bcond(1) = 2;
        parameters.g{1} = @(x,y,t) 0.*x;

        % East boundary condition (x is a dummy variable)
        parameters.bcond(2) = 2;
        parameters.g{2} = @(x,y,t) 0.*y;

        % North boundary condition (y is a dummy variable)
        parameters.bcond(3) = 1;
        parameters.g{3} = @(x,y,t) 1 + 0.*x;

        % West boundary condition (x is a dummy variable)
        parameters.bcond(4) = 2;
        parameters.g{4} = @(x,y,t) 0.*y;

        % Add additional grid properties for discretisation
        grid = setGridProperties(grid,parameters);

        % Fine-scale FVM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        sols_c_FVM = FVM(grid,parameters);
        timerFVM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        % DM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        [sols_c_DM,sols_C_DM] = DM(grid,parameters);
        timerDM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

    case 1
        % Time-stepping parameters
        parameters.T = 20; % Stopping time
        parameters.K = 2000; % No. of time steps
        store = parameters.K*[1/10,1/2,1];

        % Retardation factor
        parameters.R = @(x,y) 50 + 0.*x;

        % Diffusivity coefficient (tensor)
        parameters.D = @(x,y) [1,-0.1;-0.1,1];

        % Velocity coefficient (vector)
        parameters.v = @(x,y) [1;-0.01];

        % Reaction decay rate coefficient
        parameters.mu = @(x,y) 0.01 + 0.*x;

        % Sink/source terms
        points = parameters.points;
        parameters.S = @(x,y,t) 0.*x;

        % Initial condition
        parameters.f = @(x,y) 0.*x;

        % South boundary condition (y is a dummy variable)
        parameters.bcond(1) = 3;
        parameters.g{1} = @(x,y,t) 0.*x;

        % East boundary condition (x is a dummy variable)
        parameters.bcond(2) = 2;
        parameters.g{2} = @(x,y,t) 0.*y;

        % North boundary condition (y is a dummy variable)
        parameters.bcond(3) = 1;
        parameters.g{3} = @(x,y,t) exp(-(4*x).^2);

        % West boundary condition (x is a dummy variable)
        parameters.bcond(4) = 3;
        parameters.g{4} = @(x,y,t) 0.*y;

        % Add additional grid properties for discretisation
        grid = setGridProperties(grid,parameters);

        % Fine-scale FVM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        sols_c_FVM = FVM(grid,parameters);
        timerFVM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        % DM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        [sols_c_DM,sols_C_DM] = DM(grid,parameters);
        timerDM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

    case 2
        % Time-stepping parameters
        parameters.T = 300; % Stopping time
        parameters.K = 30000; % No. of time steps
        store = parameters.K*[1/10,1/2,1];

        % Retardation factor
        parameters.R = @(x,y) 5.3 + 0.*x;

        % Diffusivity coefficient (tensor)
        parameters.D = @(x,y) [0.1,0;0,0.03];

        % Velocity coefficient (vector)
        parameters.v = @(x,y) [0.1;0];

        % Reaction decay rate coefficient
        parameters.mu = @(x,y) 0.01 + 0.*x;

        % Sink/source terms
        points = parameters.points;
        parameters.S = @(x,y,t) (x == points(1,1)).*(y == points(1,2)).*exp(-0.01*t) ...
            + (x == points(2,1)).*(y == points(2,2)).*exp(-0.01*t) ...
            + (x == points(3,1)).*(y == points(3,2)).*exp(-0.01*t);

        % Initial condition
        parameters.f = @(x,y) 0.*x;

        % South boundary condition (y is a dummy variable)
        parameters.bcond(1) = 2;
        parameters.g{1} = @(x,y,t) 0.*x;

        % East boundary condition (x is a dummy variable)
        parameters.bcond(2) = 2;
        parameters.g{2} = @(x,y,t) 0.*y;

        % North boundary condition (y is a dummy variable)
        parameters.bcond(3) = 2;
        parameters.g{3} = @(x,y,t) 0.*x;

        % West boundary condition (x is a dummy variable)
        parameters.bcond(4) = 2;
        parameters.g{4} = @(x,y,t) 0.*y;

        % Add additional grid properties for discretisation
        grid = setGridProperties(grid,parameters);

        % Fine-scale FVM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        sols_c_FVM = FVM(grid,parameters);
        timerFVM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        % DM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        [sols_c_DM,sols_C_DM] = DM(grid,parameters);
        timerDM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

    case 3
        % Time-stepping parameters
        parameters.T = 100; % Stopping time
        parameters.K = 10000; % No. of time steps
        store = parameters.K*[1/5,1/2,1];

        % Heaviside functions describing transition layer, cut-off wall,
        % and aquifer layers of the domain
        Htl = @(x) x < 2;
        Hcw = @(x) (x>=2) & (x<3);
        Ha = @(x) x >= 3;

        n = [0.5,0.4,0.5];

        % Retardation factor
        R = n .* [1,15,1];
        parameters.R = @(x,y) R(1).*Htl(x) + R(2).*Hcw(x) + R(3).*Ha(x);

        % Diffusivity coefficient (tensor)
        Dx = n .* [1.5e-9,5e-10,1.5e-9] * 31536000;
        Dy = n .* [1.2e-9,4e-10,1.2e-9] * 31536000;
        parameters.D = @(x,y) [Dx(1).*Htl(x) + Dx(2).*Hcw(x) + Dx(3).*Ha(x),0;0,Dy(1).*Htl(x) + Dy(2).*Hcw(x) + Dy(3).*Ha(x)];

        % Velocity coefficient (vector)
        v = [2e-9,2e-9,2e-9] * 31536000;
        parameters.v = @(x,y) [v(1).*Htl(x) + v(2).*Hcw(x) + v(3).*Ha(x);0];

        % Reaction decay rate coefficient
        lam = n .* [log(2)/100,log(2)/100,log(2)/100];
        parameters.mu = @(x,y) lam(1).*Htl(x) + lam(2).*Hcw(x) + lam(3).*Ha(x);

        % Sink/source terms
        parameters.S = @(x,y,t) 0.*x;

        % Initial condition
        parameters.f = @(x,y) 0.*x;

        % South boundary condition (y is a dummy variable)
        parameters.bcond(1) = 2;
        parameters.g{1} = @(x,y,t) 0.*x;

        % East boundary condition (x is a dummy variable)
        parameters.bcond(2) = 1;
        parameters.g{2} = @(x,y,t) 0.*y;

        % North boundary condition (y is a dummy variable)
        parameters.bcond(3) = 2;
        parameters.g{3} = @(x,y,t) 0.*x;

        % West boundary condition (x is a dummy variable)
        parameters.bcond(4) = 1;
        parameters.g{4} = @(x,y,t) exp(-(y-5).^2 / 2);

        % Add additional grid properties for discretisation
        grid = setGridProperties(grid,parameters);

        % Fine-scale FVM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        sols_c_FVM = FVM(grid,parameters);
        timerFVM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        % DM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        [sols_c_DM,sols_C_DM] = DM(grid,parameters);
        timerDM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

    case 4
        % Time-stepping parameters
        parameters.T = 100; % Stopping time
        parameters.K = 10000; % No. of time steps
        store = parameters.K*[1/10,1/2,1];

        % Retardation factor
        parameters.R = @(x,y) transportCoefficients(1,xLines,modMask,x,y);

        % Diffusivity coefficient (tensor)
        parameters.D = @(x,y) transportCoefficients(2,xLines,modMask,x,y);

        % Velocity coefficient (vector)
        parameters.v = @(x,y) transportCoefficients(3,xLines,modMask,x,y);

        % Reaction decay rate coefficient
        parameters.mu = @(x,y) transportCoefficients(4,xLines,modMask,x,y);

        % Sink/source terms
        parameters.S = @(x,y,t) 0.*x;

        % Initial condition
        parameters.f = @(x,y) 0.*x;

        % South boundary condition (y is a dummy variable)
        parameters.bcond(1) = 2;
        parameters.g{1} = @(x,y,t) 0.*x;

        % East boundary condition (x is a dummy variable)
        parameters.bcond(2) = 1;
        parameters.g{2} = @(x,y,t) 0.*y;

        % North boundary condition (y is a dummy variable)
        parameters.bcond(3) = 2;
        parameters.g{3} = @(x,y,t) 0.*x;

        % West boundary condition (x is a dummy variable)
        parameters.bcond(4) = 1;
        parameters.g{4} = @(x,y,t) exp(-(y-5).^2 / 6);

        % Add additional grid properties for discretisation
        grid = setGridProperties(grid,parameters);

        % Fine-scale FVM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        sols_c_FVM = FVM(grid,parameters);
        timerFVM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        % DM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        [sols_c_DM,sols_C_DM] = DM(grid,parameters);
        timerDM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

    case 5
        % Time-stepping parameters
        parameters.T = 20; % Stopping time
        parameters.K = 2000; % No. of time steps
        store = parameters.K*[1/20,1/2,1];

        % Retardation factor
        parameters.R = @(x,y) transportCoefficients2(1,circles,radii,x,y);

        % Diffusivity coefficient (tensor)
        parameters.D = @(x,y) transportCoefficients2(2,circles,radii,x,y);

        % Velocity coefficient (vector)
        parameters.v = @(x,y) transportCoefficients2(3,circles,radii,x,y);

        % Reaction decay rate coefficient
        parameters.mu = @(x,y) transportCoefficients2(4,circles,radii,x,y);

        % Sink/source terms
        parameters.S = @(x,y,t) 0.*x;

        % Initial condition
        parameters.f = @(x,y) 0.*x;

        % South boundary condition (y is a dummy variable)
        parameters.bcond(1) = 2;
        parameters.g{1} = @(x,y,t) 0.*x;

        % East boundary condition (x is a dummy variable)
        parameters.bcond(2) = 1;
        parameters.g{2} = @(x,y,t) 0.*y;

        % North boundary condition (y is a dummy variable)
        parameters.bcond(3) = 2;
        parameters.g{3} = @(x,y,t) 0.*x;

        % West boundary condition (x is a dummy variable)
        parameters.bcond(4) = 1;
        parameters.g{4} = @(x,y,t) exp(-5 .* (y-0.5).^2);

        % Add additional grid properties for discretisation
        grid = setGridProperties(grid,parameters);

        % Fine-scale FVM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        sols_c_FVM = FVM(grid,parameters);
        timerFVM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        % DM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        [sols_c_DM,sols_C_DM] = DM(grid,parameters);
        timerDM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

    case 6
        % Time-stepping parameters
        parameters.T = 20; % Stopping time
        parameters.K = 2000; % No. of time steps
        store = parameters.K*[1/20,1/2,1];

        % Retardation factor
        parameters.R = @(x,y) transportCoefficients2(1,circles,radii,x,y);

        % Diffusivity coefficient (tensor)
        parameters.D = @(x,y) transportCoefficients2(2,circles,radii,x,y);

        % Velocity coefficient (vector)
        parameters.v = @(x,y) transportCoefficients2(3,circles,radii,x,y);

        % Reaction decay rate coefficient
        parameters.mu = @(x,y) transportCoefficients2(4,circles,radii,x,y);

        % Sink/source terms
        parameters.S = @(x,y,t) 0.*x;

        % Initial condition
        parameters.f = @(x,y) 0.*x;

        % South boundary condition (y is a dummy variable)
        parameters.bcond(1) = 2;
        parameters.g{1} = @(x,y,t) 0.*x;

        % East boundary condition (x is a dummy variable)
        parameters.bcond(2) = 1;
        parameters.g{2} = @(x,y,t) 0.*y;

        % North boundary condition (y is a dummy variable)
        parameters.bcond(3) = 2;
        parameters.g{3} = @(x,y,t) 0.*x;

        % West boundary condition (x is a dummy variable)
        parameters.bcond(4) = 1;
        parameters.g{4} = @(x,y,t) exp(-5 .* (y-0.5).^2);

        % Add additional grid properties for discretisation
        grid = setGridProperties(grid,parameters);

        % Fine-scale FVM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        sols_c_FVM = FVM(grid,parameters);
        timerFVM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        % DM Approximation
        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;

        tic
        [sols_c_DM,sols_C_DM] = DM2(grid,parameters);
        timerDM = toc;

        tic
        dummy = (10/3 + 1/7)*(2/3);
        dummy = toc;
end

%% Save solution and timing results
if parameters.saveInfo
    save(['Data/Test_Case_',num2str(parameters.testCase),'_',num2str(parameters.numStrips),'_strips.mat'],'grid','parameters','sols_c_FVM','timerFVM','sols_c_DM','sols_C_DM','timerDM','-v7.3');
end

%% Figures
if makePlots
    plotTime = store(3); % Solution at time t=(plotTime)*tau
    nodes = grid.nodes(:,1:2);
    elmnts = grid.elmnts(:,1:3);
    coarseNodes = nodes(grid.coarseNodes,1:2);
    absDiff = abs(sols_c_FVM(:,plotTime) - sols_c_DM(:,plotTime));

    stopX = parameters.xL;
    stopY = parameters.yH;

    cols = 40;
    cmap = viridis(2);

    fig1 = figure;
    patch('Faces',elmnts(:,1:3),'Vertices',nodes(:,1:2),'FaceVertexCData',sols_c_FVM(:,plotTime),'FaceColor','Interp','EdgeAlpha',0)
    colormap(viridis(cols))
    c = colorbar;
    xlim([0,stopX])
    ylim([0,stopY])
    val = max(max(sols_c_FVM(:,plotTime)),1);
    clim([0,val])
    set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    if abs(val-1) < 1e-14
        set(c,'YTick',0.0:0.1:1.0)
    end
    set(gca,'layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    if parameters.testCase == 3
        set(gca,'XTick',[0,2,3,6,9,13])
    end
    xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
    ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
    box on

    fig2 = figure;
    hold on
    if parameters.testCase < 6
        coarseSol = [coarseNodes,sols_C_DM(:,plotTime)];
    else
        coarseSol = zeros(0,3);
        for p = 1:parameters.numStrips
            coarseID = grid.doubleUpCols{p};
            rIndex = grid.subgrid{p}.rIndex;
            coarseSol(end+1:end+length(coarseID),:) = [grid.nodes(rIndex(coarseID),1:2),sols_C_DM(coarseID,plotTime)];
        end
        coarseSol = unique(coarseSol,'rows');
    end
    inc = (max(coarseSol(:,3)) - min(coarseSol(:,3)))/(cols-1);
    cmapCoarse = viridis(cols);
    for i = 1:cols
        if i == 1
            idx = (coarseSol(:,3) <= i*inc) & (coarseSol(:,3) >= (i-1)*inc - 0.1);
        else
            idx = (coarseSol(:,3) <= i*inc) & (coarseSol(:,3) >= (i-1)*inc);
        end
        plot3(coarseSol(idx,1),coarseSol(idx,2),coarseSol(idx,3),'o','markersize',5,'color',cmapCoarse(i,:),'markerfacecolor',cmapCoarse(i,:))
    end
    view(2)
    colormap(viridis(cols))
    c = colorbar;
    xlim([0,stopX])
    ylim([0,stopY])
    zlim([0,1])
    val = max(max(sols_c_DM(:,plotTime)),1);
    clim([0,val])
    set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    if abs(val-1) < 1e-14
        set(c,'YTick',0.0:0.1:1.0)
    end
    set(gca,'layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    if parameters.testCase == 3
        set(gca,'XTick',[0,2,3,6,9,13])
    end
    xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
    ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
    box on

    fig3 = figure;
    patch('Faces',elmnts(:,1:3),'Vertices',nodes(:,1:2),'FaceVertexCData',sols_c_DM(:,plotTime),'FaceColor','Interp','EdgeAlpha',0)
    colormap(viridis(cols))
    c = colorbar;
    xlim([0,stopX])
    ylim([0,stopY])
    val = max(max(sols_c_DM(:,plotTime)),1);
    clim([0,val])
    set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    if abs(val-1) < 1e-14
        set(c,'YTick',0.0:0.1:1.0)
    end
    set(gca,'layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    if parameters.testCase == 3
        set(gca,'XTick',[0,2,3,6,9,13])
    end
    xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
    ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
    box on

    fig4 = figure;
    patch('Faces',elmnts(:,1:3),'Vertices',nodes(:,1:2),'FaceVertexCData',absDiff,'FaceColor','Interp','EdgeAlpha',0)
    if parameters.testCase == 3
        xline(parameters.lines{2}(1,1),'color','r','linestyle','--','linewidth',1)
        xline(parameters.lines{3}(1,1),'color','r','linestyle','--','linewidth',1)
    elseif parameters.testCase == 4
        lines = parameters.lines;
        for i = 2:length(lines)-1
            xline(lines{i}(1,1),'color','r','linestyle','--','linewidth',1)
        end
    end
    colormap(viridis(cols+180))
    c = colorbar;
    xlim([0,stopX])
    ylim([0,stopY])
    set(gca,'layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    if parameters.testCase == 3
        set(gca,'XTick',[0,2,3,6,9,13])
    end
    set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
    ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
    box on

    pos = get(0,'screensize');
    pos = pos(3)/4 - 10;

    p1 = 5;
    p2 = p1 + pos + 10;
    p3 = p2 + pos + 10;
    p4 = p3 + pos + 10;

    set(fig1,'position',[p1,300,pos,pos])
    set(fig2,'position',[p2,300,pos,pos])
    set(fig3,'position',[p3,300,pos,pos])
    set(fig4,'position',[p4,300,pos,pos])
end
