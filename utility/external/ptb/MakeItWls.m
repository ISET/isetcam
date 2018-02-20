function wls = MakeItWls(S)
% wls = MakeItWls(S)
%
% If argument is a [start delta n] description or
% a struct with fields start, step, numberSamples,
% it is  expanded to an actual list of wavelengths.
% 
% A passed list of wavelengths is left alone.
%
% 7/27/02  dhb  Handle struct format too by calling MakeItS first.

S = MakeItS(S);
wls = SToWls(S);
