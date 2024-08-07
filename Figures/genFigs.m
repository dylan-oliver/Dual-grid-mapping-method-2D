clearvars
close all
clc

load('timerInfo.mat')

cols = 20;
cmap = viridis(2);

minMax = [50,66;750,1150;250,340];

for testCase = 1:3

    load(['Test_Case_',num2str(testCase),'.mat'])

    nodes = grid.nodes(:,1:2);
    elmnts = grid.elmnts(:,1:3);
    coarseNodes = nodes(grid.coarseNodes,1:2);
    absDiff = abs(sols_c_FVM(:,end) - sols_c_DM(:,end));

    stopX = parameters.Lx;
    stopY = parameters.Ly;

    for n = 1:3
        figure;
        patch('Faces',elmnts(:,1:3),'Vertices',nodes(:,1:2),'FaceVertexCData',sols_c_FVM(:,n),'FaceColor','Interp','EdgeAlpha',0)
        if testCase == 3
            xline(2,'color','r','linestyle','--','linewidth',2)
            xline(3,'color','r','linestyle','--','linewidth',2)
        end
        colormap(viridis(cols))
        c = colorbar;
        xlim([0,stopX])
        ylim([0,stopY])
        val = max(max(sols_c_FVM(:,n)),1);
        clim([0,val])
        set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if abs(val-1) < 1e-14
            set(c,'YTick',0.0:0.1:1.0)
        end
        set(gcf,'position',[300,100,650,600])
        set(gca,'layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if testCase == 3
            set(gca,'XTick',[0,2,3,6,9,13])
        end
        xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
        ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
        box on
        exportgraphics(gca,['test_case_',num2str(testCase),'_fine_FVM_',num2str(n),'.eps'],'ContentType','vector')

        figure;
        scatter(coarseNodes(:,1),coarseNodes(:,2),30,sols_C_DM(:,n),'filled');
        colormap(viridis(cols))
        c = colorbar;
        xlim([0,stopX])
        ylim([0,stopY])
        val = max(max(sols_c_DM(:,n)),1);
        clim([0,val])
        set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if abs(val-1) < 1e-14
            set(c,'YTick',0.0:0.1:1.0)
        end
        set(gcf,'position',[300,100,650,600])
        set(gca,'layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if testCase == 3
            set(gca,'XTick',[0,2,3,6,9,13])
        end
        xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
        ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
        box on
        exportgraphics(gca,['test_case_',num2str(testCase),'_coarse_DM_',num2str(n),'.eps'],'ContentType','vector')

        figure;
        patch('Faces',elmnts(:,1:3),'Vertices',nodes(:,1:2),'FaceVertexCData',sols_c_DM(:,n),'FaceColor','Interp','EdgeAlpha',0)
        if testCase == 3
            xline(2,'color','r','linestyle','--','linewidth',2)
            xline(3,'color','r','linestyle','--','linewidth',2)
        end
        colormap(viridis(cols))
        c = colorbar;
        xlim([0,stopX])
        ylim([0,stopY])
        val = max(max(sols_c_DM(:,n)),1);
        clim([0,val])
        set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if abs(val-1) < 1e-14
            set(c,'YTick',0.0:0.1:1.0)
        end
        set(gcf,'position',[300,100,650,600])
        set(gca,'layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
        if testCase == 3
            set(gca,'XTick',[0,2,3,6,9,13])
        end
        xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
        ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
        box on
        exportgraphics(gca,['test_case_',num2str(testCase),'_fine_DM_',num2str(n),'.eps'],'ContentType','vector')
    end

    figure;
    patch('Faces',elmnts(:,1:3),'Vertices',nodes(:,1:2),'FaceVertexCData',absDiff,'FaceColor','Interp','EdgeAlpha',0)
    if testCase == 3
        xline(2,'color','r','linestyle','--','linewidth',2)
        xline(3,'color','r','linestyle','--','linewidth',2)
    end
    colormap(viridis(cols+180))
    c = colorbar;
    xlim([0,stopX])
    ylim([0,stopY])
    set(gcf,'position',[300,100,650,600])
    set(gca,'layer', 'top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    if testCase == 3
        set(gca,'XTick',[0,2,3,6,9,13])
    end
    set(c,'fontsize',20,'fontweight','bold','ticklabelinterpreter','latex')
    xlabel('Horizontal Distance [m]','fontsize',22,'fontweight','bold','interpreter','latex')
    ylabel('Depth [m]','fontsize',24,'fontweight','bold','interpreter','latex')
    box on
    exportgraphics(gca,['test_case_',num2str(testCase),'_diff.eps'],'ContentType','vector')

    timerMean = mean(timers(:,1,testCase));
    timerQuantiles = quantile(timers(:,1,testCase),[0,1],1);

    figure;
    hold on;
    fill([2,size(timers,1)+1,size(timers,1)+1,2],timerQuantiles([1,1,2,2]),cmap(1,:),'FaceAlpha',0.25,'EdgeColor','none','handlevisibility','off')
    plot(2:(size(timers,1)+1),mean(timers(:,1,testCase))+zeros(size(timers,1),1),'color',cmap(1,:),'linewidth',8)
    plot(2:(size(timers,1)+1),timers(:,2,testCase),'color',cmap(2,:),'linewidth',8)
    xlim([2,size(timers,1)+1])
    ylim([minMax(testCase,1),minMax(testCase,2)])
    set(gcf,'position',[300,100,650,600])
    set(gca,'layer','top','fontsize',20,'fontweight','bold','ticklabelinterpreter','latex','ClippingStyle','rectangle','XTick',2:20)
    xlabel('No. Strips','fontsize',22,'fontweight','bold','interpreter','latex')
    ylabel('Computation Time [s]','fontsize',24,'fontweight','bold','interpreter','latex')
    legend('FVM','DGMM','fontsize',20,'fontweight','bold','interpreter','latex','location','best')
    box on
    exportgraphics(gca,['test_case_',num2str(testCase),'_timers.eps'],'ContentType','vector')

end
