function dPos = oiSpace(oi,sPos,unit)
% Convert sample positions in the oi to distance positions in spatial units
% 
%   dPos = oiSpace(oi,sPos,unit)
%
% oi:     Optical image
% sPos:   Sample positions, (row,col)
% unit:  'mm','um', and so forth
%
% dPos:   The position in units, where the center of the OI is (0,0). Up
%         and right are positive 
%
% Example
%   scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
%   sPos = [1, 1];  oiSpace(oi,sPos,'mm')
%   oiGet(oi,'height and width','mm')
%
% Imageval Consulting, LLC 2014

if ~exist('unit','var') || isempty(unit), unit = 'mm'; end

dPerSamp = oiGet(oi,'distance per sample',unit);
sz       = oiGet(oi,'size');
middle   = sz/2;

dPos(1) = (middle(1) - sPos(1)) * dPerSamp(1);
dPos(2) = (sPos(2) - middle(2)) * dPerSamp(2);

end
