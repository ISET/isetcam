function tests = test_oiSmoke()
tests = functiontests(localfunctions);
end

function testOiComputePadValueGoldens(~)
%% Quantitative replacement for historical oiWindow pad-value smoke checks.

scene = sceneCreate('ringsrays');
oi = oiCreate('wvf');

cases = { ...
    'opticsotf', 'mean', 4.82640361785889, 5.88829221240604e+20, 346815762312049, 185494216763278; ...
    'opticsotf', 'zero', 3.0888979434967, 3.7685070003144e+20, 345851783627927, 11889734681.1045; ...
    'opticspsf', 'mean', 4.82640361785889, 5.88829277620832e+20, 349376129175623, 185522755478783; ...
    'opticspsf', 'zero', 3.08889865875244, 3.76850740578906e+20, 349003879259018, 210130899490.907};

for ii = 1:size(cases,1)
    computeMethod = cases{ii,1};
    padValue = cases{ii,2};
    expectedMeanIlluminance = cases{ii,3};
    expectedPhotonSum = cases{ii,4};
    expectedCenterPhotons = cases{ii,5};
    expectedCornerPhotons = cases{ii,6};

    thisOI = oiSet(oi,'compute method',computeMethod);
    thisOI = oiCompute(thisOI,scene,'pad value',padValue,'crop',false);

    photons = oiGet(thisOI,'photons');
    illuminance = oiGet(thisOI,'illuminance');
    centerPhotons = mean(photons(45:55,45:55,:),'all');
    cornerPhotons = mean(photons(1:5,1:5,:),'all');

    assert(isequal(oiGet(thisOI,'size'),[320 320]));
    assert(abs(oiGet(thisOI,'fov')/12.4822240581386 - 1) < 1e-6);
    assert(abs(mean(illuminance,'all')/expectedMeanIlluminance - 1) < 1e-6);
    assert(abs(sum(photons,'all')/expectedPhotonSum - 1) < 1e-6);
    assert(abs(centerPhotons/expectedCenterPhotons - 1) < 1e-6);

    % This needs a bit more flexibility - not exactly sure why.  I
    % think different machines produce slightly different values for
    % this case.
    assert(abs(cornerPhotons/expectedCornerPhotons - 1) < 10e-6);
end

end
