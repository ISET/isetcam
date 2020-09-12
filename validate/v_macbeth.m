%% v_macbeth
%
%  Test specific chart/macbeth utilities.  The general testing of the chart
%  utilities shuld happen in v_chart.
%
% * macbethIlluminant estimates the illuminant from the image of an MCC
% * macbethDrawRects:  Show and then eliminate the rects for the patches
%
% See also
%   chart<TAB>

%%
ieInit

%% Illuminant estimate method
scene = sceneCreate;
wave = sceneGet(scene,'wave');

% The whole image is the chart.  Set the cornerpoints and store them in the
% chartP of the scene.
[cornerpoints, scene] = chartCornerpoints(scene,true);

%% Estimate the illuminant photons from the MCC data

illPhotons = macbethIlluminant(scene);

%%  Compare the original and the estimated

illOrig = sceneGet(scene,'illuminant photons');

ieNewGraphWin;
loglog(illOrig,illPhotons);
xlabel('Original'); ylabel('Estimated'); grid on
assert( max(illOrig./illPhotons) - 1 < 1e-6)

%%
sceneWindow(scene);
macbethDrawRects(scene,'on');
pause(1)
macbethDrawRects(scene,'off');  % Just a refresh.

%% END
