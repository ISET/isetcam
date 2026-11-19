function tests = test_colorSRGBXYZ()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
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
xyz = sceneGet(scene,'xyz');


%% Convert the XYZ to sRGB
%
%
[sRGB, lRGB, maxY]  = xyz2srgb(xyz);
%{
vcNewGraphWin;
image(sRGB);
%}

%% Now, let's go back from sRGB to XYZ and see how we do
xyz2 = srgb2xyz(sRGB);

% Scale it back up
xyz2 = xyz2*(maxY/max2(xyz2(:,:,2)));



RMSE = sqrt(mean((xyz2(:) - xyz(:)).^2));
assert(abs(RMSE - 1.8647) < 1e-3)

%% END
end
