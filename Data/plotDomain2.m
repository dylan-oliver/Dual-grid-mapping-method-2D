function plotDomain2(cols,parameters,circles,radii)
xL = parameters.xL;
yH = parameters.yH;
N = size(circles,1);
pos = zeros(1,4);
figure
hold on
for i = 1:N
    if i < N
        pos(1:2) = circles(i,:) - radii(i);
        pos(3:4) = 2*radii(i);
        rectangle('position',pos,'curvature',[1,1],'facecolor',cols(1,:),'edgecolor','none');
    else
        rectangle('position',[0,0,xL,yH],'facecolor',cols(2,:),'edgecolor','none');
    end
end
set(gca,'children',flipud(get(gca,'children')))
end