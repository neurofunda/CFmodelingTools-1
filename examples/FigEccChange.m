    close all
    clear all
    RS=5;
    loadPositionsV1V3

    %% rmEcc / rsEcc
    % for i = 1:RS,
    x = cat(2,rm.ecc_L,rm.ecc_R);
    y = cat(2,cell2mat(rs.ecc_L(:)),cell2mat(rs.ecc_R(:)));  
    w = cat(2,cell2mat(rs.cVE_L(:)),cell2mat(rs.cVE_R(:)));

    X=cat(2,x,x,x,x,x);
    Y = cat(2,y(1,:),y(2,:),y(3,:),y(4,:),y(5,:));
    W = cat(2,w(1,:),w(2,:),w(3,:),w(4,:),w(5,:));
%     histog(X,Y,10,10,20,2*pi,2*pi,'eccentricity (deg)','rs eccentricity (deg)');

    bootPlot(X, Y , W, 0.25, 0.3, [0 6.25],6.5,10,'rm eccentricity (deg)','rs eccentricity (deg)')
    hold on
    %     run = strcat('RS ',num2str(i));
    %     title(run);
    % end

    plot2svg('rmEccVSrsEccV1V3.svg');

    %% differences in eccentricity
    figure,
    X = cat(2,cell2mat(rmrs.dEccRdir(:,:)),cell2mat(rmrs.dEccLdir(:,:)));
    % zeros = find(X==0);
    % mfd = setdiff(1:length(X), zeros);
    % X = X(mfd);
    C=-20:0.25:20;
    [Ns]=histc(X,C);
    relativefreqNs = Ns ./ sum(Ns);
    b = bar(C,relativefreqNs,'histc');
    set(gca, 'FontSize', 14);
    set(gca,'LineWidth',1)
    set(gcf, 'color', 'w');
    axis square
    title('rmrs eccentricity shifts');
    xlabel('eccentricity (deg)','FontSize', 14);
    ylabel('relative frequency','FontSize', 14);
    xlim([-15 15]);
    b = findobj(gca,'Type','patch');
    set(b(1),'FaceColor', 'k','EdgeColor', 'k','facealpha',0.8,'edgealpha',0);
    plot2svg('rmrsEccShift.svg');


    x = cat(2,rm.sigma_L,rm.sigma_R);
    y = rmrs.Cdisplacements;
    w = cat(2,cell2mat(rs.cVE_L(:)),cell2mat(rs.cVE_R(:)));
    X = cat(2,x,x,x,x,x);
    Y = cat(2,y(1,:),y(2,:),y(3,:),y(4,:),y(5,:));
    W = cat(2,w(1,:),w(2,:),w(3,:),w(4,:),w(5,:));
    %histog2(X,Y,binX,binY,cMax,xmax,ymax,xLabel,yLabel)
    y = cat(2,cell2mat(rmrs.dEccRdir(:,:)),cell2mat(rmrs.dEccLdir(:,:)));
    zeros = find(y==0);
    mfd = setdiff(1:length(y), zeros);
    y = y(mfd);
    W = W(mfd);
    figure,histog2(y,W,1,100,30,10,1,'eccentricity difference (mm)','corrected E.V.');
    plot2svg('rmrsEccDiff.svg');


    %% eccentricity referenced plots
    % rmEcc / rmrs visual distance
    % for i = 1:RS,
    x = cat(2,rm.ecc_L,rm.ecc_R);
    y = rmrs.Vdisplacements;
    w = cat(2,cell2mat(rs.cVE_L(:)),cell2mat(rs.cVE_R(:)));

    X = cat(2,x,x,x,x,x);
    Y = cat(2,y(1,:),y(2,:),y(3,:),y(4,:),y(5,:));
    W = cat(2,w(1,:),w(2,:),w(3,:),w(4,:),w(5,:));

    data = bootPlot(X, Y , W, 0.35, 0.25, [0 6],6.25,6.25,'rm eccentricity (deg)','rmrs distance (deg)')
       plot2svg('rmrsVdisEcc.svg');

    %     run = strcat('RS ',num2str(i));
    %     title(run);
    % end
    % rmEcc / rmrs cortical distance
    % for i = 1:RS,
   % x = cat(2,rm.ecc_L,rm.ecc_R);
   
       close all
    clear all
    RS=5;
    loadPositionsV1V3
    y = rmrs.Cdisplacements;
      x = rmrs.iaCdisplacements;
    w = cat(2,cell2mat(rs.cVE_L(:)),cell2mat(rs.cVE_R(:)));
    
    X = cat(2,x(1,:),x(2,:),x(3,:),x(4,:),x(5,:));
    Y = cat(2,y(1,:),y(2,:),y(3,:),y(4,:),y(5,:));
    W = cat(2,w(1,:),w(2,:),w(3,:),w(4,:),w(5,:));

    %bootPlot(X, Y , W, 0.35, 1, [0 25],30,20,'rm eccentricity (deg)','rmrs distance (mm)')      
    bootPlot(X, Y , abs(W), 0.35, 1, [0 25],25,20,'inter-area distance (mm) (mm)','intra-area distance (mm)')
    
    plot2svg('interAreaD_V1V3.svg');

    plot2svg('rmrsCdisEccV1V3.svg');

    %     run = strcat('RS ',num2str(i));
    %     title(run);
    % end
    %
    %
    % %% RSRS
    %
    %
    % % rmEcc / rsrs visual distance
    % for i = 1:RS,
    %
    %     x = cat(2,rm.ecc_L,rm.ecc_R);
    %     y = rsrs.Vdisplacements;
    %     w = cat(2,cell2mat(rs.cVE_L(:)),cell2mat(rs.cVE_R(:)));
    %
    %     X = cat(2,x,x,x,x,x);
    %     Y = cat(2,y(1,:),y(2,:),y(3,:),y(4,:),y(5,:));
    %     W = cat(2,w(1,:),w(2,:),w(3,:),w(4,:),w(5,:));
    %
    %     data = bootPlot(X, Y , W, 0.35, 0.25, [0 6],6.25,6.25,'rm eccentricity (deg)','rsrs distance (deg)')
    %     hold on
    %     run = strcat('RS ',num2str(i));
    %     title(run);
    % end
    % % rmEcc / rsrs cortical distance
    % for i = 1:RS,
    %     x = cat(2,rm.ecc_L,rm.ecc_R);
    %     y = rsrs.Cdisplacements;
    %     w = cat(2,cell2mat(rs.cVE_L(:)),cell2mat(rs.cVE_R(:)));
    %
    %     X = cat(2,x,x,x,x,x);
    %     Y = cat(2,y(1,:),y(2,:),y(3,:),y(4,:),y(5,:));
    %     W = cat(2,w(1,:),w(2,:),w(3,:),w(4,:),w(5,:));
    %
    %     bootPlot(X, Y , W, 0.35, 0.5, [0 8],6.25,20,'rm eccentricity (deg)','rsrs distance (mm)')
    %     hold on
    %     run = strcat('RS ',num2str(i));
    %     title(run);
    % end
