close all 
clear all
refDataType = 'Averages';
XdataType = 'RS5';
source = 'LV1';
target = 'LV3';
path2Ref = strcat('pRFandCFdata_',refDataType,'_',source,'_',target,'.mat');
path2X = strcat('pRFandCFdata_',XdataType,'_',source,'_',target,'.mat');
%Compute CF displacement between reference and X condition
[cfCdis cfVdis] = computeCFdisplacements(path2Ref,path2X,0);

%--------------------------------------------------------------------------
% Frequency histogram
%--------------------------------------------------------------------------
load(path2X);
% Cortical displacement
figure,
X = cfCdis;
%X = pRFandCFdata.cf.correctedVE;
% zeros = find(X==0);
% mfd = setdiff(1:length(X), zeros);
% X = X(mfd);
C=0:0.25:40; % CF scatter
%C=0:0.05:1; % VE
[Ns]=histc(X,C);
relativefreqNs = Ns ./ sum(Ns);
b(1) = bar(C,relativefreqNs,'histc');
% hold on
% X = CFdis;
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
title('CF scatter');
xlabel('Cortical distance (mm)','FontSize', 14);
ylabel('Relative frequency','FontSize', 14);
xlim([0 50]); % CF scatter
%xlim([0 1]); % VE
b = findobj(gca,'Type','patch');
set(b(1),'FaceColor', 'k','EdgeColor', 'k','facealpha',0.8,'edgealpha',0);
% set(b(2),'FaceColor', 'g','EdgeColor', 'g','facealpha',0.2,'edgealpha',0);
title('CF scatter frequency scatter');

%--------------------------------------------------------------------------
% Bivariate histogram
%--------------------------------------------------------------------------
% function  [] = histog2(X,Y,binX,binY,cMax,xmax,ymax,xLabel,yLabel)
bvhistog(pRFandCFdata.cf.correctedVE,cfCdis',10,2,10,1,40,'Variance explained','CF scatter (mm)');
title('CF scatter vs variance eplxained');

%--------------------------------------------------------------------------
% Bivariate plot
%--------------------------------------------------------------------------

figure,
% Thresholding of data
EVthresh = 0.35;
X = pRFandCFdata.targetVCoords(1,:);
Y = cfCdis'; % CF scatter
W = pRFandCFdata.cf.correctedVE;
xmax = 6;
ymax= 40;
dataMatrix = cat(2,W',X',Y');
dataAbove = dataMatrix(dataMatrix(:,1)>EVthresh,:);
W = dataAbove(:,1)';
X = dataAbove(:,2)';
Y = dataAbove(:,3)';
scatter(X,Y,0.5,[0 0 0]+0.1); % Raw data
hold on
data = cat(1,X,Y);
data = sortrows(data,1)';
[ResMat,NewMat] = binning(data,1,0,15); % Binned stats
%boundedline(NewMat(:,1),NewMat(:,2), NewMat(:,3)); % Fancy bounded line
errorbar(NewMat(:,1),NewMat(:,2),NewMat(:,3),'--kx'); % Error bars
xlabel('pRF eccentricity (deg)','FontSize', 14);
ylabel('CF scatter (mm)','FontSize', 14);
xlim([0 xmax]); ylim([0 ymax]);
set(gca, 'FontSize', 14);
set(gca,'LineWidth',1)
set(gcf, 'color', 'w');
axis square
title('CF eccentricity vs CF scatter');


% Linear reressions
% Thresholding of data
EVthresh = 0.35;
X = pRFandCFdata.sourceVCoords(1,:);
Y = pRFandCFdata.sourceSigma;
W = pRFandCFdata.sourceVE;
% Bootstrap quantile (found to be the most reliable. If needed, find code for mean and median based
% regressions inside function bootPlot)
% bootPlot(X, Y, W, EVthresh, binsize,range,maxX,maxY,labelX,labelY)
data = bootPlot(X, Y , W, 0.35, 1, [0 7],7,3,'pRF eccentricity (rad)','pRF size (mm)')
title('pRF eccentricity vs pRF size');
