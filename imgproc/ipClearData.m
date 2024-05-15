function vci = ipClearData(vci)
% Clear data from image processor structure
%
%   vci = ipClearData(vci)
%
% The data field in an image is set to empty.
%
% Copyright ImagEval Consultants, LLC, 2005.

vci = ipSet(vci,'data',[]);

end
