function [row,col] = space2sample(rMicrons,cMicrons,pixelHeight,pixelWidth)
% Convert spatial position (microns) into sample position 
%
%   [row,col] = space2sample(rMicrons,cMicrons,pixelHeight,pixelWidth)
%
%  This routine inverts sample2space.
%
%Example:
%  [row,col] = ...
%          space2sample(rMicrons,cMicrons, ...
%                       sceneGet(oi,'hres'),sceneGet(oi,'wres'))  
% [X,Y] = meshgrid(cMicrons,rMicrons);
%
% OBSOLETE
%
% Copyright ImagEval Consultants, LLC, 2005.

disp('obsolete');

% tmp = (1 - 1/2 + rMicrons/pixelHeight); 
% row = tmp + max(tmp(:));
% tmp = (1 - 1/2 + cMicrons/pixelWidth);  
% col = tmp + max(tmp(:));

tmp = rMicrons/pixelHeight; % rescaling
row = tmp - tmp(1); % assuming samples are starting at 0;
tmp = cMicrons/pixelWidth;
col = tmp - tmp(1);

return;
