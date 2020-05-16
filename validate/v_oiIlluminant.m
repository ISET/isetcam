%% Check the oi illuminant functions
%
%  We sometimes include illuminant in the OI when we render a 3D scene with
%  PBRT (ISET3D).  Typically these are spatial-spectral illuminants
%
% See also
%   oiIlluminantSS, oiIlluminantPattern, sceneIlluminantSS,
%   sceneIlluminantPattern
%

%%
ieInit;
oi = oiCreate;
thisI = illuminantCreate;

%%
oi = oiSet(oi,'illuminant',thisI);
testI = oiGet(oi,'illuminant');
assert(isequal(thisI,testI));

%%  This reads the data in the illuminant and reports the format

oiGet(oi,'illuminant format')


%% END


