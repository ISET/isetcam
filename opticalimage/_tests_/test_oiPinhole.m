function tests = test_oiPinhole()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
% Pinhole testing
% 
% The oiCreate 'pinhole' means 'skip' the optics.  We compare the oi
% and scene when 'skip' is set and when we are diffraction limited for
% the same parameters.
%
%

%%
ieInit;

%% Diffraction limited optics blurs this image

scene = sceneCreate('macbethd65',64);
scene = sceneSet(scene,'fov',1);

oi = oiCreate('default');
oi = oiCompute(oi,scene,'crop',true);
oiWindow(oi);

%% Pinhole sets the optics model to 'skip'

% With pinhole, there is no blurring.  Also, for some reason, no
% padding. I guess the padding takes place as part of the
% blurring/optics calculation.

oi = oiCreate('pinhole');
oi = oiCompute(oi,scene);

sceneWindow(scene);
oiWindow(oi);

%% If we set the optics model to diffraction limited ...
oi = oiSet(oi,'optics model','diffractionlimited');
oi = oiCompute(oi,scene,'crop',true);
oiWindow(oi);

%% END
end
