function wlstruct = MakeItStruct(S)
% wlstruct = MakeItStruct(S)
% 
% Convert a wavelength representation to struct format.
%
% See also: MakeItS, MakeItWls, WavelengthSamplingTest.
%
% 7/11/03  dhb  Wrote it.

S = MakeItS(S);
wlstruct.start = S(1);
wlstruct.step = S(2);
wlstruct.numberSamples = S(3);
