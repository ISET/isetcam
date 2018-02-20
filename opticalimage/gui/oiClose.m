function oiClose
%OICLOSE  -  Close optical image window
%
%    oiClose
%
% Close window function for optical image and remove figure handle from
% vcSESSION structure.
%
% Copyright ImagEval Consultants, LLC, 2003.

global vcSESSION;

if checkfields(vcSESSION,'GUI','vcOptImgWindow')
    vcSESSION.GUI = rmfield(vcSESSION.GUI,'vcOptImgWindow');
end
closereq;

return;