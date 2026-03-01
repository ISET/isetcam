function ok = sceneFluorescenceChart_test()
% Regression and behavior tests for sceneFluorescenceChart.
%
% Coverage
%   1) Legacy mode: rows=odBloodLevels, cols=weights rows
%   2) Legacy golden-value check
%   3) Two-axis mode: fixed blood + weightGridSize layout
%   4) Two-axis input validation
%
% Run
%   ok = sceneFluorescenceChart_test();
%
% Returns
%   ok - true if all assertions pass.

ieInit;

%% 1) Legacy mode checks
wave = (500:10:700)';
odBloodLevels = [0.5 1.0 1.5 2.0]';
weights = [
    7.0, 0.45, 0.10, 0.03, 0.30;
    8.0, 0.50, 0.15, 0.04, 0.30;
    9.0, 0.55, 0.20, 0.05, 0.30;
    10.0, 0.60, 0.25, 0.06, 0.30];

patchSize = 8;
targetLuminance = 10;

[scene, signalCube, rcSize] = sceneFluorescenceChart( ...
    odBloodLevels, weights, patchSize, wave, targetLuminance);
chartP = sceneGet(scene,'chart parameters');

assert(isequal(rcSize, [numel(odBloodLevels), size(weights,1)]), ...
    'Legacy mode rcSize mismatch.');
assert(isequal(chartP.rowcol, rcSize), ...
    'Legacy mode chart rowcol mismatch.');
assert(isequal(size(signalCube), [numel(odBloodLevels), size(weights,1), numel(wave)]), ...
    'Legacy mode signalCube size mismatch.');

mapTol = 1e-10;
for rr = 1:numel(odBloodLevels)
    for cc = 1:size(weights,1)
        expected = fluorescenceSignal(wave, odBloodLevels(rr), weights(cc,:)');
        got = squeeze(signalCube(rr,cc,:));
        relErr = norm(got(:)-expected(:)) / max(norm(expected(:)), eps);
        assert(relErr < mapTol, ...
            'Legacy mapping mismatch at (row=%d,col=%d).', rr, cc);
    end
end

%% 2) Legacy golden-value check
goldenTol = 1e-9;
v = squeeze(signalCube(3,2,:));
expectedSum = 14.795025949261;
expectedNorm = 3.55198508960606;
expectedV1 = 1.37080485743272;
expectedV11 = 0.57099328989583;
expectedV21 = 0.322217523321561;

assert(abs(sum(v) - expectedSum) < goldenTol, 'Legacy golden check failed for sum(v).');
assert(abs(norm(v) - expectedNorm) < goldenTol, 'Legacy golden check failed for norm(v).');
assert(abs(v(1) - expectedV1) < goldenTol, 'Legacy golden check failed for v(1).');
assert(abs(v(11) - expectedV11) < goldenTol, 'Legacy golden check failed for v(11).');
assert(abs(v(21) - expectedV21) < goldenTol, 'Legacy golden check failed for v(21).');

%% 3) Two-axis mode checks (fixed blood, two fluorophore sweeps)
fixedBlood = 1.25;
collagen = [7 8 9];
fad = [0.4 0.6 0.8 1.0];
porphyrin = 0.2;
chlorophyll = 0.04;
keratin = 0.30;

[w2, wInfo] = fluorescenceWeights(collagen, fad, porphyrin, chlorophyll, keratin);
chartOptions = struct('weightGridSize', wInfo.gridSize, 'variedIdx', wInfo.variedIdx);

[scene2, signalCube2, rcSize2] = sceneFluorescenceChart( ...
    fixedBlood, w2, patchSize, wave, targetLuminance, chartOptions);
chartP2 = sceneGet(scene2,'chart parameters');

assert(isequal(rcSize2, wInfo.gridSize), 'Two-axis rcSize mismatch.');
assert(isequal(chartP2.rowcol, wInfo.gridSize), 'Two-axis rowcol mismatch.');
assert(chartP2.twoAxisWeightMode == true, 'Two-axis mode flag should be true.');
assert(isequal(chartP2.weightGridSize, wInfo.gridSize), 'Two-axis stored weightGridSize mismatch.');

nRows = wInfo.gridSize(1);
nCols = wInfo.gridSize(2);
idxGrid = reshape(1:size(w2,1), nCols, nRows)';
for rr = 1:nRows
    for cc = 1:nCols
        weightIdx = idxGrid(rr,cc);
        expected = fluorescenceSignal(wave, fixedBlood, w2(weightIdx,:)');
        got = squeeze(signalCube2(rr,cc,:));
        relErr = norm(got(:)-expected(:)) / max(norm(expected(:)), eps);
        assert(relErr < mapTol, ...
            'Two-axis mapping mismatch at (row=%d,col=%d).', rr, cc);
    end
end

%% 4) Input-validation check for two-axis mode
try
    badChartOptions = struct('weightGridSize', [2 3]);
    sceneFluorescenceChart([1 2], w2, patchSize, wave, targetLuminance, badChartOptions);
    error('ExpectedErrorNotThrown');
catch ME
    assert(~strcmp(ME.identifier,'ExpectedErrorNotThrown'), ...
        'Expected input-validation error was not thrown in two-axis mode.');
end

ok = true;
disp('sceneFluorescenceChart_test passed.');

end
