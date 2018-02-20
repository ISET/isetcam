function plotDisplayColor(ip,dataType)
%Gateway routine for plotting image processor window color analysis
%
%  plotDisplayColor(vci,dataType)
%
% The user selects a region of a display image.  This routine plots the
% distribution of color values of various types.  
%
%  Current types of data plots
%
%       {'rgb'}               - Digital rgb values
%       {'chromaticity'}      - Display chromaticities
%       {'luminance'}         - Display luminance
%       {'cielab'}            - CIELAB values w.r.t the image white point
%       {'cieluv'}            - CIELUV values w.r.t. the image white point.
%
% The selected values are stored in the userdata area of the plot window,
% that is, get(gcf,'userdata') will return the values.
%
% If vci is empty, then the currently selected processor data (vci) is
% used.
%
% See also:  plotDisplayGamut
%
% Examples:
%  vci = vcGetObject('vci');
%  plotDisplayColor(vci,'xy'); userData = get(gcf,'UserData');
%
%  plotDisplayColor([],'luminance')
%  plotDisplayColor([],'cielab')
%
% Copyright ImagEval Consultants, LLC, 2005.

% TODO:  Restructure using a new routine, plotIP
%

%% Variables
if ieNotDefined('vci');      ip = vcGetObject('vcimage'); end
if ieNotDefined('dataType'), dataType = 'rgb'; end

%% Select the RGB data from the ROI
handles = ieSessionGet('vcimagehandle');
ieInWindowMessage('Select image region of interest.',handles,[]);
roiLocs = vcROISelect(ip);
RGB     = vcGetROIData(ip,roiLocs,'result');
ieInWindowMessage('',handles,[]);

%%
% maxRGB = ipGet(vci,'rgbmax');

% Always open up a new window?
figNum =  vcNewGraphWin;

switch lower(dataType)
    case {'rgb'}
        colorlist = {'r','g','b'};
        for ii=1:3
            subplot(1,3,ii); 
            nBins = round(max(20,size(RGB,1)/25));
            hist(RGB(:,ii),nBins);
            set(gca,'xlim',[0 1.1]); 
            c = get(gca,'Children');
            set(c,'EdgeColor',colorlist{ii});
            grid on;
        end
        subplot(1,3,1); ylabel('Count');
        subplot(1,3,2); xlabel('Pixel value');
        title('RGB histograms');
        set(gcf,'Color',[.8 .8 .8]);
        udata.RGB = RGB;

    case {'xy','chromaticity'}
        dataXYZ = imageRGB2XYZ(ip,RGB);
        xy = chromaticity(dataXYZ);
        
        plotSpectrumLocus(figNum); hold on;
        plot(xy(:,1),xy(:,2),'o'); 
        grid on;
        
        title('CIE (1931) chromaticities');
        xlabel('x-chromaticity'); ylabel('y-chromaticity');
        axis square;

        meanXYZ = mean(dataXYZ);
        
        txt = sprintf('X = %.02f\nY = %.02f\nZ = %.02f',meanXYZ(1),meanXYZ(2),meanXYZ(3));
        plotTextString(txt,'ur');
        
        udata.xy = xy; udata.XYZ = dataXYZ;
        
    case 'luminance'
        
        dataXYZ = imageRGB2XYZ(ip,RGB);
        luminance = dataXYZ(:,2);
        
        hist(luminance(:)); grid on;
        xlabel('Luminance (cd/m^2)'); ylabel('Count'); title('Luminance (CIE 1931 Y)');
        set(gca,'xlim',[max(0,0.*min(luminance(:))), max(luminance(:))*1.1]);
        mnL = mean(luminance);
        stdL = std(luminance);
        txt = sprintf('Mean: %.02f\nSD:   %.03f\nSNR (db)=%.03f',mnL,stdL,20*log10(mnL/stdL));
        plotTextString(txt,'ul');

        udata.luminance = luminance;
        udata.meanL = mnL;
        udata.stdLum = stdL;
        
    case 'cielab'
        % Needs updating
        dataXYZ  = ipGet(ip,'roi xyz',roiLocs);
        whitepnt = ipGet(ip,'data or Display WhitePoint');
        dataLAB = ieXYZ2LAB(dataXYZ,whitepnt);
        plot3(dataLAB(:,2), dataLAB(:,3),dataLAB(:,1), 'o');
        set(gca,'xlim',[-50 50],'ylim',[-50 50],'zlim',[0,100]);
        grid on; axis square
        
        xlabel('a*'); ylabel('b*'); zlabel('L*');
        title('CIELAB values of selected region');
        
        txt = sprintf('Mean: [%.02f,%.02f,%.02f]\n',mean(dataLAB));
        plotTextString(txt,'ul');
        
        udata = dataLAB;
        
    case 'cieluv'
        dataXYZ  = ipGet(ip,'roi xyz',roiLocs);
        whitepnt = ipGet(ip,'data or Display WhitePoint');
        dataLUV = xyz2luv(dataXYZ,whitepnt);
        plot3(dataLUV(:,2), dataLUV(:,3),dataLUV(:,1),'o');
        grid on; axis square
        set(gca,'xlim',[-100 100],'ylim',[-100 100],'zlim',[0,100]);

        xlabel('u*'); ylabel('v*'); zlabel('L*');
        title('CIELUV values of selected region');
        
        txt = sprintf('Mean: [%.02f,%.02f,%.02f]\n',mean(dataLUV));
        plotTextString(txt,'ul');
        
        udata = dataLUV;
        
    otherwise
        error('Unknown plot display data type.')
end

set(figNum,'Userdata',udata);
hold off

return;
