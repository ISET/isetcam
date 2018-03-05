%% v_oiPad
%
% Validate that the oiPad function does not change the sample spacing,
% just the size of the oi data.  This is tested for the diffraction
% limited, shift-invariant and ray trace models.
%
% BW, SCIEN Stanford, 2018

%%
ieInit

%%  Test scene - decent but low resolution
s = sceneCreate('slanted bar',96);
s = sceneSet(s,'fov',1);
ieAddObject(s);

%% Make oi for testing
oi = oiCreate('diffraction limited');
oi = oiCompute(oi,s);
oiGet(oi,'fov');
baseSpacing = oiGet(oi,'sample spacing');

%% Verify that padding does not change the sample spacing

for padding = 10:10:100
    oip = oiPad(oi,[padding,padding]);
    % oiGet(oip,'fov')
    newSpacing = oiGet(oip,'sample spacing');
    assert(max(abs(newSpacing - baseSpacing)) < 1e-10)
end
disp('v_oiPad succeeds for diffraction limited');

%% Make oi for testing
oi = oiCreate('shiftinvariant');
oi = oiCompute(oi,s);
oiGet(oi,'fov');
baseSpacing = oiGet(oi,'sample spacing');
sz = oiGet(oi,'size');

%% Verify that padding does not change the sample spacing

for padding = 10:10:100
    oip = oiPad(oi,[padding,padding]);
    % oiGet(oip,'fov')
    newSpacing = oiGet(oip,'sample spacing');
    assert(max(abs(newSpacing - baseSpacing)) < 1e-10)
end
disp('v_oiPad succeeds for shift invariant');
%%  Now check for the ray trace oi case, which failed at one time

% Fewer wavelengths for speed
s = sceneSet(s,'wave',400:100:700);
s = sceneSet(s,'distance',2);   % Matches the lens
ieAddObject(s);

oi = oiCreate('raytrace');
oi = oiCompute(oi,s);
baseSpacing = oiGet(oi,'sample spacing');

%%
for padding = 10:10:100
    oip = oiPad(oi,[padding,padding]);
    newSpacing = oiGet(oip,'sample spacing');
    assert(max(abs(newSpacing - baseSpacing)) < 1e-10)
end
disp('v_oiPad succeeds for ray trace');
ieDeleteObject(s);

%%