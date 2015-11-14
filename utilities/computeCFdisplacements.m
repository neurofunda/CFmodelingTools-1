function [ CFdis Vdis ] = computeCFdisplacements(path2Ref,path2X,VEthr)

% reference 
load(path2Ref);
conRef = pRFandCFdata.cf.conIndex;
distances = pRFandCFdata.sourceDistances;
eccRef = pRFandCFdata.cf.ecc;
polRef = pRFandCFdata.cf.pol;

% condition
load(path2X);
VE = pRFandCFdata.cf.correctedVE;
con = pRFandCFdata.cf.conIndex;
eccX = pRFandCFdata.cf.ecc;
polX = pRFandCFdata.cf.pol;
ind = find(VE > VEthr);

CFdis = diag(distances(con(ind),conRef(ind)));
Vdis = sqrt(eccRef(ind).^2 + eccX(ind).^2 - 2.*eccRef(ind).*eccX(ind).*cos(polRef(ind) - polX(ind)))';

return


