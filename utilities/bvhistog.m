function  [] = bvhistog(X,Y,binX,binY,cMax,xmax,ymax,xLabel,yLabel)
figure,
%# bin centers (integers)
xbins = floor(min(X)):1/binX:ceil(max(X));
ybins = floor(min(Y)):1/binY:ceil(max(Y));
xNumBins = numel(xbins); yNumBins = numel(ybins);
%# map X/Y values to bin indices
Xi = round( interp1(xbins, 1:xNumBins, X, 'linear', 'extrap') );
Yi = round( interp1(ybins, 1:yNumBins, Y, 'linear', 'extrap') );
%# limit indices to the range [1,numBins]
Xi = max( min(Xi,xNumBins), 1);
Yi = max( min(Yi,yNumBins), 1);
%# count number of elements in each bin
H = accumarray([Yi(:) Xi(:)], 1, [yNumBins xNumBins]);
%# plot 2D histogram
imagesc(xbins, ybins, H), axis on %# axis image
hold on
data = cat(1,X,Y); 
data = sortrows(data,1)';
[ResMat,NewMat] = binning(data,1,[],[]);
%errorbar(NewMat(:,1),NewMat(:,2),NewMat(:,3),'kx');
cmap = colormap(hot);
%cmap = colormap(flipud(haxby)); 
colormap(cmap);  
caxis([0 cMax]);
cb = colorbar;
xlabel(cb,'#', 'FontSize', 14);%hold on, plot(X, Y, 'b.', 'MarkerSize',1), hold off
set(gca,'YDir','normal')
set(gca, 'FontSize', 14);
set(gca,'LineWidth',1)
set(gcf, 'color', 'w');
xlabel(xLabel,'FontSize', 14);
xlim([0 xmax]);
ylim([0 ymax]);
ylabel(yLabel,'FontSize', 14);
axis square
end