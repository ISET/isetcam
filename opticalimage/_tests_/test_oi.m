function tests = test_oi()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Test optical image functions
%
% This tests the diffraction limited case.  There are other wvf cases
% tested by other validation routines.
%
% Copyright Imageval LLC, 2009

%%
tolerance = 1e-6;

%% Diffraction limited simulation properties
oi  = oiCreate('diffraction limited');
% When we eliminated diffraction limited, we could do this
tmp = oiGet(oi,'optics otf',[],550);

% But when we put dlMTF back, we had this awful change to opticsGet that is
% model dependent.  That must get fixed!
% tmp = opticsGet(optics,'otf data',oi, 'mm', 550);

assert(abs(sum(tmp(:)))/3.966187029892846e+04 - 1 < 1e-4);

%%
uData = oiPlot(oi,'otf',[],550);
assert(abs(mean(abs(uData.otf(:)))/0.012275433296988 - 1) < tolerance);

uData = oiPlot(oi,'otf',[],450);
assert(abs(mean(abs(uData.otf(:)))/0.012275433296988- 1) < tolerance);

%% Shift invariant, which defaults to diffraction limited
oi = oiCreate('shift invariant');
oiPlot(oi,'otf',[],550);
oiPlot(oi,'otf',[],450);

tmp = oiGet(oi,'optics otf',550);
assert(abs(sum(tmp(:)))/109 -1 < 1e-4);

%% Make a scene and show some oiGets and oiCompute work
scene = sceneCreate('gridlines',256);
scene = sceneSet(scene,'fov',1);
oi = oiCreate('wvf');
oi = oiCompute(oi,scene);

uData = oiPlot(oi,'illuminance mesh linear');
assert(isequal(size(uData.data),[320 320]));
assert(mean(double(uData.data(:))/3.073368220531811 - 1) < tolerance);

%% Check GUI control
oiWindow(oi); pause(0.2);
oiSet(oi,'gamma',1);
oiSet(oi,'gamma',0.4); pause(0.5)
oiSet(oi,'gamma',1);

%%
end
