function [uData, figHdl] = plotDisplayColor(ip,dataType)
% Plots for ip (image processor) window color analysis
%
% Syntax:
%  [udata, figHdl] = plotDisplayColor(ip,dataType)
%
% Description:
%   Use ipPlot rather than calling this routine directly.  It will be
%   renamed to displayPlotColor() some day.
%
%  The user selects a region of a display image.  This routine plots
%  the distribution of color values of various types.
%
% Inputs:
%   ip - Image processor object
%   dataType - string specifying the type of plot
%
%  Current types of data plots
%
%       {'rgb histogram'}     - Digital rgb values histograms
%       {'rgb 3d'}            - 3D graph of RGB values
%       {'chromaticity'}      - Display chromaticities
%       {'luminance'}         - Display luminance
%       {'cielab'}            - CIELAB values w.r.t the image white point
%       {'cieluv'}            - CIELUV values w.r.t. the image white point.
%
% Outputs
%   uData  - Struct with the values.  This is also attached to the userdata
%            in the figure (get(figHdl,'userdata'))
%   figHdl - Figure handle of the graph window
%
% If ip is empty, then the currently selected image processor data (ip) is
% used.
%
% ieExamplesPrint('plotDisplayColor')
%
% See also:  
%  plotDisplayGamut

% Examples:
%{
  ip = ieGetObject('ip');
  plotDisplayColor(ip,'xy'); userData = get(gcf,'UserData');
  plotDisplayColor([],'luminance')
  plotDisplayColor([],'cielab')
%}

%% Variables
if ieNotDefined('ip');      ip = vcGetObject('ip'); end
if ieNotDefined('dataType'), dataType = 'rgbhistogram'; end

%% Select the RGB data from the ROI
% app = ieSessionGet('ip window');

% Get the data
% ieInWindowMessage('Select image region of interest.',app,[]);
[roiLocs, rect] = ieROISelect(ip);
RGB     = vcGetROIData(ip,roiLocs,'result');
% ieInWindowMessage('',app,[]);

%% Plot the data

figHdl =  ieNewGraphWin;
uData.rect = rect;

switch lower(dataType)
    case {'rgb','rgbhistogram'}
        colorlist = {'r','g','b'};
        for ii=1:3
            % The individual panels
            subplot(1,3,ii); 
            nBins = round(max(20,size(RGB,1)/25));
            thisH = histogram(RGB(:,ii),nBins);
            thisH.FaceColor = colorlist{ii};
            thisH.EdgeColor = colorlist{ii};
            grid on
        end
        % Label the edge cases
        subplot(1,3,1); ylabel('Count');
        subplot(1,3,2); xlabel('Pixel value');
        mn = mean(RGB);
        title(sprintf('RGB histograms; mean = (%.1f,%.1f,%.1f)',mn(1),mn(2),mn(3)));
        uData.RGB = RGB;

    case {'rgb3d'}
        plot3(RGB(:,1),RGB(:,2),RGB(:,3),'.');
        xlabel('R'); ylabel('G'); zlabel('B');
        grid on;
        title('RGB (result)');
        uData.RGB = RGB;
        
    case {'xy','chromaticity'}
        dataXYZ = imageRGB2XYZ(ip,RGB);
        xy = chromaticity(dataXYZ);
        
        % Gray background, res of 256, do not start a new figure
        chromaticityPlot(xy,'gray',256,false);

        % plotSpectrumLocus(figNum); hold on;
        hold on
        plot(xy(:,1),xy(:,2),'ko'); 
        grid on;
        
        title('CIE (1931) chromaticities');
        xlabel('x-chromaticity'); ylabel('y-chromaticity');
        axis square;

        meanXYZ = mean(dataXYZ);
        
        txt = sprintf(' Mean XYZ \nX = %.02f\nY = %.02f\nZ = %.02f',meanXYZ(1),meanXYZ(2),meanXYZ(3));
        plotTextString(txt,'ur');
        
        uData.xy = xy; uData.XYZ = dataXYZ;
        
    case 'luminance'
        
        dataXYZ = imageRGB2XYZ(ip,RGB);
        luminance = dataXYZ(:,2);
        
        histogram(luminance(:)); grid on;
        xlabel('Luminance (cd/m^2)'); ylabel('Count'); title('Luminance (CIE 1931 Y)');
        set(gca,'xlim',[max(0,0.*min(luminance(:))), max(luminance(:))*1.1]);
        mnL = mean(luminance);
        stdL = std(luminance);
        txt = sprintf('Mean: %.02f\nSD:   %.03f\nSNR (db)=%.03f',mnL,stdL,20*log10(mnL/stdL));
        plotTextString(txt,'ul');

        uData.luminance = luminance;
        uData.meanL = mnL;
        uData.stdLum = stdL;
        
    case 'cielab'
        % Needs updating
        dataXYZ  = ipGet(ip,'roi xyz',roiLocs);
        whitepnt = ipGet(ip,'data or Display WhitePoint');
        dataLAB = ieXYZ2LAB(double(dataXYZ),double(whitepnt));
        plot3(dataLAB(:,2), dataLAB(:,3),dataLAB(:,1), 'o');
        set(gca,'xlim',[-80 80],'ylim',[-80 80],'zlim',[0,100]);
        grid on; axis square
        
        xlabel('a*'); ylabel('b*'); zlabel('L*');
        title('CIELAB values of selected region');
        
        txt = sprintf('Mean: [%.02f,%.02f,%.02f]\n',mean(dataLAB));
        plotTextString(txt,'ul');
        
        uData = dataLAB;
        
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
        
        uData = dataLUV;
        
    otherwise
        error('Unknown plot display data type.')
end

% Draw the ROI on the window
% ieROIDraw(ip,'shape','rectangle','shape data',rect);

% Store the data
set(figHdl,'Userdata',uData);
hold off

end
