function vci = vcimageClearData(vci)
% Clear data from vcimage structure
%
%   vci = vcimageClearData(vci)
%
% Purpose:
%    The data field in an image is set to empty.  
%
% Copyright ImagEval Consultants, LLC, 2005.

vci = ipSet(vci,'data',[]); 

return;