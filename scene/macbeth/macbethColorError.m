function [macbethLAB, macbethXYZ, dE, vci] = macbethColorError(vci,illName,cornerPoints,method)
% Analyze color error of a MCC in the image processor window
%
%  [macbethLAB, macbethXYZ, deltaE, vci] = ...
%        macbethColorError(vci,illName,cornerPoints,method)
%
% The user interactively identifies the position of the MCC in the image
% processor window. This routine analyzes the RGB MCC data and plots the
% results.  The analyses are
%
%  - Comparisons of the data and ideal CIELAB values
%  - A histogram of delta E values between the data and ideal
%  - Comparisons of the gray series L* values
%  - Comparisons of the chromaticity (xy) values
%
% vci:     An image processor structure from ISET containing the processed
%          MCC. ON the return, the corner points of the MCC are stored in
%          the structure.
% illName:      The illuminant assumed for the MCC
% cornerPoints: A rect defining the outer points of the MCC.  The order of
%               the outer corners is white, gray, blue, brown
% method:   This defines the color space of the vci image data in the
%           result field. Default 'sRGB'.  You can set method = 'custom'
%           to use the monitor model stored in the vci.
%
% Example:
%   ip = vcGetObject('ip');
%   [macbethXYZ, whiteXYZ] = ipMCCXYZ(vci);
%
% Copyright ImagEval Consultants, LLC, 2003.

% Programming notes:  Could add display gamut to chromaticity plot

%% Check variables
if ieNotDefined('vci'),     vci = vcGetObject('vcimage'); end
if ieNotDefined('illName'), illName = 'd65'; end
if ieNotDefined('method'),  method = 'sRGB'; end

% Positions of key patches
whiteIndex = 4;
gSeries = 4:4:24;

%% Get the rectangle positions

% cornerPoints has the coordinates of the corners of the MCC. If the user
% sent them in, don't bother them.  But, if the parameter is empty or
% undefined, then we swing into action.
if ieNotDefined('cornerPoints')
    % First, check whether there are cornerpoints attached to the object.
    % If there aren't, the user is queried in vcimageMCCXYZ, below.
    cornerPoints = ipGet(vci,'chart corner points');
    
    % But, if there are cornerpoints, check them here.
    if ~isempty(cornerPoints)
        % Ask the user if a change is desired.  The current ones may not be
        % satisfactory.
        macbethDrawRects(vci,'on');
        b = ieReadBoolean('Are these rects OK?');
        if b % Do nothing, we are good.  Just turn off rects
            macbethDrawRects(vci,'off');
        else
            % Set the cornerPoints to empty and let vcimageMCCXYZ handle
            % the situation, below
            cornerPoints = [];
            vci = ipSet(vci,'mcc corner points',cornerPoints);
            macbethDrawRects(vci,'off');
        end
    else
        % There were no corner points.  So, the user must be asked.
    end
end

%% Retrieve ideal and image MCCdata LAB and XYZ values

% These are Processor window XYZ values using the monitor model.  They are
% computed using a model monitor with peak luminance of Y = 1 cd/m2.
[macbethXYZ, whiteMacbethXYZ, cornerPoints] = ipMCCXYZ(vci,cornerPoints,method);
vci = ipSet(vci,'chart corner points',cornerPoints);
macbethDrawRects(vci,'on');        % Make sure we have ther rects
pause(1)
macbethDrawRects(vci,'off');  % Now turn it all off

% The idealXYZ values of the MCC
idealXYZ = macbethIdealColor(illName,'xyz');

%   macbethsRGB = xyz2srgb(reshape(idealXYZ,4,6,3));
%   vcNewGraphWin; image(macbethsRGB);

% This is the white surface
whiteIdealXYZ = idealXYZ(whiteIndex,:);

% The max ideal luminance is whiteXYZ(2), so we scale by this quantity to
% put idealXYZ and macbethXYZ in the same range.
macbethXYZ = (macbethXYZ/whiteMacbethXYZ(2))*whiteIdealXYZ(2);
whiteMacbethXYZ = macbethXYZ(whiteIndex,:);

% vcNewGraphWin; plot(macbethXYZ(:),idealXYZ(:),'.')
% axis equal, grid on

% %% Initialize figure
% macbethEvaluationGraphs(L,rgb,idealRGB,sName);

vcNewGraphWin([],'upperleft big'); clf;
set(gcf,'name',sprintf('VCIMAGE: %s',ipGet(vci,'name')))

%% LAB positions of the patches
subplot(2,2,1),
idealLAB   = ieXYZ2LAB(idealXYZ,whiteIdealXYZ);
macbethLAB = ieXYZ2LAB(macbethXYZ,whiteMacbethXYZ);

plot(macbethLAB(:,2),macbethLAB(:,3),'o')
line([idealLAB(:,2),macbethLAB(:,2)]',...
    [idealLAB(:,3),macbethLAB(:,3)]');

xlabel('a (red-green)'); ylabel('b (blue-yellow)')
grid on; axis square
title('CIELAB color plane')

%% Show histogram of delta E errors
subplot(2,2,2)

% We compute the delta E difference between the data and the ideal
dE = deltaEab(macbethXYZ,idealXYZ,whiteIdealXYZ);
histogram(dE); grid on; axis square
title(sprintf('Mean deltaE = %.2f',mean(dE)));

%% Show the gray series L* values
subplot(2,2,3)
plot(1:6,macbethLAB(gSeries,1),'-o',1:6,idealLAB(gSeries,1),'x');
xlabel('Gray patch'); ylabel('L*');  axis square; grid on;
title('Achromatic series')

%% Lines between chromaticities of the ideal and current Processor data

subplot(2,2,4)

% Exclude very black surfaces from chromaticity plot.
list = find(macbethXYZ(:,2) > 0.01);
xy   = chromaticity(macbethXYZ(list,:));
chromaticityPlot(xy,'gray',256,0);

% Draw little lines to the ideal position
hold on;
idealxy = chromaticity(idealXYZ(list,:));
line([idealxy(:,1),xy(:,1)]',[idealxy(:,2),xy(:,2)]');

%% Store the data in the figure
uData.macbethXYZ =  macbethXYZ;
uData.macbethLAB = macbethLAB;
uData.idealLAB   = idealLAB;
uData.deltaE     = dE;

set(gcf,'userdata',uData);

return;