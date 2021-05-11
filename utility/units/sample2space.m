function [rMicrons, cMicrons] = sample2space(rSamples, cSamples, rowDelta, colDelta)
%The physical position of samples in a scene or optical image
%
% Syntax:
%   [rMicrons,cMicrons] = sample2space(rSamples,cSamples,rowDelta,colDelta)
%
% Given a number of row and column samples (rSamples and cSamples) and
% a spacing between the rows and columns (rowDelta and colDelta)
% return the full sampling grid in the units of rowDelta and colDelta.
% These are usually in units of microns for these sensor applications.
%
% We treat the center of the samples as (0,0) and use the sampling spacing
% in microns to calculate the location of the other samples.
%
% Weak terminology
%   hres is Height Resolution; (Not horizontal resolution)
%   wres is Width resolution
%
% Calculate the positions of every pixel this way:
%    [X,Y] = meshgrid(cMicrons,rMicrons);
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also:
%

% Examples:
%{
cSamples = [1:64]; rSamples = [1:64];  %
rowDelta = 5; colDelta = 5;                  % In microns

[rMicrons,cMicrons] = sample2space(rSamples,cSamples, rowDelta,colDelta)
%}
%{
scene = sceneCreate;
oi = oiCreate; oi = oiCompute(oi,scene);
rSamples = 1:oiGet(oi,'rows');
cSamples = 1:oiGet(oi,'cols');
[rMicrons,cMicrons] = sample2space(rSamples,cSamples, ...
    oiGet(oi,'hres'),oiGet(oi,'wres'));
disp(rMicrons)
[U,V] = meshgrid(rMicrons,cMicrons);
ieNewGraphWin;
plot(U(:),V(:),'.');
%}

%% Main code

% Normally, the samples are row or col position 1:N; in this routine and we
% calculate assigning them positions 0:(N-1).

% Find the center.
% this is faster
%   rCenter = max(rSamples(:))/2;
%   cCenter = max(cSamples(:))/2;
% But this stays correct even if the positions start at 1
rCenter = mean(rSamples(:));
cCenter = mean(cSamples(:));

% rMicrons = ((rSamples - 1) - rCenter + 1/2)*rowDelta;
% cMicrons = ((cSamples - 1) - cCenter + 1/2)*colDelta;

rMicrons = (rSamples - rCenter) * rowDelta;
cMicrons = (cSamples - cCenter) * colDelta;

end
