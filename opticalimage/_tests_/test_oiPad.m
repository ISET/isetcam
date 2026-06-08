function tests = test_oiPad()
tests = functiontests(localfunctions);
end

function testMain(~)
%% v_oiPad
%
% Validate the oiPad function in two ways.
%
% First, we check that padding does not change the sample spacing,
% just the row/col size of the oi data.  This is tested for the
% diffraction limited, shift-invariant and ray trace models.
%
% Second, we compute with different pad values at the border (zero,
% mean, border).  We test this 'padvalue' operation for both the
% opticspsf and opticsotf paths.
%

%%
ieInit

%%  Test scene - decent but low resolution
s = sceneCreate('slanted bar',96);
s = sceneSet(s,'fov',1);
ieAddObject(s);

%% Make DL oi for testing
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

oip = oiPad(oi,[40 40]);
assert(isequal(oiGet(oip,'size'),[201 201]));
assert(abs(oiGet(oip,'fov')/2.07199171491491 - 1) < 1e-6);
assert(abs(mean(oiGet(oip,'illuminance'),'all')/1.1183705329895 - 1) < 1e-4);
assert(abs(sum(oiGet(oip,'photons'),'all')/5.31577172443882e+19 - 1) < 1e-4);
% disp('v_oiPad succeeds for diffraction limited');

%% Make SIL oi for testing
oi = oiCreate('shift invariant');
oi = oiCompute(oi,s);
oiGet(oi,'fov');
baseSpacing = oiGet(oi,'sample spacing');
% oiWindow(oi);

%% Verify that padding does not change the sample spacing
for padding = 10:10:100
    oip = oiPad(oi,[padding,padding]);
    % oiGet(oip,'fov')
    newSpacing = oiGet(oip,'sample spacing');
    assert(max(abs(newSpacing - baseSpacing)) < 1e-10)
end

oip = oiPad(oi,[40 40]);
assert(isequal(oiGet(oip,'size'),[201 201]));
assert(abs(oiGet(oip,'fov')/2.07199171491491 - 1) < 1e-6);
assert(abs(mean(oiGet(oip,'illuminance'),'all')/1.11837303638458 - 1) < 1e-4);
assert(abs(sum(oiGet(oip,'photons'),'all')/5.31577146684277e+19 - 1) < 1e-4);
% disp('v_oiPad succeeds for shift invariant');
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

oip = oiPad(oi,[40 40]);
assert(isequal(oiGet(oip,'size'),[269 269]));
assert(abs(oiGet(oip,'fov')/2.77272502827149 - 1) < 1e-6);
assert(abs(mean(oiGet(oip,'illuminance'),'all')/0.410668759282349 - 1) < 1e-4);
assert(abs(sum(oiGet(oip,'photons'),'all')/5.02003239027267e+18 - 1) < 1e-4);
disp('v_oiPad succeeds for ray trace');
ieDeleteObject(s);

%% END
end
