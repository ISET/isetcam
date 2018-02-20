function [rMicrons,cMicrons] = sample2space(rSamples,cSamples,rowDelta,colDelta)
%The physical position of samples in a scene or optical image
%
%   [rMicrons,cMicrons] = sample2space(rSamples,cSamples,rowDelta,colDelta)
%
% We treat the center of the samples as (0,0) and use the sampling spacing
% in microns to calculate the location of the other samples. 
%
%Example:
%  [rMicrons,cMicrons] = ...
%          sample2space(sceneGet(oi,'rows'),sceneGet(oi,'cols'), ...
%                       sceneGet(oi,'hres'),sceneGet(oi,'wres'));
% Unfortunate terminology
%   hres is Height Resolution; 
%   wres is Width resolution
%
% Calculate the positions of every pixel this way:
%    [X,Y] = meshgrid(cMicrons,rMicrons);
%
% cSamples = [1:.2:64];
% rSamples = [1:.2:64];
% rowDelta = 5;
% colDelta = 5;
% [rMicrons,cMicrons] = sample2space(rSamples,cSamples, rowDelta,colDelta)  
%
% Copyright ImagEval Consultants, LLC, 2005.

% Normally, the samples are row or col position 1:N; in this routine and we
% calculate assigning them positions 0:(N-1). 

% Find the center.
% this is faster
% rCenter = max(rSamples(:))/2; 
% cCenter = max(cSamples(:))/2;
%but this stays correct even if the positions start at 1
rCenter = mean(rSamples(:));
cCenter = mean(cSamples(:));

% rMicrons = ((rSamples - 1) - rCenter + 1/2)*rowDelta;
% cMicrons = ((cSamples - 1) - cCenter + 1/2)*colDelta;

rMicrons = (rSamples - rCenter)*rowDelta;
cMicrons = (cSamples - cCenter)*colDelta;
return;

