function CalToggleBitsPlusPlus(enableBitsPP)
% CalToggleBitsPlusPlus(enableBitsPP)
%   This function toggles the use of Bits++ in the calibration functions.
%   Currently, this is only a temporary way of doing things until the Bits++
%   code built into Screen is tested more.
%
%   'enableBitsPP' is a true/false value that turns on/off Bits++
%   functionality in the Calibrate functions.

global g_usebitspp;

if nargin ~= 1
    error('Usage: CalToggleBitsPlusPlus(enableBitsPP)');
end

g_usebitspp = enableBitsPP;
