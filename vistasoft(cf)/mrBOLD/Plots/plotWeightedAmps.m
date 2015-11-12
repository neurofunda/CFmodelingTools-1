function plotWeightedAmps(view)
%
% plotWeightedAmplitudes(view)
% 
% Bar plot of the amplitudes for each scan, averaging across
% all pixels (in all slices) in the current ROI.  The bar heights
% gmb  5/25/98
% Compute means across scans, for all pixels in the
% currently selected ROI.  The seZ value is the mean
% make sure a parameter map exists:

if isempty(view.map)
  warndlg('No Parameter map is loaded.  Use View->Residual Std Map to load the map used for weighting')
  return
end

refScan = getCurScan(view);

meanProjectedAmps = weightedProjectedAmps(view);

% Header
ROIname = view.ROIs(view.selectedROI).name;
headerStr = ['Mean of projected amplitudes, ROI ',ROIname];
set(gcf,'Name',headerStr);

%plot the bar graph
clf
fontSize = 14;
h=mybar(meanProjectedAmps);
xlabel('Scan','FontSize',fontSize);
ylabel('Mean Projected Amplitude','FontSize',fontSize);
ylim =get(gca,'YLim');
set(gca,'YLim',ylim*1.1);
set(gca,'FontSize',fontSize);

foo=cell2struct(h,'bar');
hbar=foo.bar(refScan);
set(hbar,'FaceColor','r')

%Save the data in gca('UserData')
data.y = meanProjectedAmps;
data.refScan = refScan;
set(gca,'UserData',data);

return;