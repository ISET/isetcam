function tests = test_oiPlot()
tests = functiontests(localfunctions);
end

function testMain(~)
%% Numeric checks for representative oiPlot return data.

existingFigures = findall(groot,'Type','figure');
cleanupObj = onCleanup(@() localCleanupPlotState(existingFigures)); %#ok<NASGU>

ieInit;

scene = sceneCreate;
scene = sceneSet(scene,'fov',4);
oi = oiCreate('wvf');
oi = oiCompute(oi,scene);

rows = round(oiGet(oi,'rows')/2);

uData = oiPlot(oi,'irradiance photons roi',[10 10 10 10],'nofigure');
assert(numel(uData.x) == 31);
assert(numel(uData.y) == 31);
assert(size(uData.roiLocs,1) == 1);
assert(abs(mean(uData.x) - 550) < 1e-12);
localAssertRel(mean(uData.y),63244690632036,1e-6);

uData = oiPlot(oi,'hline',[20 20],'nofigure');
assert(numel(uData.pos) == 120);
assert(numel(uData.wave) == 31);
localAssertRel(mean(uData.data,'all'),136374103200482,1e-6);
localAssertRel(sum(uData.data,'all'),5.07311663905791e+17,1e-6);

uData = oiPlot(oi,'illuminance fft hline',[1,rows],'nofigure');
assert(numel(uData.freq) == 60);
localAssertRel(mean(uData.data,'all'),0.0981732085347176,1e-6);
localAssertRel(max(uData.data(:)),1,1e-12);

% Grid spacing and nofigure can be supplied together.
uData = oiPlot(oi,'irradiance image wave',[],500,40,'nofigure');
assert(isequal(size(uData.irrad),[80 120]));
assert(numel(uData.xCoords) == 120);
assert(numel(uData.yCoords) == 80);
localAssertRel(mean(uData.irrad,'all'),104381233641431,1e-6);

uData = oiPlot(oi,'irradiance fft',[],450,'nofigure');
assert(isequal(size(uData.z),[80 120]));
localAssertRel(mean(uData.z,'all'),2.70325978143147e+15,1e-6);
localAssertRel(max(uData.z(:)),2.82189157347564e+17,1e-6);

uData = oiPlot(oi,'psf 550','um','nofigure');
assert(isequal(size(uData.psf),[120 120]));
localAssertRel(sum(uData.psf,'all'),0.999999880790709,1e-6);
localAssertRel(max(uData.psf(:)),0.981597127285269,1e-6);
localAssertRel(max(uData.x(:)),169.161996620764,1e-6);

uData = oiPlot(oi,'otf 550','um','nofigure');
assert(isequal(size(uData.otf),[120 120]));
localAssertRel(mean(abs(uData.otf),'all'),0.981597127285269,1e-6);
localAssertRel(sum(abs(uData.otf),'all'),1.41349986329079e+04,1e-6);
localAssertRel(uData.fx(1),-177.344797290703,1e-6);
localAssertRel(uData.fx(end),174.389050669191,1e-6);

end

function localAssertRel(actual,expected,tolerance)
%% Relative scalar assertion with exact-zero protection.

if expected == 0
    assert(abs(actual) < tolerance);
else
    assert(abs(actual/expected - 1) < tolerance);
end

end

function localCleanupPlotState(existingFigures)
%% Close figures created by oiPlot checks.

delete(setdiff(findall(groot,'Type','figure'),existingFigures));

end
