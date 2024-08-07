%% Grid construction
clearvars
close all
clc

%% Pick test case, set no. of strips for DM method
parameters.testCase = 3;
parameters.numStrips = 8; % Number of strips to partition the domain into
parameters.newGrid = false; % Generate a new grid using GMSH
parameters.saveInfo = false;

%% Construct a grid over a rectangular domain [0,Lx] x [0,Ly]
switch parameters.testCase
    case 0
        Lx = 1;
        Ly = 1;
        parameters.Lx = Lx;
        parameters.Ly = Ly;
        parameters.ref = 0.0750;
        parameters.lines = {[0,0;0,Ly],[Lx,0;Lx,Ly]};
        parameters.points = [];
    case 1
        Lx = 1;
        Ly = 1;
        parameters.Lx = Lx;
        parameters.Ly = Ly;
        parameters.ref = 0.0115;%0.035;%0.0115; % Mesh refinement parameter (smaller = finer grid)
        parameters.lines = {[0,0;0,Ly],[Lx,0;Lx,Ly]};
        parameters.points = [];
    case 2
        Lx = 30;
        Ly = 20;
        parameters.Lx = Lx;
        parameters.Ly = Ly;
        parameters.ref = 0.2825;%0.8;%0.2825; % Mesh refinement parameter (smaller = finer grid)
        parameters.lines = {[0,0;0,Ly],[Lx,0;Lx,Ly]};
        parameters.points = [[5,7.5];[5,12.5];[10,10]];
    case 3
        Lx = 13;
        Ly = 10;
        parameters.Lx = Lx;
        parameters.Ly = Ly;
        parameters.ref = 0.1315; % Mesh refinement parameter (smaller = finer grid)
        parameters.lines = {[0,0;0,Ly],[2,0;2,Ly],[3,0;3,Ly],[Lx,0;Lx,Ly]};
        parameters.points = [];
end

parameters.gmshPath = 'gmsh '; % GMSH path on your workstation

grid = modGrid(parameters);

%% Boundary/initial conditions, time-stepping, and transport coefficients
switch parameters.testCase
    case 0
        % Time-stepping parameters
        parameters.T = 1; % Stopping time
        parameters.K = 1000; % No. of time steps
        parameters.store = parameters.K*[1/10,1/2,1];

        % Retardation factor
        parameters.R = @(x,y) ones(size(x));

        % Diffusivity coefficient
        parameters.D = @(x,y) [1,0;0,1];

        % Velocity coefficient (vector)
        parameters.v = @(x,y) [0;-1];

        % Reaction decay rate coefficient
        parameters.mu = @(x,y) zeros(size(x));

        % Sink/source terms
        parameters.S = @(x,y,t) zeros(size(x));

        % Initial condition
        parameters.f = @(x,y) zeros(size(x));

        % South boundary condition (y is a dummy variable)
        parameters.bcond(1) = 2;
        parameters.g{1} = @(x,y,t) zeros(size(x));

        % East boundary condition (x is a dummy variable)
        parameters.bcond(2) = 2;
        parameters.g{2} = @(x,y,t) zeros(size(y));

        % North boundary condition (y is a dummy variable)
        parameters.bcond(3) = 2;
        parameters.g{3} = @(x,y,t) ones(size(x));

        % West boundary condition (x is a dummy variable)
        parameters.bcond(4) = 2;
        parameters.g{4} = @(x,y,t) zeros(size(y));

    case 1
        % Time-stepping parameters
        parameters.T = 20; % Stopping time
        parameters.K = 2000; % No. of time steps
        parameters.store = parameters.K*[1/10,1/2,1];

        % Retardation factor
        parameters.R = @(x,y) 50 + zeros(size(x));

        % Diffusivity coefficient
        parameters.D = @(x,y) [1,-0.1;-0.1,1];

        % Velocity coefficient (vector)
        parameters.v = @(x,y) [1;-0.01];

        % Reaction decay rate coefficient
        parameters.mu = @(x,y) 0.01 + zeros(size(x));

        % Sink/source terms
        points = parameters.points;
        parameters.S = @(x,y,t) zeros(size(x));

        % Initial condition
        parameters.f = @(x,y) zeros(size(x));

        % South boundary condition (y is a dummy variable)
        parameters.bcond(1) = 3;
        parameters.g{1} = @(x,y,t) zeros(size(x));

        % East boundary condition (x is a dummy variable)
        parameters.bcond(2) = 2;
        parameters.g{2} = @(x,y,t) zeros(size(y));

        % North boundary condition (y is a dummy variable)
        parameters.bcond(3) = 1;
        parameters.g{3} = @(x,y,t) exp(-(4*x).^2);

        % West boundary condition (x is a dummy variable)
        parameters.bcond(4) = 3;
        parameters.g{4} = @(x,y,t) zeros(size(y));

    case 2
        % Time-stepping parameters
        parameters.T = 300; % Stopping time
        parameters.K = 3000;%30000; % No. of time steps
        parameters.store = parameters.K*[1/10,1/2,1];

        % Retardation factor
        parameters.R = @(x,y) 5.3 + zeros(size(x));

        % Diffusivity coefficient
        parameters.D = @(x,y) [0.1,0;0,0.03];

        % Velocity coefficient (vector)
        parameters.v = @(x,y) [0.1;0];

        % Reaction decay rate coefficient
        parameters.mu = @(x,y) 0.01 + zeros(size(x));

        % Sink/source terms
        points = parameters.points;
        parameters.S = @(x,y,t) (x == points(1,1)).*(y == points(1,2)).*exp(-0.01*t) ...
                              + (x == points(2,1)).*(y == points(2,2)).*exp(-0.01*t) ...
                              + (x == points(3,1)).*(y == points(3,2)).*exp(-0.01*t);

        % Initial condition
        parameters.f = @(x,y) zeros(size(x));

        % South boundary condition (y is a dummy variable)
        parameters.bcond(1) = 2;
        parameters.g{1} = @(x,y,t) zeros(size(x));

        % East boundary condition (x is a dummy variable)
        parameters.bcond(2) = 2;
        parameters.g{2} = @(x,y,t) zeros(size(y));

        % North boundary condition (y is a dummy variable)
        parameters.bcond(3) = 2;
        parameters.g{3} = @(x,y,t) zeros(size(x));

        % West boundary condition (x is a dummy variable)
        parameters.bcond(4) = 2;
        parameters.g{4} = @(x,y,t) zeros(size(y));

    case 3
        % Time-stepping parameters
        parameters.T = 100; % Stopping time
        parameters.K = 10000; % No. of time steps
        parameters.store = parameters.K*[1/5,1/2,1];

        % Heaviside functions describing transition layer, cut-off wall,
        % and aquifer layers of the domain
        Htl = @(x) x < 2;
        Hcw = @(x) (x>=2) & (x<3);
        Ha = @(x) x >= 3;

        n = [0.5,0.4,0.5];

        % Retardation factor
        R = n .* [1,15,1];
        parameters.R = @(x,y) R(1)*Htl(x) + R(2)*Hcw(x) + R(3)*Ha(x);

        % Diffusivity coefficient
        Dx = n .* [1.5e-9,5e-10,1.5e-9] * 31536000;
        Dy = n .* [1.2e-9,4e-10,1.2e-9] * 31536000;
        parameters.D = @(x,y) [Dx(1)*Htl(x) + Dx(2)*Hcw(x) + Dx(3)*Ha(x),0;0,Dy(1)*Htl(x) + Dy(2)*Hcw(x) + Dy(3)*Ha(x)];

        % Velocity coefficient (vector)
        v = [2e-9,2e-9,2e-9] * 31536000;
        parameters.v = @(x,y) [v(1)*Htl(x) + v(2)*Hcw(x) + v(3)*Ha(x);0];

        % Reaction decay rate coefficient
        lam = n .* [log(2)/100,log(2)/100,log(2)/100];
        parameters.mu = @(x,y) lam(1)*Htl(x) + lam(2)*Hcw(x) + lam(3)*Ha(x);

        % Sink/source terms
        parameters.S = @(x,y,t) zeros(size(x));

        % Initial condition
        parameters.f = @(x,y) zeros(size(x));

        % South boundary condition (y is a dummy variable)
        parameters.bcond(1) = 2;
        parameters.g{1} = @(x,y,t) zeros(size(x));

        % East boundary condition (x is a dummy variable)
        parameters.bcond(2) = 1;
        parameters.g{2} = @(x,y,t) zeros(size(y));

        % North boundary condition (y is a dummy variable)
        parameters.bcond(3) = 2;
        parameters.g{3} = @(x,y,t) zeros(size(x));

        % West boundary condition (x is a dummy variable)
        parameters.bcond(4) = 1;
        parameters.g{4} = @(x,y,t) exp(-(y-5).^2 / 2);

end

% Add additional grid properties for discretisation
grid = setGridProperties(grid,parameters);

%% Fine-scale FVM Approximation
tic
dummy = (10/3 + 1/7)*(2/3);
dummy = toc;

tic
sols_c_FVM = FVM(grid,parameters);
timerFVM = toc;

tic
dummy = (10/3 + 1/7)*(2/3);
dummy = toc;

%% DM Approximation
tic
dummy = (10/3 + 1/7)*(2/3);
dummy = toc;

tic
[sols_c_DM,sols_C_DM] = DM(grid,parameters);
timerDM = toc;

tic
dummy = (10/3 + 1/7)*(2/3);
dummy = toc;
%% Save solution and timing results
if parameters.saveInfo
    save(['Figures/Test_Case_',num2str(parameters.testCase),'.mat'],'grid','parameters','sols_c_FVM','timerFVM','sols_c_DM','sols_C_DM','timerDM')
end

%% Figures
nodes = grid.nodes(:,1:2);
elmnts = grid.elmnts(:,1:3);
coarseNodes = nodes(grid.coarseNodes,1:2);
absDiff = abs(sols_c_FVM(:,end) - sols_c_DM(:,end));

stopX = parameters.Lx;
stopY = parameters.Ly;

cols = 20;
cmap = viridis(2);

fig1 = figure;
patch('Faces',elmnts(:,1:3),'Vertices',nodes(:,1:2),'FaceVertexCData',sols_c_FVM(:,end),'FaceColor','Interp','EdgeAlpha',0)
if parameters.testCase == 3
    xline(parameters.lines{2}(1,1),'color','r','linestyle','--','linewidth',2)
    xline(parameters.lines{3}(1,1),'color','r','linestyle','--','linewidth',2)
end
colormap(viridis(cols))
c = colorbar;
xlim([0,stopX])
ylim([0,stopY])
val = max(max(sols_c_FVM(:,end)),1);
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
scatter(coarseNodes(:,1),coarseNodes(:,2),30,sols_C_DM(:,end),'filled');
colormap(viridis(cols))
c = colorbar;
xlim([0,stopX])
ylim([0,stopY])
val = max(max(sols_c_DM(:,end)),1);
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
patch('Faces',elmnts(:,1:3),'Vertices',nodes(:,1:2),'FaceVertexCData',sols_c_DM(:,end),'FaceColor','Interp','EdgeAlpha',0)
if parameters.testCase == 3
    xline(parameters.lines{2}(1,1),'color','r','linestyle','--','linewidth',2)
    xline(parameters.lines{3}(1,1),'color','r','linestyle','--','linewidth',2)
end
colormap(viridis(cols))
c = colorbar;
xlim([0,stopX])
ylim([0,stopY])
val = max(max(sols_c_DM(:,end)),1);
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
    xline(parameters.lines{2}(1,1),'color','r','linestyle','--','linewidth',2)
    xline(parameters.lines{3}(1,1),'color','r','linestyle','--','linewidth',2)
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
