function tests = test_oiSmoke()
tests = functiontests(localfunctions);
end

function testOiComputePadValueGoldens(~)
%% Quantitative replacement for historical oiWindow pad-value smoke checks.

scene = sceneCreate('ringsrays');
oi = oiCreate('wvf');

cases = { ...
    'opticsotf', 'mean', 4.75262212753296, 5.79827737039854e+20, 3.41513963073168e+14, 1.82658547539661e+14; ...
    'opticsotf', 'zero', 3.04167842864990, 3.71089752981574e+20, 3.40564720858664e+14, 1.17079753087174e+10; ...
    'opticspsf', 'mean', 4.75262165069580, 5.79827784539912e+20, 3.44035188481596e+14, 1.82686646129258e+14; ...
    'opticspsf', 'zero', 3.04167866706848, 3.71089790121506e+20, 3.43668629632818e+14, 2.069181499360089e+11};

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
