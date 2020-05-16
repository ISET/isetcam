%% Check the oi illuminant functions
%
%  We sometimes include illuminant in the OI when we render a 3D scene with
%  PBRT (ISET3D).  Typically these are spatial-spectral illuminants
%


%%
ieInit;
oi = oiCreate;
thisI = illuminantCreate;

%%
oi = oiSet(oi,'illuminant',thisI);
testI = oiGet(oi,'illuminant');
assert(isequal(thisI,testI));

%%
oiGet(oi,'illuminant format')

oiSet(oi,'illuminant format','spatial spectral')




