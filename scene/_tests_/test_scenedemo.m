function tests = test_scenedemo()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
% Test simple scene create values

%%
ieInit;

% We validate some of the ISET calculations by the numerical tolerance
tolerance = 1e-5;

%% sceneCreate

% To create a simple spectral scene of a Macbeth Chart  under a
% D65 illuminant, we use
%
sceneMacbethD65 = sceneCreate('macbethd65');

%% sceneGet

% To manipulate the data in a scene, you can extract variables
% sceneGet(sceneMacbethD65,'meanLuminance');

% To access directly the photons in the image, do this:
photons = sceneGet(sceneMacbethD65,'photons');

% The values are big because they are photons emitted per second
% per wavelength per steradian per meter from the scene
assert( abs(max(photons(:))/ 1.3119e+16 - 1) < tolerance,'Max photon error');

% Suppose we compute the mean number of photons across the entire
% image
meanPhotons = mean(photons,1);  meanPhotons = mean(meanPhotons,2);
meanPhotons = squeeze(meanPhotons);
assert(abs(mean(meanPhotons(:)) / 3.7624e+15 - 1) < tolerance,'Mean photon error');

%% sceneDescriptions

% To see a general description of the scene, the one printed in
% the upper right of the window, we use this
txt = sceneDescription(sceneMacbethD65);
assert(ischar(txt));

% Many other quantites can be stored or derived, such as the
% horizontal field of view in degrees
fov = sceneGet(sceneMacbethD65,'fov');

% To change the field of view
sceneMacbethD65 = sceneSet(sceneMacbethD65,'fov',20);
assert(sceneGet(sceneMacbethD65,'fov')==20);

%% Different types of scenes

% There are many types of scenes.  Here is a simple one that is
% useful for demosaicing.  For a list, type help sceneCreate
sceneTest = sceneCreate('freq orient pattern');

% With this one, we might try some simple plots, such as a plot
% of the luminance across the bottom row
sz = sceneGet(sceneTest,'size');
uData = scenePlot(sceneTest,'luminance hline',sz);
assert(mean(uData.data)/100.5751 - 1 < tolerance);

% We can do this ourselves by getting the luminance of this
% bottom row as follows
luminance = sceneGet(sceneTest,'luminance');
data = luminance(sz(1),:);

support = sceneSpatialSupport(sceneTest,'mm');
assert(support.x(1)/(-104.5762) - 1 < tolerance);

rows = round(sceneGet(sceneTest,'rows')/2);
assert(rows == 128,'Row test failed')
scenePlot(sceneTest,'radiance hline',[1,rows]);
drawnow;

%% END

end
