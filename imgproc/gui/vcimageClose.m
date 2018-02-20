function displayClose
%
% Author: ImagEval
% Purpose:
%    Close window function for DISPLAY.

global vcSESSION;

if checkfields(vcSESSION,'GUI','vcImageWindow')
    vcSESSION.GUI = rmfield(vcSESSION.GUI,'vcImageWindow');
end

closereq;

return;