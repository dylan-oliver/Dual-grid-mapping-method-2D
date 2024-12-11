function plotDomain(cols,parameters,mask)
lines = parameters.lines;
xL = parameters.xL;
yH = parameters.yH;
figure
hold on
rectangle('position',[0,0,xL,yH],'facecolor',cols(1,:),'edgecolor','none');
for i = 1:length(lines)-1
    if mask(i)
        pos = [lines{i}(1,1),lines{i}(1,2),lines{i+1}(1,1)-lines{i}(1,1),yH];
        rectangle('position',pos,'facecolor',cols(2,:),'edgecolor','none');
    else
        continue
    end
end
xlim([0,xL])
ylim([0,yH])
end