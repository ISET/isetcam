function tests = test_sceneIncreaseSize()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Increase the number of scene spatial samples
%
% The number of spatial samples in a scene is one more of its
% resolution.  Equally important is how many samples there are
% per degree of visual angle.
%
% This routine increases the number of spatial samples by linear
% interpolation.
%
% See also:  imageIncreaseImageRGBSize
%
% (c) Imageval Consulting, LLC, 2012

%%
ieInit
tolerance = 1e-6;

%%
scene = sceneCreate;
% sceneWindow(scene); pause(delay);

%% Double the rows, triple the columns
s = [2,3];
p = sceneGet(scene,'photons');
p = imageIncreaseImageRGBSize(p,s);
scene = sceneSet(scene,'photons',p);
assert( isequal(sceneGet(scene,'size'),[128   288]));
assert( abs((mean(p(:))/3.762411950109244e+15) - 1) < tolerance)

%% Double the cols
s = [1,2];
p = sceneGet(scene,'photons');
p = imageIncreaseImageRGBSize(p,s);
scene = sceneSet(scene,'photons',p);
assert( isequal(sceneGet(scene,'size'),[128   576]));
assert( abs((mean(p(:))/3.762411950109244e+15) - 1) < tolerance)

% sceneWindow(scene); pause(delay);

%% Triple the cols - should return to original aspect ratio

s = [3,1];
p = sceneGet(scene,'photons');
p = imageIncreaseImageRGBSize(p,s);
scene = sceneSet(scene,'photons',p);
scene = sceneSet(scene,'photons',p);
assert( isequal(sceneGet(scene,'size'),[384,576]));
assert( abs((mean(p(:))/3.762411950109244e+15) - 1) < tolerance)

%%
end
