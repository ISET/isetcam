%% v_oiPad
%
% Validate that the oiPad function does not change the sample spacing,
% just the size of the oi data
%
% BW, SCIEN Stanford, 2018

%%  Test scene
s = sceneCreate;
s = sceneSet(s,'fov',5);
ieAddObject(s);

%% Make n oi for testing
oi = oiCreate;
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

%%