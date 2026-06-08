function tests = test_oiPinhole()
tests = functiontests(localfunctions);
end

function testMain(~)
% Pinhole testing
%
% The oiCreate 'pinhole' means 'skip' the optics.  We compare the oi
% and scene when 'skip' is set and when we are diffraction limited for
% the same parameters.
%
%

%%
ieInit;
tolerance = 1e-4;

%% Diffraction limited optics blurs this image

scene = sceneCreate('macbethd65',64);
scene = sceneSet(scene,'fov',1);

oi = oiCreate('default');
oi = oiCompute(oi,scene,'crop',true);
dlPhotons = oiGet(oi,'photons');
dlIlluminance = oiGet(oi,'illuminance');

%% Pinhole sets the optics model to 'skip'

% With pinhole, there is no blurring.  Also, for some reason, no
% padding. I guess the padding takes place as part of the
% blurring/optics calculation.

oi = oiCreate('pinhole');
oi = oiCompute(oi,scene);
phPhotons = oiGet(oi,'photons');
phIlluminance = oiGet(oi,'illuminance');

%% If we set the optics model to diffraction limited ...
oi = oiSet(oi,'optics model','diffractionlimited');
oi = oiCompute(oi,scene,'crop',true);
phdlPhotons = oiGet(oi,'photons');
phdlIlluminance = oiGet(oi,'illuminance');

assert(isequal(size(dlPhotons),[256 384 31]));
assert(isequal(size(phPhotons),[256 384 31]));
assert(isequal(size(phdlPhotons),[256 384 31]));

assert(abs(mean(dlIlluminance,'all')/4.54423093795776 - 1) < tolerance);
assert(abs(mean(phIlluminance,'all')/314.153411865234 - 1) < tolerance);
assert(abs(mean(phdlIlluminance,'all')/297.799926757812 - 1) < tolerance);

assert(abs(sum(dlPhotons,'all')/5.21679038919063e+20 - 1) < tolerance);
assert(abs(sum(phPhotons,'all')/3.60198709488239e+22 - 1) < tolerance);
assert(abs(sum(phdlPhotons,'all')/3.41861358810503e+22 - 1) < tolerance);

assert(abs(mean(dlPhotons(120:140,120:140,:),'all')/1.46083573530097e+14 - 1) < tolerance);
assert(abs(mean(phPhotons(120:140,120:140,:),'all')/9.59895535871931e+15 - 1) < tolerance);
assert(abs(mean(phdlPhotons(120:140,120:140,:),'all')/9.55990075279266e+15 - 1) < tolerance);

assert(mean(phIlluminance,'all') > mean(phdlIlluminance,'all'));
assert(mean(phdlIlluminance,'all') > mean(dlIlluminance,'all'));

%% END
end
