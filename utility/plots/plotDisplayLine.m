function [uData,figNum] = plotDisplayLine(ip,ori,xy)
% Graph the values across a line in the ipWindow
%
% Synopsis
%   [uData,figNum] = plotDisplayLine([ip], [ori = 'h'], [xy])
%
% Brief description:
%  Call this routine from the ipPlot method, not directly.
%
%  The line plot must pass through a point xy selected by the user.  The
%  line orientation (h or v) ori, is passed as a calling argument (ORI).
%  Monochrome and color data are handled in various ways.
%   
%  The plotted values are attached the graph window and can be obtained
%  using a data = get(figNum,'userdata') call.
%
% Inputs:
%   ip    - image processing struct
%   ori   - orientation of the line
%   xy    - a point on the line
%
% Outputs
%   uData - struct with position, values, xy and ori
%  
% Examples:
%    figNum = plotDisplayLine(ip,'h')
%    figNum = plotDisplayLine(ip,'h',[1,1])
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   ipPlot, sensorPlot, oiPlot, scenePlot

%% Params

if ieNotDefined('ip'),    ip = vcGetObject('VCIMAGE'); end
if ieNotDefined('ori'),    ori = 'h'; end
if ieNotDefined('xy')
    % Find the line in the sensor window.
    switch lower(ori)
        case 'h'
            message = 'Select horizontal line';
        case 'v'
            message = 'Select vertical line';            
        otherwise
            error('Unknown orientation')
    end
    pointLoc = iePointSelect(ip,message,1);
    xy = round(pointLoc);
end

%% Call main routine

data = ipGet(ip,'quantized result');
if isempty(data), error('Results not computed in display window.'); end

[figNum, uData] = plotColorDisplayLines(xy,data,ori);

%% Draw a line on the ipWindow
switch ori
    case 'h'
        % See also ieDrawShape
        sz = ipGet(ip,'size');
        ieROIDraw(ip,'shape','line','shape data',[1 sz(2) xy(2) xy(2)]);
    case 'v'
        % See also ieDrawShape
        sz = ipGet(ip,'size');
        ieROIDraw(ip,'shape','line','shape data',[xy(1) xy(1) 1 sz(1)]);
end

end

%% -----------------------------
function [figNum, uData] = plotColorDisplayLines(xy,data,ori)
% Internal routine:  plot color line data from display data
%

dType = 'digital';
if max(data(:)) <=1, dType = 'analog'; end
    
switch lower(ori)
    case {'h','horizontal'}
        lData = squeeze(data(xy(2),:,:));
        titleString =sprintf('ISET:  Horizontal line %.0f',xy(2));
        xstr = 'Col number';
    case {'v','vertical'}
        lData = squeeze(data(:,xy(1),:));
        titleString =sprintf('ISET:  Vertical line %.0f',xy(1));
        xstr = 'Row number';
    otherwise
        error('Unknown line orientation');
end

figNum = vcNewGraphWin([],'tall');

% Extract the data and assign a line color corresponding to the cfa color.
pos = 1:size(lData,1);
colordef = {'r-','g-','b-'};
for ii=1:3
    subplot(3,1,ii)
    plot(pos,lData(:,ii),colordef{ii},'linewidth',1)
    grid on; set(gca,'xlim',[pos(1), pos(end)]);
    xlabel(xstr);
    switch dType
        case 'digital'
            ylabel('Digital value');
        case 'analog'
            ylabel('Value')
    end
    if ii==1,  title(titleString); end
end

% Store and attach data
uData.xy  = xy;
uData.ori = ori;
uData.pos = pos;
uData.values = lData;
set(gcf,'userdata',uData);

% Figure label 
set(gcf,'NumberTitle','off');
set(gcf,'Name',titleString);

end
