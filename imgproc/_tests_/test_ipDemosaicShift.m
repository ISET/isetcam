function tests = test_ipDemosaicShift()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_demosaic

% GG says that there is a shift in the position of the line caused by the
% demosaicking algorithm.  She sent a clear email about this

%%
ieInit

%%
scene = sceneCreate('line ee');
sceneWindow(scene);

%%
c = cameraCreate;
c = cameraSet(c,'ip demosaic method','bilinear');
c = cameraCompute(c,scene);
ipWindow(c.vci);

%%
c = cameraSet(c,'ip demosaic method','Laplacian');
c = cameraCompute(c,scene);
ipWindow(c.vci);

%%
drawnow;

%% END
end
