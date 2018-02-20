function unitBlock = sensorUnitBlock(ISA,colorOrder)
% ****OBSOLETE ****
% Create a spatial unit block of a color filter array
%
%     unitBlock = sensorSetUnitBlock(ISA,colorOrder)
%
% The spatial unit block of the image sensor array is defined by a small,
% unit block, that makes up the basic component of a larger array.  The
% basic configurations are 
%
% Monochrome
% Bayer 1223  (e.g., rggb)
% Bayer 2132  (e.g., grbg)
% Four Color  (e.g., cmyg)
%
% unitBlock.config:
%   1st column : x coordinates
%   2nd column : y coordinates
%
% At one time, we allowed the pixel positions to be arbitrary.  At present
% we only support rectangular arrays.  We plan to add a transformation to
% non-rectangular representations.  This transformation is not yet
% implemented. 
%
% Copyright ImagEval Consultants, LLC, 2003.

disp('Obsolete')
evalin('caller','mfilename')
return;
