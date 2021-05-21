function optics = opticsClearData(optics)
%Clear OTF and cos4th data from optics.
%
%   obj = opticsClearData(obj)
%
% Clear the data from the optics fields after one of the optics parameters
% has been changed.
%
% The input object can be either an optical image or an optics
% object.
%
% Examples:
%
%
% Copyright ImagEval Consultants, LLC, 2003.

% Clear cahced OTF data
optics = opticsSet(optics,'OTF data',[]);

% Sometimes we have a lot of cos4th data.
optics = opticsSet(optics,'cos4th data',[]);

end