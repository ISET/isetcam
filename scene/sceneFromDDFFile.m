function [scene,fName] = sceneFromDDFFile(fName, imType, meanLuminance, dispCal, ...
    wList, varargin)
%SCENEFROMDDFFILE Summary of this function goes here
%   Detailed explanation goes here

% First we call the basic scene creation routine
% it should probably take depth as a parameter, but it seems to have 
% a lot of other legacy parameter stuff, so doing it here for now
scene = sceneFromFile(fName, imType, meanLuminance, dispCal, ...
    wList, varargin{:});

% right now we only support depth that is compatible with Google's approach
depthMap = exiftoolDepthFromFile(fName, 'type', 'GooglePixel');

% NEED TO DECIDE IF DEPTHMAP IS ALREADY METERS HERE, OR IS A JPEG???
%depthImage = imload(depthmap);

scene = sceneSet(scene, 'depth map', depthMap);


end

