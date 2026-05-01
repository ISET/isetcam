function tests = test_ipData()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Show the ip data representations
%
% The input data 

%%
ieInit;

%% Data

scene = sceneCreate; scene = sceneSet(scene,'fov',4);

oi = oiCreate; oi = oiCompute(oi,scene);

sensor = sensorCreate; sensor = sensorCompute(sensor,oi);

ip = ipCreate; ip = ipCompute(ip,sensor);
% ipWindow(ip);

%%  Read the main data types in sequence

ieNewGraphWin([],'tall');
tiledlayout(3,2);

img = ipGet(ip,'input');
nexttile; imagesc(img); axis image; colormap(gray)

img = ipGet(ip,'sensor space');
nexttile; imagesc(img); axis image

img = ipGet(ip,'data ics');
nexttile; imagesc(img); axis image

img = ipGet(ip,'data ics illuminant corrected');
nexttile; imagesc(img); axis image

img = ipGet(ip,'data display');
nexttile; imagesc(img);axis image

img = ipGet(ip,'data srgb');
nexttile; imagesc(img);axis image

%%




end
