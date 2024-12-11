% This runner file is intended to be executed when lines 1-12 of run.m
% commented out. WARNING: Running the code as-is will require at least 32GB
% of RAM. If there is no solution data present, the runNew variable must be
% set to true. Running this file will generate an entirely new set of data
% if the runNew variable is set to true, which will take a considerable
% amount of time. Running this file will also generate a number of figures,
% creating .eps copies in the Figures folder (above, in the parent folder).

clearvars
close all
clc

runNew = false;
runCase6 = false;

cols = 20;
cmap = viridis(2);

% These values correspond to the minimum and maximum of time values for
% each test case and may need to be adjusted depending on hardware setup,
% MATLAB version, etc. in order to properly display a manuscript-quality
% figure.
minMax = [45,55;650,960;215,285;240,340;250,390];
yTicks = {45:55,650:25:960,215:10:285,240:10:340,250:10:390};

storeTimes = [
              1/10,1/2,1
              1/10,1/2,1
               1/5,1/2,1
              1/10,1/2,1
              1/20,1/2,1
             ];

maxCases = 5;

maxStrips = 80;

% You'll note that we omit case 6 here as it is meant as a proof of concept
% example. We also need to account for the fact that numStrips starts at 2,
% rather than 1, so maxStrips is decremented here to ensure the correct
% array size for the information storage.
timers = zeros(maxCases-1,2,maxStrips-1);
absDiffs = zeros(maxCases-1,maxStrips-1);

if runNew
    for testCase = 1:maxCases
        for numStrips = 2:maxStrips
            % Run through all numbers of strips to collect runtime and abs.
            % diff. data.
            if testCase == 5
                parameters.testCase = testCase;
                parameters.numStrips = numStrips;

                run('../run.m')

                timers(testCase,:,numStrips-1) = [timerFVM,timerDM];
                absDiffs(testCase,numStrips-1) = max(max(abs(sols_c_FVM - sols_c_DM)));

                clearvars -except runNew runCase6 cols cmap minMax startCase maxCases maxStrips timers absDiffs testCase numStrips yTicks storeTimes
            else
                if numStrips <= 40
                    parameters.testCase = testCase;
                    parameters.numStrips = numStrips;

                    run('../run.m')

                    timers(testCase,:,numStrips-1) = [timerFVM,timerDM];
                    absDiffs(testCase,numStrips-1) = max(max(abs(sols_c_FVM - sols_c_DM)));

                    clearvars -except runNew runCase6 cols cmap minMax startCase maxCases maxStrips timers absDiffs testCase numStrips yTicks storeTimes
                end
            end
        end
    end
    save('timers_and_differences.mat','timers','absDiffs')
else
    load('timers_and_differences.mat','timers')
end

for testCase = 1:maxCases
    load(['Test_Case_',num2str(testCase),'_13_strips.mat'])

    solTime = parameters.K*storeTimes(testCase,:) + 1;

    absDiff = abs(sols_c_FVM(:,end) - sols_c_DM(:,end));

    nodes = grid.nodes(:,1:2);
    elmnts = grid.elmnts(:,1:3);
    coarseNodes = nodes(grid.coarseNodes,1:2);

    stopX = parameters.xL;
    stopY = parameters.yH;
    for n = 1:3
        figure
        patch('Faces',elmnts(:,1:3),'Vertices',nodes(:,1:2),'FaceVertexCData',sols_c_FVM(:,solTime(n)),'FaceColor','Interp','EdgeAlpha',0)
        colormap(viridis(cols))
        c = colorbar;
        xlim([0,stopX])
        ylim([0,stopY])
        val = max(max(sols_c_FVM(:,solTime(n))),1);
        clim([0,val])
        set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if abs(val-1) < 1e-14
            set(c,'YTick',0.0:0.1:1.0)
        end
        set(gcf,'position',[300,100,650,600])
        set(gca,'Color','none','layer','top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if testCase == 3
            set(gca,'XTick',[0,2,3,6,9,13])
        end
        xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
        ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
        box on
        exportgraphics(gca,['../Figures/test_case_',num2str(testCase),'_fine_FVM_',num2str(n),'.eps'],'ContentType','vector','BackgroundColor','none')
        close(1)

        figure
        hold on
        coarseSol = [coarseNodes,sols_C_DM(:,solTime(n))];
        % Solution will be plotted at coarse node points as a circle marker
        % with radius:
        rad = 1e-2;
        % tol*rad is very small, so the distance between plotted point
        % centroids will generally be > tol*rad and most/all points will be
        % included in the plot.
        tol = 1e-10;
        plotCoarse(coarseSol,rad,tol)
        colormap(viridis(cols))
        c = colorbar;
        xlim([0,stopX])
        ylim([0,stopY])
        zlim([0,1])
        val = max(max(sols_c_DM(:,solTime(n))),1);
        clim([0,val])
        set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if abs(val-1) < 1e-14
            set(c,'YTick',0.0:0.1:1.0)
        end
        set(gcf,'position',[300,100,650,600])
        set(gca,'Color','none','layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if parameters.testCase == 3
            set(gca,'XTick',[0,2,3,6,9,13])
        end
        xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
        ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
        box on
        exportgraphics(gca,['../Figures/test_case_',num2str(testCase),'_coarse_DM_',num2str(n),'.eps'],'ContentType','vector','BackgroundColor','none')
        close(1)

        figure
        patch('Faces',elmnts(:,1:3),'Vertices',nodes(:,1:2),'FaceVertexCData',sols_c_DM(:,solTime(n)),'FaceColor','Interp','EdgeAlpha',0)
        colormap(viridis(cols))
        c = colorbar;
        xlim([0,stopX])
        ylim([0,stopY])
        val = max(max(sols_c_DM(:,solTime(n))),1);
        clim([0,val])
        set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if abs(val-1) < 1e-14
            set(c,'YTick',0.0:0.1:1.0)
        end
        set(gcf,'position',[300,100,650,600])
        set(gca,'Color','none','layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if testCase == 3
            set(gca,'XTick',[0,2,3,6,9,13])
        end
        xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
        ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
        box on
        exportgraphics(gca,['../Figures/test_case_',num2str(testCase),'_fine_DM_',num2str(n),'.eps'],'ContentType','vector','BackgroundColor','none')
        close(1)
    end

    figure;
    patch('Faces',elmnts(:,1:3),'Vertices',nodes(:,1:2),'FaceVertexCData',absDiff,'FaceColor','Interp','EdgeAlpha',0)
    colormap(viridis(cols+9980))
    c = colorbar;
    xlim([0,stopX])
    ylim([0,stopY])
    set(gcf,'position',[300,100,650,600])
    set(gca,'Color','none','layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    if testCase == 3
        set(gca,'XTick',[0,2,3,6,9,13])
    end
    set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
    ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
    box on
    exportgraphics(gca,['../Figures/test_case_',num2str(testCase),'_diff.eps'],'ContentType','vector','BackgroundColor','none')
    close(1)

    if testCase == 5
        times = reshape(timers(testCase,1,1:maxStrips-1),[],1);
        timerMeanFVM = mean(times);
        timerQuantilesFVM = quantile(times,[0,1],1);

        times = reshape(timers(testCase,2,1:maxStrips-1),[],1);

        quantPoints = [2,maxStrips,maxStrips,2];

        tPoints = 2:maxStrips;

        tTicks = 2:6:maxStrips;
    else
        times = reshape(timers(testCase,1,1:17),[],1);
        timerMeanFVM = mean(times);
        timerQuantilesFVM = quantile(times,[0,1],1);

        times = reshape(timers(testCase,2,1:17),[],1);

        quantPoints = [2,18,18,2];

        tPoints = 2:18;

        tTicks = 2:18;
    end

    figure;
    hold on;
    fill(quantPoints,timerQuantilesFVM([1,1,2,2]),cmap(1,:),'FaceAlpha',0.25,'EdgeColor','none','handlevisibility','off')
    plot(tPoints,timerMeanFVM + zeros(1,length(tPoints)),'color',cmap(1,:),'linewidth',8)
    plot(tPoints,times,'color',cmap(2,:),'linewidth',8)
    xlim([tPoints(1),tPoints(end)])
    ylim([minMax(testCase,1),minMax(testCase,2)])
    set(gcf,'position',[300,100,650,600])
    set(gca,'Color','none','layer','top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex','Clipping','on','XTick',tTicks,'XTickLabelRotation',90,'YTick',yTicks{testCase})%,'ClippingStyle','rectangle'
    xlabel('No. Strips','fontsize',22,'fontweight','bold','interpreter','latex')
    ylabel('Computation Time [s]','fontsize',24,'fontweight','bold','interpreter','latex')
    legend('FVM','DGMM','fontsize',20,'fontweight','bold','interpreter','latex','location','best','color','none')
    box on
    exportgraphics(gca,['../Figures/test_case_',num2str(testCase),'_timers.eps'],'ContentType','vector','BackgroundColor','none')
    close(1)
end

figure
rectangle('position',[0,0,13,10],'facecolor',cmap(2,:),'edgecolor','none');
rectangle('position',[2,0,1,10],'facecolor',cmap(1,:),'edgecolor','none');
set(gcf,'position',[300,100,650,600])
set(gca,'Color','none','layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex','XTick',[0,2,3,6,9,13],'TickLength',[0,0])
xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
xlim([0,13])
ylim([0,10])
box on
pbaspect(gca,[4,1.5,1])
exportgraphics(gca,'../Figures/test_case_3_domain.eps','ContentType','vector','BackgroundColor','none')
close(1)
clearvars -except runNew runCase6 cols cmap minMax maxCases maxStrips timers absDiffs testCase numStrips

load('Test_Case_4_13_strips.mat','parameters')
load('hetDomainMask.mat','modMask')
plotDomain(cmap(1:2,:),parameters,modMask)
set(gcf,'position',[300,100,650,600])
set(gca,'Color','none','layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex','TickLength',[0,0])
xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
box on
pbaspect(gca,[4,1.5,1])
exportgraphics(gca,'../Figures/test_case_4_domain.eps','ContentType','vector','BackgroundColor','none')
close(1)
clearvars -except runNew runCase6 cols cmap minMax maxCases maxStrips timers absDiffs testCase numStrips

load('Test_Case_5_13_strips.mat','parameters')
load('hetDomain.mat','circles','radii')
plotDomain2(cmap(1:2,:),parameters,circles,radii)
set(gcf,'position',[300,100,650,600])
set(gca,'Color','none','layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex','TickLength',[0,0])
xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
box on
pbaspect(gca,[4,1.5,1])
exportgraphics(gca,'../Figures/test_case_5_6_domain.eps','ContentType','vector','BackgroundColor','none')
close(1)
clearvars -except runNew runCase6 cols cmap

load('timers_and_differences','absDiffs')
numStrips = 40;
minMax = [0,1e-12];
absDiffMean = mean(absDiffs(:,1:numStrips-1),1);
absDiffQuantiles = quantile(absDiffs(:,1:numStrips-1),[0,1],1);
figure;
hold on;
fill([2:numStrips,numStrips:-1:2],[absDiffQuantiles(1,:),absDiffQuantiles(2,end:-1:1)],cmap(2,:),'FaceAlpha',0.25,'EdgeColor','none','handlevisibility','off')
plot(2:numStrips,absDiffMean,'color',cmap(2,:),'linewidth',8)
xlim([2,numStrips])
ylim(minMax)
set(gcf,'position',[300,100,1300,600])
set(gca,'Color','none','layer','top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex','Clipping','on','XTick',2:2:numStrips,'YScale','log')%,'ClippingStyle','rectangle'
xlabel('No. Strips','fontsize',22,'fontweight','bold','interpreter','latex')
ylabel('$$\max\limits_{i,k} |c_i^{(k)} - \widetilde{c}_i^{(k)}|$$','fontsize',24,'fontweight','bold','interpreter','latex')
box on
exportgraphics(gca,'../Figures/maximum_absolute_difference_quantiles.eps','ContentType','vector','BackgroundColor','none')

clearvars -except runCase6 cols

if runCase6
    parameters.testCase = 6;
    parameters.numStrips = 500;

    run('../run.m')
else
    load('Test_Case_6_500_strips.mat','parameters','grid','sols_C_DM','sols_c_DM')
end

stopX = parameters.xL;
stopY = parameters.yH;

figure
hold on
coarseSol = zeros(0,3);
for p = 1:parameters.numStrips
    coarseID = grid.doubleUpCols{p};
    rIndex = grid.subgrid{p}.rIndex;
    coarseSol(end+1:end+length(coarseID),:) = [grid.nodes(rIndex(coarseID),:),sols_C_DM(coarseID,end)];
end
coarseSol = unique(coarseSol,'rows');
% If the number of points is very large, then choose a tolerance such that
% plotted point centroids must be > tol*rad to be included in the plot (the
% points should only slightly overlap, if at all; points that are too close
% are not entirely necessary in a very dense plot and may be excluded as
% they wont contribute anything, visually, to the plot.)
rad = 1e-2;
tol = 0.9;
plotCoarse(coarseSol,rad,tol)
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
set(gcf,'position',[300,100,1950,600])
set(gca,'Color','none','layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
box on
exportgraphics(gca,'../Figures/test_case_6_coarse_DM_3.eps','ContentType','vector','BackgroundColor','none')
close(1)

clearvars
close all
clc
