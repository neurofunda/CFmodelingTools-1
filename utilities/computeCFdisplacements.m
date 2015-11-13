function [ CFdisplacements ] = computeCFdisplacements(folder,refDataType,dataType,source,target,VEthr)

% reference 
load(strcat(folder,'pRFandCFdata_',refDataType,'_',source,'_',target,'.mat'));
conRef = pRFandCFdata.cf.conIndex;
distances = pRFandCFdata.sourceDistances;

% condition
load(strcat(folder,'pRFandCFdata_',dataType,'_',source,'_',target,'.mat'));
VE_L = pRFandCFdata.cf.correctedVE;
con = pRFandCFdata.cf.conIndex;
ve = VE_L;
ind = find(ve > VEthr);

CFdisplacements = diag(distances(con(ind),conRef(ind)));

return


