function [ CFdis ] = computeCFdisplacements(folder,refDataType,dataType,source_L,target_L,source_R,target_R,VEthr)
% reference 
% L
pRFandCFdata = strcat(folder,'pRFandCFdata_',refDataType,'_',source_L,'_',target_L,'.mat');
load(pRFandCFdata);
conIndexVFM_L = pRFandCFdata.cf.conIndex;
distances_L = pRFandCFdata.sourceDistances;
% R
pRFandCFdata = strcat(folder,'pRFandCFdata_Averages_',source_R,'_',target_R,'.mat');
load(pRFandCFdata);
conIndexVFM_R = pRFandCFdata.cf.conIndex;
distances_R = pRFandCFdata.sourceDistances;

% condition
% L
L = strcat(folder,'pRFandCFdata_',dataType,'_',source_L,'_',target_L,'.mat');
load(L);
VE_L = pRFandCFdata.cf.correctedVE;
conIndex_L = pRFandCFdata.cf.conIndex;
ve = VE_L;
ind = find(ve > VEthr);
conRS_L = conIndex_L;
D = distances_L(conIndexVFM_L,conRS_L);
CFdisplacements_L = diag(D);
CFdisplacements_L = CFdisplacements_L(ind);
medDisplacement_L = median(CFdisplacements_L);
madDisplacement_L = median(abs(CFdisplacements_L - medDisplacement_L));
clear L
% R
R = strcat(folder,'pRFandCFdata_',dataType,'_',source_R,'_',target_R,'.mat');
load(R);
VE_R = pRFandCFdata.cf.correctedVE;
conIndex_R = pRFandCFdata.cf.conIndex;
ve = VE_R;
ind = find(ve > VEthr);
conRS_R = conIndex_R;
D = distances_R(conIndexVFM_R,conRS_R);
CFdisplacements_R = diag(D);
CFdisplacements_R = CFdisplacements_R(ind);
medDisplacement_R = median(CFdisplacements_R);
madDisplacement_R = median(abs(CFdisplacements_R - medDisplacement_R));
clear R


CFdisplacements = cat(1,CFdisplacements_L,CFdisplacements_R);
medDisplacement = median(CFdisplacements);
madDisplacement = median(abs(CFdisplacements - median(CFdisplacements)));


med =  cat(2,medDisplacement_L',medDisplacement_R');
mad =  cat(2,madDisplacement_L',madDisplacement_R');
CFdis = cat(1,med,mad);

return


