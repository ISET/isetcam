%% v_macbeth
%
%  Validate some macbeth utilities
%
% macbethIlluminant estimates the illuminant from the image of an MCC
% macbethDrawRects:  Show and then eliminate the rects for the patches
%
% See also
%

%%
ieInit

%% Illuminant estimate method
scene = sceneCreate;
wave = sceneGet(scene,'wave');

% White point (1,64), black point (96,64) and so forth
cornerPoints = [
    1    64
    96    64
    96     1
    1     1];
scene = sceneSet(scene,'chart corner points',cornerPoints);

%%
illPhotons = macbethIlluminant(scene);

illOrig = sceneGet(scene,'illuminant photons');

%%
ieNewGraphWin;
loglog(illOrig,illPhotons);
xlabel('Original'); ylabel('Estimated'); grid on
assert( max(illOrig./illPhotons) - 1 < 1e-6)

% plotRadiance(wave,illPhotons);
% scenePlot(scene,'illuminant photons');

%%
sceneWindow(scene);
macbethDrawRects(scene,'on');
macbethDrawRects(scene,'off');

%% END