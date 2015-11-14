function [ CFdisplacements ] = computeCFdisplacements(path2Ref,path2X,VEthr)

% reference 
load(path2Ref);
conRef = pRFandCFdata.cf.conIndex;
distances = pRFandCFdata.sourceDistances;

% condition
load(path2X);
VE = pRFandCFdata.cf.correctedVE;
con = pRFandCFdata.cf.conIndex;
ind = find(VE > VEthr);

CFdisplacements = diag(distances(con(ind),conRef(ind)));

return


