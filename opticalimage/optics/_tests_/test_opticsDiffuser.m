function tests = test_opticsDiffuser()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_diffuser
%
% See oiDiffuser for how to set up the 2D diffusing  An example from the
% header to that file is here:
%
%   oi = oiCreate; scene = sceneCreate; scene = sceneSet(scene,'fov',1);
%   oi = oiCompute(scene,oi);
%   % SD units are FWHM microns,
%   [oi,sd,blurFilter] = oiDiffuser(oi,[10,2]);
%   [X,Y] = meshgrid(1:size(blurFilter,2),1:size(blurFilter,1));
%   wSpatialRes = oiGet(oi,'widthSpatialResolution','microns');
%   X = X*wSpatialRes;  Y = Y*wSpatialRes;
%   X = X - mean(X(:)); Y = Y - mean(Y(:));
%   figure(1); mesh(X,Y,blurFilter);
%
% Copyright ImagEval Consultants, LLC, 2009

%%
ieInit

%% Example of setting up the multi-dimensional diffusion calculation.

% Build a Macbeth color checker.
scene = sceneCreate;
scene = sceneSet(scene,'fov',1);
oi = oiCreate;

oi = oiSet(oi,'diffuser Method','blur');
oi = oiSet(oi,'diffuser Blur',[6,2]*1e-6);  %Units are meters.
oi = oiCompute(oi,scene);
first = oiGet(oi,'photons');

% Rotate the diffusing blur direction.
oi = oiSet(oi,'diffuserBlur',[2,6]*1e-6);  %Units are meters.

oi = oiCompute(oi,scene);
second = oiGet(oi,'photons');
testCase.verifySize(second,size(first));
testCase.verifyGreaterThan(norm(double(first(:))-double(second(:))),0);
testCase.verifyEqual(double(sum(first,'all')),3.33050540968185e19,'RelTol',1e-6);
testCase.verifyEqual(double(sum(second,'all')),3.40119465833496e19,'RelTol',1e-6);

%% END
end
