function tests = test_oiWVF()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Test that wvf2oi produces the same OTF in wvf and oi
%
% See also
%  v_icam_opticsWVF

%%
ieInit

%% Build a wvf that we will convert

wave = 700;
pupilMM = 3;   % Could be 6, 4.5, or 3
fLengthMM = 17;

% Create the multispectral wvf
wvf  = wvfCreate('wave',wave,'name',sprintf('%dmm-pupil',pupilMM));
wvf  = wvfSet(wvf,'calc pupil diameter',pupilMM);
wvf  = wvfSet(wvf,'focal length',fLengthMM);  % 17 mm focal length for deg per mm
wvfWave = wvfGet(wvf,'wave');

% Calculate without human LCA
wvf = wvfSet(wvf,'lcaMethod','none');
wvf  = wvfCompute(wvf);

%%  Here are the OTF data from the wvf, in a couple of ways
wvfOTF = wvfGet(wvf,'otf and support','mm',wave);
tmp = wvfGet(wvf,'otf',wave);
% iePlot(abs(tmp(:)),abs(wvfOTF.data(:)),'.');identityLine;
assert(max(abs(tmp(:)-wvfOTF.data(:))) < 1e-6)

%% Convert wvf to OI format
oi = wvf2oi(wvf);
assert(max(abs(tmp(:)-oi.optics.OTF.OTF(:))) < 1e-6)
% iePlot(abs(tmp(:)),abs(oi.optics.OTF.OTF(:)),'.'); identityLine;

%% They still match.
oiOTF = oiGet(oi,'optics otf',wave);
assert(max(abs(tmp(:)-oiOTF(:))) < 1e-6)
% iePlot(abs(tmp(:)),abs(oiOTF(:)),'.'); identityLine;

%% Still match
oiOTF2 = oiGet(oi,'optics otf and support',wave);
assert(max(abs(tmp(:)-abs(oiOTF2.otf(:)))) < 1e-6)
% iePlot(abs(tmp(:)),abs(oiOTF2.otf(:)),'.'); identityLine;

%%
end
