function [ip, yNoise, mRGB] = macbethLuminanceNoise(ip,cp)
% Analyze luminance noise in gray series of MCC from image processor window
%
% Synopsis
%  [ip, yNoise,mRGB] = macbethLuminanceNoise(ip)s
%
% Inputs:
%  ip:       image process structure
%  pointLoc:  Macbeth point locations 
% 
% Outputs:
%  ip:      Has corner points attached
%  yNoise:  Luminance noise
%  mRGB:    Linear RGB values of the display
%
% See also

% TODO
% Programming notes:  Could add display gamut to chromaticity plot

%% Arguments
if ieNotDefined('ip'),ip = vcGetObject('vcimage'); end
if ieNotDefined('cp'), cp = []; end

%% Find the patches and the mean RGB values
if isempty(cp)
    cp = ipGet(ip,'chart corner points');
    if isempty(cp)
        % Ask the user to select
        cp = chartCornerpoints(ip);
        ip = ipSet(ip,'chart corner points',cp);
    end
end

%% Create the rectangles, draw, and get the data
[rects,mLocs,pSize] = chartRectangles(cp,4,6,0.5);
chartRectsDraw(ip,rects);
fulldata = true;
mRGB = chartRectsData(ip,mLocs,0.6*pSize(1),fulldata);

%% Compute the std dev and mean for each gray series patch.  

% The ratio is the contrast noise.
jj = 1;
gSeries = 4:4:24;
yNoise = zeros(1,length(gSeries));
for ii = gSeries
    rgb = mRGB{ii};
    % Convert linear RGB values of the display to XYZ and then luminance
    macbethXYZ = imageRGB2XYZ(ip,rgb);
    Y = macbethXYZ(:,2);
    
    % Calculate noise
    yNoise(jj) = 100*(std(Y)/mean(Y));
    jj = jj+1;
end

%% Show it
ieNewGraphWin;
str = sprintf('%s: MCC luminance noise',ipGet(ip,'name'));
set(gcf,'name',str);
plot(yNoise,'ro-');
line([1 6],[3 3],'Color','k','Linestyle','--','LineWidth',2)
grid on
xlabel('Gray patch (white to black)')
ylabel('Luminance noise (sd(Y)/mean(Y)) x 100');
legend({'data','1000 photon (33 db) '},'Location','NorthWest')

end

