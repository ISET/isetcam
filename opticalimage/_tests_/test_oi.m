function tests = test_oi()
tests = functiontests(localfunctions);
end

function testMain(~)
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
tmp = oiGet(oi,'optics otf',[],550);
assert(isequal(size(tmp),oiGet(oi,'size')));
assert(tmp(1,1) == 1);
assert(abs(sum(tmp,'all')/3.966187029892846e+04 - 1) < 1e-4);
assert(sum(oiGet(oi,'optics otf',450),'all') > sum(tmp,'all'));

%%
uData = oiPlot(oi,'otf',[],550,'nofigure');
assert(abs(mean(abs(uData.otf(:)))/0.012275433296988 - 1) < tolerance);

uData = oiPlot(oi,'otf',[],450,'nofigure');
assert(abs(mean(abs(uData.otf(:)))/0.012275433296988- 1) < tolerance);

%% Shift invariant, which defaults to diffraction limited
oi = oiCreate('shift invariant');
oiPlot(oi,'otf',[],550,'nofigure');
oiPlot(oi,'otf',[],450,'nofigure');

tmp = oiGet(oi,'optics otf',550);
assert(abs(abs(sum(tmp(:)))/109 - 1) < 1e-4);

%% Make a scene and show some oiGets and oiCompute work
scene = sceneCreate('gridlines',256);
scene = sceneSet(scene,'fov',1);
oi = oiCreate('wvf');
oi = oiCompute(oi,scene);

uData = oiPlot(oi,'illuminance mesh linear',[],'nofigure');
assert(isequal(size(uData.data),[320 320]));
assert(abs(mean(double(uData.data(:)))/3.12108049875606 - 1) < tolerance);

photons = oiGet(oi,'photons');
assert(abs(sum(photons,'all')/3.80776968964576e+20 - 1) < 1e-4);

centerROI = mean(photons(150:170,150:170,:),'all');
assert(abs(centerROI/214312867384502 - 1) < 1e-4);

support = oiGet(oi,'spatial support');
assert(abs(support(1,1,1)/-4.2141217067371e-05 - 1) < 1e-6);
assert(abs(support(1,end,1)/4.2141217067371e-05 - 1) < 1e-6);
assert(abs(support(1,1,2)/-4.2141217067371e-05 - 1) < 1e-6);
assert(abs(support(end,1,2)/4.2141217067371e-05 - 1) < 1e-6);

%%
end
