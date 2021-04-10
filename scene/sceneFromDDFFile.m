function [scene,fName] = sceneFromDDFFile(fName, imType, meanLuminance, dispCal, ...
    wList, varargin)
%SCENEFROMDDFFILE Summary of this function goes here
%   Detailed explanation goes here

% First we call the basic scene creation routine
% it should probably take depth as a parameter, but it seems to have 
% a lot of other legacy parameter stuff, so doing it here for now
if ~exist('meanLuminance', 'var')
    meanLuminance = [];
end
if ~exist('imType', 'var')
    imType = 'rgb';
end
if ~exist('dispCal', 'var')
    dispCal = []; 
end
if ~exist('wList', 'var')
    wList = [400:10:700];
end

tic
scene = sceneFromFile(fName, imType, meanLuminance, dispCal, ...
    wList, varargin{:});
toc

% right now we only support depth that is compatible with Google's approach
depthMap = exiftoolDepthFromFile(fName, 'type', 'GooglePixel');
if ~isempty(depthMap)
    scene = sceneSet(scene, 'depth map', depthMap);
end

end

