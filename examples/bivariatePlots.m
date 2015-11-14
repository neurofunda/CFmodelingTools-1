close all 
clear all
refDataType = 'Averages';
XdataType = 'RS5';
source = 'LV1';
target = 'LV3';
path2Ref = strcat('pRFandCFdata_',refDataType,'_',source,'_',target,'.mat');
path2X = strcat('pRFandCFdata_',XdataType,'_',source,'_',target,'.mat');
%Compute CF displacement between reference and X condition
CFdis = computeCFdisplacements(path2Ref,path2X,0);

%--------------------------------------------------------------------------
% Frequency histogram
%--------------------------------------------------------------------------
load(path2X);
% Cortical displacement
figure,
%X = CFdis;
X = pRFandCFdata.cf.correctedVE;
% zeros = find(X==0);
% mfd = setdiff(1:length(X), zeros);
% X = X(mfd);
%C=0:0.25:40; % CF scatter
C=0:0.05:1; % VE
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
xlabel('Distance (mm)','FontSize', 14);
ylabel('Relative frequency','FontSize', 14);
%xlim([0 50]); % CF scatter
xlim([0 1]); % VE
b = findobj(gca,'Type','patch');
set(b(1),'FaceColor', 'k','EdgeColor', 'k','facealpha',0.8,'edgealpha',0);
% set(b(2),'FaceColor', 'g','EdgeColor', 'g','facealpha',0.2,'edgealpha',0);

%--------------------------------------------------------------------------
% Bivariate histogram
%--------------------------------------------------------------------------
% function  [] = histog2(X,Y,binX,binY,cMax,xmax,ymax,xLabel,yLabel)
histog2(pRFandCFdata.cf.correctedVE,CFdis',10,2,10,1,40,'VE','CF displacement')

%--------------------------------------------------------------------------
% Bivariate plot
%--------------------------------------------------------------------------

% weighted linear regression:

figure,
% Thresholding of data
EVthresh = 0.35;
X = pRFandCFdata.targetVCoords(1,:);
Y = CFdis';
W = pRFandCFdata.cf.correctedVE;
dataMatrix = cat(2,W',X',Y');
dataAbove = dataMatrix(dataMatrix(:,1)>EVthresh,:);
W = dataAbove(:,1)';
X = dataAbove(:,2)';
Y = dataAbove(:,3)';
xmax = 6;
ymax= 40;

scatter(X,Y,0.5,[0 0 0]+0.1); % Raw data
hold on

data = cat(1,X,Y);
data = sortrows(data,1)';
[ResMat,NewMat] = binning(data,1,0,15); % Binned stats
%boundedline(NewMat(:,1),NewMat(:,2), NewMat(:,3)); % Fancy bounded line
errorbar(NewMat(:,1),NewMat(:,2),NewMat(:,3),'--kx'); % Error bars
xlabel('pRF eccentricity (deg)','FontSize', 14);
ylabel('CF eccentricity (deg)','FontSize', 14);
xlim([0 xmax]); ylim([0 ymax]);
set(gca, 'FontSize', 14);
set(gca,'LineWidth',1)
set(gcf, 'color', 'w');
axis square
title('CF eccentricity vs CF scatter');
