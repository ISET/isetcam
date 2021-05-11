%% v_colorSRGBXYZ
%
%  Checking the xyz to srgb and back functions.  THere are some
%  imprecisions in the back and forth.  Let's track this down.
%
% ZL/BW SCIEN Stanford, 2018

%%
ieInit;

%%
scene = sceneCreate;
xyz = sceneGet(scene, 'xyz');
sceneWindow(scene);

%% Convert the XYZ to sRGB
%
%
[sRGB, lRGB, maxY] = xyz2srgb(xyz);
%{
vcNewGraphWin;
image(sRGB);
%}

%% Now, let's go back from sRGB to XYZ and see how we do
xyz2 = srgb2xyz(sRGB);

% Scale it back up
xyz2 = xyz2 * (maxY / max2(xyz2(:, :, 2)));

vcNewGraphWin;
histogram(100*(xyz2(:) - xyz(:))./xyz(:));
xlabel('Percent error')
ylabel('Number of points');
set(gca, 'yscale', 'log'); grid on

RMSE = sqrt(mean((xyz2(:)-xyz(:)).^2));
assert((RMSE - 1.8647) < 1e-3)

%% END