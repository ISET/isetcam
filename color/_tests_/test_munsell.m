function tests = test_munsell()
tests = functiontests(localfunctions);
end

function testNotationParseAndFormat(~)
%% Text and numeric Munsell notation convert in both directions

hvc = ieMunsellNotation({'5R 4/14','2.5YR 6.5/8','10RP 3/2','0YR 5/4','N 5/','n7'});
expected = [5 4 14; 12.5 6.5 8; 100 3 2; 10 5 4; NaN 5 0; NaN 7 0];
assert(isequaln(hvc, expected));

txt = ieMunsellNotation(expected);
assert(isequal(txt, ["5R 4/14";"2.5YR 6.5/8";"10RP 3/2";"10R 5/4";"N 5/";"N 7/"]));

% Hue wraps onto (0,100] and rounding to 0 becomes 10RP
assert(ieMunsellNotation([0.02 5 6]) == "10RP 5/6");
assert(ieMunsellNotation([105 5 6]) == "5R 5/6");

end

function testRenotationTablesLoad(~)
%% The three renotation datasets load with the expected sizes

dReal = ieMunsellRenotation('real');
dAll  = ieMunsellRenotation('all');
d1929 = ieMunsellRenotation('1929');

assert(isequal(size(dReal.hvc), [2734 3]));
assert(isequal(size(dAll.hvc),  [4995 3]));
assert(isequal(size(d1929.hvc), [956 3]));

% Every sample in 'all' is a distinct grid point
assert(size(unique(dAll.hvc, 'rows'), 1) == size(dAll.hvc, 1));

% Published Y is relative to MgO; XYZ is relative to a perfect diffuser
assert(max(abs(dReal.XYZ(:,2) - 0.975*dReal.xyY(:,3))) < 1e-12);

end

function testForwardReproducesRenotation(~)
%% ieMunsell2XYZ returns the published values at the renotation samples

% The interpolation grid is the 'all' dataset
dAll = ieMunsellRenotation('all');
[~, xyY] = ieMunsell2XYZ(dAll.hvc);
assert(max(abs(xyY(:,1:2) - dAll.xyY(:,1:2)), [], 'all') < 1e-12);

% The 'real' dataset agrees except for x at 2.5R 9/2 (0.3210 vs 0.3220)
d = ieMunsellRenotation('real');
[~, xyY] = ieMunsell2XYZ(d.hvc);
dxy = max(abs(xyY(:,1:2) - d.xyY(:,1:2)), [], 2);
assert(isequal(d.notation(dxy > 1e-12), "2.5R 9/2"));
assert(abs(dxy(d.notation == "2.5R 9/2") - 0.001) < 1e-12);

% ASTM D1535 Y equals the published 'real' Y times 0.975, to table precision
assert(max(abs(xyY(:,3)/0.975 - d.xyY(:,3))) < 5e-3);

% Text input gives the same result
assert(max(abs(ieMunsell2XYZ(d.notation(1:50)) - ieMunsell2XYZ(d.hvc(1:50,:))), [], 'all') < 1e-12);

end

function testForwardNeutralAndOutOfRange(~)
%% Neutrals have the Illuminant C chromaticity; unknown colors are NaN

[XYZ, xyY] = ieMunsell2XYZ({'N 5/','N 10/','N 0/'});
assert(max(abs(xyY(:,1:2) - [0.31006 0.31616]), [], 'all') < 1e-12);
assert(abs(xyY(2,3) - 100) < 1e-2);
assert(all(XYZ(3,:) == 0));

% Chroma 40 does not exist at 5R 4, and Value 0.1 is below the data
XYZ = ieMunsell2XYZ([5 4 40; 5 0.1 2]);
assert(all(isnan(XYZ), 'all'));

end

function testInverseOfRenotationSamples(~)
%% ieXYZ2Munsell recovers the notation of the renotation samples

% XYZ from the table chromaticity and the ASTM D1535 Y at each Value
d = ieMunsellRenotation('real');
hvc = ieXYZ2Munsell(ieMunsell2XYZ(d.hvc));

assert(~any(isnan(hvc), 'all'));
assert(max(abs(hvc(:,2:3) - d.hvc(:,2:3)), [], 'all') < 1e-6);
dH = mod(hvc(:,1) - d.hvc(:,1) + 50, 100) - 50;
assert(max(abs(dH)) < 1e-6);

% The published XYZ, whose Y is rounded to three decimals, inverts to
% table precision.  At Value 1 that rounding is worth about 0.015 chroma.
% Skip 2.5R 9/2, where 'real' and 'all' disagree.
keep = d.notation ~= "2.5R 9/2";
hvc = ieXYZ2Munsell(d.XYZ(keep,:));
assert(~any(isnan(hvc), 'all'));
assert(max(abs(hvc(:,2:3) - d.hvc(keep,2:3)), [], 'all') < 0.02);
dH = mod(hvc(:,1) - d.hvc(keep,1) + 50, 100) - 50;
assert(max(abs(dH)) < 0.01);

end

function testRoundTripBetweenSamples(~)
%% Munsell -> XYZ -> Munsell is the identity between the samples

rng(1);
d = ieMunsellRenotation('real');
base = d.hvc(d.hvc(:,3) >= 4, :);
idx  = randi(size(base,1), 500, 1);

% Stay inside the data: move hue and Value a little and lower the chroma
hvc = base(idx,:) + [2.5*rand(500,1), -0.9*rand(500,1), -2*rand(500,1)];
hvc(:,1) = mod(hvc(:,1), 100);
XYZ = ieMunsell2XYZ(hvc);
ok  = all(isfinite(XYZ), 2);
assert(sum(ok) > 450);

hvc2 = ieXYZ2Munsell(XYZ(ok,:));
dH = mod(hvc2(:,1) - hvc(ok,1) + 50, 100) - 50;
assert(max(abs(dH)) < 1e-4);
assert(max(abs(hvc2(:,2:3) - hvc(ok,2:3)), [], 'all') < 1e-4);

end

function testInverseFormatsAndNeutrals(~)
%% RGB-format input, neutral colors, and the notation output

XYZ = ieMunsell2XYZ({'N 5/','5PB 3/10','4.2YR 8.1/5.3','10GY 6/6'});
[hvc, notation] = ieXYZ2Munsell(reshape(XYZ, 2, 2, 3));

assert(isequal(size(hvc), [2 2 3]));
assert(isequal(notation, ["N 5/","4.2YR 8.1/5.3";"5PB 3/10","10GY 6/6"]));
assert(isnan(hvc(1,1,1)) && hvc(1,1,3) == 0);

end

function testInverseOutOfRangeWarns(testCase)
%% Chromaticities beyond the renotation data return NaN with a warning

% A saturated red at Value 9.  The data at Value 9 stop near chroma 14.
Y = ieMunsell2XYZ('N 9/');
XYZ = xyy2xyz([0.65 0.33 Y(2)]);
hvc = testCase.verifyWarning(@() ieXYZ2Munsell(XYZ), 'ieXYZ2Munsell:outOfRange');
testCase.verifyTrue(isnan(hvc(1)) && isnan(hvc(3)));
testCase.verifyEqual(hvc(2), 9, 'AbsTol', 1e-8);

end
