function [yNoise,mRGB] = macbethLuminanceNoise(vci,pointLoc)
% Analyze luminance noise in gray series of MCC fromimage processor window
%
%   [yNoise,mRGB] = macbethLuminanceNoise(vci)s
%
% vci:  image process structure
% pointLoc:  Macbeth point locations 
% 
% yNoise:  Luminance noise
% mRGB:    Linear RGB values of the display
%
% Copyright ImagEval Consultants, LLC, 2003.

% Programming notes:  Could add display gamut to chromaticity plot

%% Arguments
if ieNotDefined('vci'),vci = vcGetObject('vcimage'); end
if ieNotDefined('pointLoc'), pointLoc=[]; end

%% Return the full data from all the patches
mRGB = macbethSelect(vci,0,1,pointLoc);

% Compute the std dev and mean for each patch.  The ratio is the contrast
% noise.
jj = 1;
gSeries = 4:4:24;
yNoise = zeros(1,length(gSeries));
for ii = gSeries
    rgb = mRGB{ii};
    % Convert linear RGB values of the display to XYZ and then luminance
    macbethXYZ = imageRGB2XYZ(vci,rgb);
    Y = macbethXYZ(:,2);
    
    % Calculate noise
    yNoise(jj) = 100*(std(Y)/mean(Y));
    jj = jj+1;
end

%% Show it
vcNewGraphWin;
str = sprintf('%s: MCC luminance noise',ipGet(vci,'name'));
set(gcf,'name',str);
plot(yNoise);
line([1 6],[3 3],'Linestyle','--')
grid on
xlabel('Gray patch (white to black)')
ylabel('Percent luminance noise (std(Y)/mean(Y))x100');
legend({'data','1000 photon (33 db) '},'Location','NorthWest')

return;

