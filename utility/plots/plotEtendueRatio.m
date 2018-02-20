function plotEtendueRatio(ISA,optimal,bare,zLabel)
%Plot etendue ratio at the pixels across the sensor array
%
%   plotEtendueRatio(ISA,optimal,bare,zLabel)
%
%  The etendue ratio between two optics conditions is a measure of the
%  relative optical efficiency between those conditions. This routine takes
%  the two optical conditions, optimal microlens placement and no
%  microlens, and summarizes their etendue ratios in a mesh graph.
%
%  showing the sensor etendue stored in the ISA structure. 
%  The etendue is usually computed using mlAnalyzeArrayEtendue.
%
% Copyright ImagEval Consultants, LLC, 2003.

% I wonder if we need to adjust the ISA pixel width to match the microlens?
if ieNotDefined('ISA'), ISA = vcGetObject('ISA'); end
if ieNotDefined('optimal'), error('Etendue for optimal placement required.'); end
if ieNotDefined('optimal'), error('Etendue for no microlens required.'); end
if ieNotDefined('zLabel'), zLabel = 'Etendue improvement (%)'; end

% Make a figure showing the etendue across the array.  The units of the
% support are unclear to me at this moment.
figNum = vcSelectFigure('GRAPHWIN');
plotSetUpWindow(figNum);
set(figNum,'name','ISET:  Etendue ratio');

support = sensorGet(ISA,'spatialSupport','microns');
r = (optimal./bare - 1)*100;
mesh(support.x,support.y,r);
colormap(hot(128))
xlabel('Position (um)'); ylabel('Position (um)');
zlabel(zLabel);

uData.support = support;
uData.Ratio = r;

set(figNum,'userdata',uData);

return;
