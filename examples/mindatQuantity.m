%--------------------------------------------------------------------------
% Cumulative chopping of time series into dataypes
%--------------------------------------------------------------------------
% clear all
% close all
% view=initHiddenGray();
% mrGlobals;
% firstDatatype=6;
% lastDatatype=10;
% totalTR=240;
% wSize=40;
% lastDatatypeIndex=10;
% bins=totalTR/wSize;
% label='_cumSum40TR_';
% for i=firstDatatype:lastDatatype
%     for j=1:bins
%         view =selectDataType(view,i);
%         curDataType = viewGet(view,'curDataType')
%         fprintf('Loading Datatype:%s\n',dataTYPES(1,curDataType).name)
%         groupName = strcat('RS',num2str(i-(firstDatatype-1)),label,num2str(j))
%         groupScans(view, 1, groupName)
%         view = selectDataType(view,lastDatatypeIndex+j+(bins*(i-firstDatatype)))
%         curDataType = viewGet(view,'curDataType')
%         fprintf('Loading Datatype:%s\n',dataTYPES(1,curDataType).name)
%         tSeriesClipFrames(view,1,0,wSize*j);
%     end
% end

%--------------------------------------------------------------------------
% Compute CF models for each data segment
%--------------------------------------------------------------------------
% clear all
% close all
% view=initHiddenGray();
% mrGlobals;
% dataFolders
% for i=11:40
% % Left hemisphere and ROIs
% hemis = 'L';
% source = 'V1';
% target = 'V3';
% % Load ROIS
% ROIS{1} = strcat(hemis,source) % Source ROI
% ROIS{2} = strcat(hemis,target) % Target ROI
% view = loadROI(view, ROIS,[], [], 0, 1);   
% cf = computeCF(view,1,0,i,pRFmodel,0);
% VE{(i-10),1} = cf.correctedVE;
% surrogateVE{i,1} = cf.scorrectedVE;
% clear cf 
% view = deleteAllROIs(view); view = refreshScreen(view,0); 
% % Right hemisphere and ROIs
% hemis = 'R';
% source = 'V1';
% target = 'V3';
% % Load ROIS
% ROIS{1} = strcat(hemis,source) % Source ROI
% ROIS{2} = strcat(hemis,target) % Target ROI
% view = loadROI(view, ROIS,[], [], 0, 1);  
% cf = computeCF(view,1,0,i,pRFmodel,0);
% VE{(i-10),2} = cf.correctedVE;
% surrogateVE{i,2} = cf.scorrectedVE;
% clear cf
% 
% view = deleteAllROIs(view); view = refreshScreen(view,0);
% 
% end
% 
% % Save data
% mindata = struct('VE',VE,'surrogateVE',surrogateVE);
% file = ['./Analysis/mindatAnalysis_LV1_LV3.mat'];
% save (file,'mindata','-mat');


%--------------------------------------------------------------------------
% ROC analysis
%--------------------------------------------------------------------------
% Performance scores
% Sensitivity, recall                             TPR=TP/(TP+FN)
% False positive rate                             FPR=FP/(FP+TN)
% Accuracy                                        ACC=(TP+TN)/((TP+FN)+(FP+TN))
% Positive predictive value, Precision            PPV=TP/(TP+FP)
% F-score                                         F-score=2TP/(2TP+FP+FN)
% False discovery rate                            FDR=FP/FP+TP)
%--------------------------------------------------------------------------
close all 
clear all
totalTR=240;
wSize=40;
bins=totalTR/wSize;
%data = strcat('./Analysis/mindatAnalysis_LV1_LV3.mat');
data = strcat('mindatAnalysis_LV1_LV3.mat');
load(data);

% Collect data
for n = 1:bins    
    j = 1;
    for i = (10+n):6:40        
        % VE
        x_L(j,:) = mindata(i,1).VE;
        x_R(j,:) = mindata(i,2).VE;
        % Surrogate VE
        sx_L(j,:) = mindata(i,1).surrogateVE;
        sx_R(j,:) = mindata(i,2).surrogateVE;        
        j = j+1;
    end
    x(n,:) = [x_L(:)' x_R(:)'];
    sx(n,:) = [sx_L(:)' sx_R(:)'];
end

% Format by class
for i = 1:6
class(:,:,i) = format_by_class(x(i,:),sx(i,:));
end

% Compute ROC
[tp1,fp1,ppv1,mcc1,Fscore1] = roc(class(:,:,1));
[tp2,fp2,ppv2,mcc2,Fscore2] = roc(class(:,:,2));
[tp3,fp3,ppv3,mcc3,Fscore3] = roc(class(:,:,3));
[tp4,fp4,ppv4,mcc4,Fscore4] = roc(class(:,:,4));
[tp5,fp5,ppv5,mcc5,Fscore5] = roc(class(:,:,5));
[tp6,fp6,ppv6,mcc6,Fscore6] = roc(class(:,:,6));

% Compute AUC
[A1,Aci1] = auc(class(:,:,1),0.001,'maxvar');
[A2,Aci2] = auc(class(:,:,2),0.001,'maxvar');
[A3,Aci3] = auc(class(:,:,3),0.001,'maxvar');
[A4,Aci4] = auc(class(:,:,4),0.001,'maxvar');
[A5,Aci5] = auc(class(:,:,5),0.001,'maxvar');
[A6,Aci6] = auc(class(:,:,6),0.001,'maxvar');

% Compute Discriminability
kA1=2*A1-1;
kA2=2*A2-1;
kA3=2*A3-1;
kA4=2*A4-1;
kA5=2*A5-1;
kA6=2*A6-1;

% Compute Discriminability CI
kAci1=2.*Aci1-1; lowCI1=kA1-kAci1(1); upCI1=kAci1(2)-kA1;
kAci2=2.*Aci2-1; lowCI2=kA2-kAci2(1); upCI2=kAci2(2)-kA2;
kAci3=2.*Aci3-1; lowCI3=kA3-kAci3(1); upCI3=kAci3(2)-kA3;
kAci4=2.*Aci4-1; lowCI4=kA4-kAci4(1); upCI4=kAci4(2)-kA4;
kAci5=2.*Aci5-1; lowCI5=kA5-kAci5(1); upCI5=kAci5(2)-kA5;
kAci6=2.*Aci6-1; lowCI6=kA6-kAci6(1); upCI6=kAci6(2)-kA6;

%--------------------------------------------------------------------------
% Plot results
%--------------------------------------------------------------------------
figure,

% Box plots
subplot (2,2,1)
X = [x(1,:) x(2,:) x(3,:) x(4,:) x(5,:) x(6,:)];
group = [ones(size(x(1,:))) ones(size(x(2,:)))+1 ones(size(x(3,:)))+2 ones(size(x(4,:)))+3 ...
    ones(size(x(5,:)))+4 ones(size(x(6,:)))+5];
h=boxplot(X, group,'notch','on','plotstyle','compact','boxstyle','outline','colors','k','symbol','w','medianstyle','line');
hold on
SX = [sx(1,:) sx(2,:) sx(3,:) sx(4,:) sx(5,:) sx(6,:)];
sgroup = [ones(size(sx(1,:))) ones(size(sx(2,:)))+1 ones(size(sx(3,:)))+2 ones(size(sx(4,:)))+3 ...
    ones(size(sx(5,:)))+4 ones(size(sx(6,:)))+5];
sh=boxplot(SX, sgroup,'notch','on','plotstyle','compact','boxstyle','outline','colors','r','symbol','w','medianstyle','line');
% title('cumulative sum of volumes','FontSize', 14)
ylabel('corrected E.V.','FontSize', 14);
xlabel('cumulative sum of volumes','FontSize', 14);
set(gca, 'FontSize', 14);
set(gcf, 'color', 'w');
set(gca,'LineWidth',1);
set(gca,'xtick',[1 2 3 4 5 6 ])
set(gca,'xticklabel',{'40','80','120','160','200','240'});
delete(findobj(gca,'Type','text'));
axis square

% ROC curves
subplot (2,2,2)
plot(fp1,tp1,'color',[0,0,0]+0.5);
hold on
plot(fp2,tp2,'color',[0,0,0]+0.4);
plot(fp3,tp3,'color',[0,0,0]+0.3);
plot(fp4,tp4,'color',[0,0,0]+0.2);
plot(fp5,tp5,'color',[0,0,0]+0.1);
plot(fp6,tp6,'color',[0,0,0]);
axis square
xlabel('false positive rate','FontSize', 14);
ylabel('true positive rate','FontSize', 14);
set(gcf, 'color', 'w');
set(gca,'LineWidth',1);
set(gca, 'FontSize', 14);
legend('40','80','120','160','200','240','Location','SouthEast');

% AUC vs TR
subplot (2,2,3)
t=linspace(40,240,6)';
errorbar(t,[kA1 kA2 kA3 kA4 kA5 kA6],...
    [lowCI1 lowCI2 lowCI3 lowCI4 lowCI5 lowCI6],[upCI1 upCI2 upCI3 upCI4 upCI5 upCI6],'--k');
axis square
xlabel('cumulative sum of volumes','FontSize', 14);
ylabel('discriminability (2*AUC-1)','FontSize', 14);
xlim([20 260]);
ylim([0 1]);
grid on
set(gcf, 'color', 'w');
set(gca,'LineWidth',1);
set(gca, 'FontSize', 14);
set(gca,'xtick',[40 80 120 160 200 240 ])
set(gca,'xticklabel',{'40','80','120','160','200','240'});
delete(findobj(gca,'Type','text'));

% Fscore vs threshold
subplot (2,2,4)
thr1=linspace(1,0,length(Fscore1))';
thr2=linspace(1,0,length(Fscore2))';
thr3=linspace(1,0,length(Fscore3))';
thr4=linspace(1,0,length(Fscore4))';
thr5=linspace(1,0,length(Fscore5))';
thr6=linspace(1,0,length(Fscore6))';
plot(thr1,Fscore1,'color',[0,0,0]);
hold on
plot(thr2,Fscore2,'color',[0,0,0]);
plot(thr3,Fscore3,'color',[0,0,0]);
plot(thr4,Fscore4,'color',[0,0,0]);
plot(thr5,Fscore5,'color',[0,0,0]);
plot(thr6,Fscore6,'color',[0,0,0]);
axis square
xlabel('EV threshold','FontSize', 15);
ylabel('F-score','FontSize', 15);
xlim([0 1]);
ylim([0 1]);
set(gcf, 'color', 'w');
set(gca,'LineWidth',1);
set(gca, 'FontSize', 15);

% Export figure
% export_fig('Fscore_threshold.png')
