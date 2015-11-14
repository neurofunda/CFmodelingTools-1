function data = bootPlotMean(X, Y, W, EVthresh, binsize,range,maxX,maxY,labelX,labelY)

Y = Y;
X = X;
varexp = W;

% thresholds
EVthresh = EVthresh;
thresh.X = range + [binsize -binsize];

% plotting parameters
MarkerSize = 5;

% find useful data given thresholds
ii = varexp > EVthresh & X > thresh.X(1) & X < thresh.X(2) & Y > 0.0001;
if ~any(ii), ii = X > thresh.X(1) & X < thresh.X(2) & varexp > EVthresh; end

% weighted linear regression:
p = linreg(X(ii),Y(ii),varexp(ii));
p = flipud(p(:));
xfit = thresh.X;
yfit = polyval(p,xfit);
  
% output struct
data.X = X(ii);
data.Y = Y(ii);
data.ve  = varexp(ii);
data.xfit = xfit(:);
data.yfit = yfit(:);
data.x    = (thresh.X(1):binsize:thresh.X(2))';
data.y    = nan(size(data.x));
data.ysterr = nan(size(data.x));

% linear mean regression, compute the 95% bootstrap confidence interval over the mean 
B = bootstrp(1000,@(x) localfit(x,X(ii),Y(ii),varexp(ii)),(1:numel(X(ii))));
B = B';
pct1 = 100*0.05/2;
pct2 = 100-pct1;
b_lower = prctile(B',pct1);
b_upper = prctile(B',pct2);
keep1 = B(1,:)>b_lower(1) &  B(1,:)<b_upper(1);
keep2 = B(2,:)>b_lower(2) &  B(2,:)<b_upper(2);
keep = keep1 & keep2;
data.b_xfit = linspace(min(xfit),max(xfit),100)';
fits = [ones(100,1) data.b_xfit]*B(:,keep);
data.b_upper = max(fits,[],2);
data.b_lower = min(fits,[],2);

% plot averaged data
for b=thresh.X(1):binsize:thresh.X(2),
    bii = X >  b-binsize./2 & ...
        X <= b+binsize./2 & ii;
    if any(bii),
        s = wstat(Y(bii),varexp(bii));
%         ii2 = find(data.x==b);
        ii2 = abs(data.x - b) < 0.000001;
        data.y(ii2) = s.mean;
        data.ymed(ii2) = s.median;
        data.ysterr(ii2) = s.sterr;
        data.ymad(ii2) = s.mad; 
    end;
end;

%data.x(15) = [];
% quantile regression, compute the 95% bootstrap confidence interval over the median 
% [pq,stats] = quantreg(data.x,data.ymed',0.5,1,1000);
% yfitmed = polyval(pq,data.x)
% data.yfitmed = yfitmed(:);
% data.b_upperq =  stats.yfitci(:,1);
% data.b_lowerq =  stats.yfitci(:,2);

% plot if requested
figure('Color', 'w'); hold on;

% median regression
% errorbar(data.x,data.ymed,data.ymad,'ko',...
%     'MarkerFaceColor','k',...
%     'MarkerSize',MarkerSize);
% plot(data.x,yfitmed,'k','LineWidth',1);
% q1 = plot(data.x,data.b_upperq,'--k','LineWidth',1);
% q2 = plot(data.x,data.b_lowerq,'--k','LineWidth',1);

% mean regression
errorbar(data.x,data.y,data.ysterr,'ko',...
    'MarkerFaceColor','k',...
    'MarkerSize',MarkerSize);
plot(data.xfit,data.yfit','k','LineWidth',1);
p1 = plot(data.b_xfit,data.b_upper,'--k','LineWidth',1);
p2 = plot(data.b_xfit,data.b_lower,'--k','LineWidth',1);
%     set(p1,'Color',[.6 .6 1]);
%     set(p2,'Color',[.6 .6 1]);

xlabel(labelX,'FontSize', 14);
ylabel(labelY,'FontSize', 14);
set(gca, 'FontSize', 14);
set(gca,'LineWidth',1)
set(gcf, 'color', 'w');
axis square
xlim([0 maxX]);
ylim([0 maxY]);

return

function  B=localfit(ii,x,y,ve)
B = linreg(x(ii),y(ii),ve(ii));
B(:);
return
