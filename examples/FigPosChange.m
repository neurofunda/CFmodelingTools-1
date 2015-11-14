close all
clear all
RS=5;

figure,
loadPositionsV1V2
X = rmrs.Vdisplacements(:);
%% displacement in visual distance
% zeros = find(X==0);
% mfd = setdiff(1:length(X), zeros);
% X = X(mfd);
C=0:0.25:20;
[Ns]=histc(X,C);
relativefreqNs = Ns ./ sum(Ns);
b(1) = stairs(C,relativefreqNs);
hold on
% X = rsrs.Vdisplacements(:);
% zeros = find(X==0);
% mfd = setdiff(1:length(X), zeros);
% X = X(mfd);
% C=0:0.25:20;
% [Ns]=histc(X,C);
% relativefreqNs = Ns ./ sum(Ns);
%b(2) = bar(C,relativefreqNs,'histc');
set(gca, 'FontSize', 14);
set(gca,'LineWidth',1)
set(gcf, 'color', 'w');
axis square
title('rmrs visuotopic shifts');
xlabel('distance (deg)','FontSize', 14);
ylabel('relative frequency','FontSize', 14);
xlim([0 20]);
b = findobj(gca,'Type','patch');
set(b(1),'FaceColor', 'k','EdgeColor', 'k','facealpha',0.8,'edgealpha',0);
% set(b(2),'FaceColor', 'g','EdgeColor', 'g','facealpha',0.2,'edgealpha',0);

plot2svg('rmrsVShift.svg');

%% displacement in cortical distance
figure;
loadSurrogatePositions
X = rmrs.Cdisplacements(:);
% zeros = find(X==0);
% mfd = setdiff(1:length(X), zeros);
% X = X(mfd);
C=0:1:50;
[Ns]=histc(X,C);
relativefreqNs = Ns ./ sum(Ns);
b(1) = bar(C,relativefreqNs,'histc');
hold on
loadPositionsV1V2
X = rmrs.Cdisplacements(:);
% zeros = find(X==0);
% mfd = setdiff(1:length(X), zeros);
% X = X(mfd);
C=0:1:50;
[Ns]=histc(X,C);
relativefreqNs = Ns ./ sum(Ns);
b(2) = bar(C,relativefreqNs,'histc');
set(gca, 'FontSize', 14);
set(gca,'LineWidth',1)
set(gcf, 'color', 'w');
axis square
title('rmrs cortical shifts');
xlabel('distance(mm)','FontSize', 14);
ylabel('relative frequency','FontSize', 14);
xlim([0 50]);
b = findobj(gca,'Type','patch');
set(b(1),'FaceColor', 'k','EdgeColor', 'k','facealpha',0.5,'edgealpha',0);
set(b(2),'FaceColor', 'k','EdgeColor', 'k','facealpha',0.7,'edgealpha',0);
plot2svg('rmrsCShift.svg');

%% EV  vs displacement
R=5;
    loadPositionsV1V3
    x = cat(2,rm.sigma_L,rm.sigma_R);
    y = rmrs.Cdisplacements;
    w = cat(2,cell2mat(rs.cVE_L(:)),cell2mat(rs.cVE_R(:)));     
    X = cat(2,x,x,x,x,x);
    Y = cat(2,y(1,:),y(2,:),y(3,:),y(4,:),y(5,:));        
    W = cat(2,w(1,:),w(2,:),w(3,:),w(4,:),w(5,:));
    %histog2(X,Y,binX,binY,cMax,xmax,ymax,xLabel,yLabel)
    figure,histog2(W,Y,50,1,30,1,40,'Corrected EV','Distance (mm)');
    plot2svg('rmrsCShiftEV.svg');

    
    loadSurrogatePositions

    x = cat(2,rm.sigma_L,rm.sigma_R);
    y = rmrs.Cdisplacements;
    w = cat(2,cell2mat(rs.cVE_L(:)),cell2mat(rs.cVE_R(:)));     
    X = cat(2,x,x,x,x,x);
    Y = cat(2,y(1,:),y(2,:),y(3,:),y(4,:),y(5,:));        
    W = cat(2,w(1,:),w(2,:),w(3,:),w(4,:),w(5,:));
    %histog2(X,Y,binX,binY,cMax,xmax,ymax,xLabel,yLabel)
    figure,histog2(Y,W,1,50,50,40,1,'distance (mm)','corrected E.V.');
    plot2svg('srmrsCShiftEV.svg');
    

%     x = cat(2,cell2mat(rs.cVE_L(:)),cell2mat(rs.cVE_R(:))); 
%     y = rmrs.Vdisplacements;
%     w = cat(2,cell2mat(rs.cVE_L(:)),cell2mat(rs.cVE_R(:)));     
%     X = cat(2,w(1,:),w(2,:),w(3,:),w(4,:),w(5,:));
%     Y = cat(2,y(1,:),y(2,:),y(3,:),y(4,:),y(5,:));        
%     W = cat(2,w(1,:),w(2,:),w(3,:),w(4,:),w(5,:));
%     data = bootPlotMean(Y, X , W, 0.35, 0.25, [0 6],6.25,1,'distance','EV')
%     hold on
    
    
%% funky histograms
% 
% for i=1:RS
%     figure,histog2(rm.sigma_L,cell2mat(rmrs.distancesL(i)),1,1,10,15,15,'sigma (mm)','distance (visual angle)');
%     plot2svg('sigmaVSvdist.svg');
%     figure,histog2(rm.sigma_L,cell2mat(rmrs.CdistancesL(i,:)),1,1,10,15,30,'sigma (mm)','distance (mm)');
%     plot2svg('sigmaVScdist.svg');
% end
% 
% for i=1:RS
%     figure,histog2(rm.ecc_L,cell2mat(rmrs.distancesL(i)),1,1,50,15,15,'eccentricity (deg)','distance (visual angle)');
%     plot2svg('eccVSvdist.svg');
%     figure,histog2(rm.ecc_L,cell2mat(rmrs.CdistancesL(i,:)),1,1,50,15,30,'eccentricity (deg)','distance (mm)');
%     plot2svg('eccVSvdist.svg');
% end
% 
for i=1:RS
    figure,
    
    histog(rmrs.polDis(:),rmrs.Vdisplacements(:),30,20,20,pi,pi,'distance (rad)','distance (deg)');
    histog(rmrs.polDis(:),rmrs.Cdisplacements(:),30,1,20,pi,40,'distance (rad)','distance (mm)');

    histog(rmrs.eccDis(:),rmrs.Vdisplacements(:),30,20,20,2*pi,2*pi,'distance (ecc)','distance (deg)');
    histog(rmrs.eccDis(:),rmrs.Cdisplacements(:),30,1,20,2*pi,40,'distance (ecc)','distance (mm)');

    histog(cat(2,rm.pol_Lfix,rm.pol_Lfix),rmrs.Vdisplacements(:),30,20,20,2*pi,2*pi,'pol','distance (deg)');
    histog(rmrs.eccDis(:),rmrs.Cdisplacements(:),30,1,20,2*pi,40,'distance (ecc)','distance (mm)');

    
    plot2svg('polVSvdist.svg');
    figure,histog2(rm.pol_Lfix,cell2mat(rmrs.CdistancesL(i,:)),1,1,10,2*pi,40,'polar angle (rad)','distance (mm)');
    plot2svg('polVSvdist.svg');
end

loadPositionsV1V2
x = cat(2,rm.sigma_L,rm.sigma_R);
sigmaV2 = cat(2,x,x,x,x,x);
loadPositionsV1V3
x = cat(2,rm.sigma_L,rm.sigma_R);
sigmaV3 = cat(2,x,x,x,x,x);

