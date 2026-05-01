function tests = test_wvfsets()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_icam_wvfsets
%
% Requires having isetLens on your path

%% Test focal length and fnumber wvfSets/Gets

% Default
wvf = wvfCreate;
assert(wvfGet(wvf,'focal length')==17.1883);

assert(abs(wvfGet(wvf,'focal length','um') - 1.718830000000000e+04) < 1e-1);
wvfGet(wvf,'focal length','m');
wvfGet(wvf,'focal length','mm');

% um per degree changes with focal length
assert(abs(wvfGet(wvf,'um per degree')-300) < 1);

wvf = wvfSet(wvf,'focal length',3.9,'mm');
assert(abs(wvfGet(wvf,'um per degree')-68.069568767918554) < 1e-3);

% Print the focal length with different units
assert(abs(wvfGet(wvf,'focal length','mm')-3.9) < 1e-3);
wvfGet(wvf,'focal length','m');

%% Now test f-number sets and gets

% Current f number
a = wvfGet(wvf,'fnumber');

% Matches pupil diameter and focal length
b = wvfGet(wvf,'focal length','mm')/wvfGet(wvf,'calc pupil diameter','mm');
assert( abs(a/b - 1) < 1e-9);

% We never change the f number.  We only adjust only the pupil or the focal
% length. To set the fnumber to 4, we have to decide what to change, the
% pupil or the focal length.
%
% To make the fNumber, say 4, we would do this:

fLength = wvfGet(wvf,'focal length','mm');
fNumber = 4;
wvf = wvfSet(wvf,'calc pupil diameter',fLength/fNumber,'mm');

assert(abs(fNumber - wvfGet(wvf,'fnumber')) < 1e-4);
assert(abs(fLength - wvfGet(wvf,'focal length','mm')) < 1e-4);
assert(abs(fLength/4 - wvfGet(wvf,'calc pupil diameter','mm')) < 1e-4);

%% The default OI has an f number of 4 and focal length of 3.9 mm

[oi, wvf] = oiCreate('wvf');

assert( abs(oiGet(oi,'optics fnumber') - wvfGet(wvf,'fnumber')) < 1e-5);
assert( abs(oiGet(oi,'optics focal length','mm') - wvfGet(wvf,'focal length','mm')) < 1e-5);

%% Test from ISETBio validate via DHB

if ~isempty(which('isetbioRootPath'))

    pupilDiamMm = 3;
    theOI = oiCreate('wvf human', pupilDiamMm);

    assert(abs(pupilDiamMm - oiGet(theOI,'optics pupil diameter','mm')) < 1e-5)

    % This is the distance we should set the focal length to be in perfect
    % focus for the scene.  Not exactly the focal length.
    % focalLength = oiGet(theOI, 'distance');

    focalLength = oiGet(theOI,'optics focal length','mm');

    desiredFNumber = focalLength / pupilDiamMm ;
    assert(abs(desiredFNumber - oiGet(theOI,'optics fnumber')) < 1e-5)

    % This set is the test.  Did we change things correctly?
    theOI  = oiSet(theOI , 'optics fnumber', desiredFNumber);

    focalLengthTest = oiGet(theOI,'optics focal length','mm');
    pupilTest = oiGet(theOI,'optics pupil diameter','mm');

    assert( abs(focalLengthTest - focalLength) < 1e-6);
    assert( abs(pupilTest - pupilDiamMm) < 1e-6);


    %% Change the focalLength, reset the fnumber, and test

    theOI  = oiSet(theOI , 'optics focal length', 0.004);   % Meters
    theOI  = oiSet(theOI , 'optics fnumber', desiredFNumber);

    pupilTest = oiGet(theOI,'optics pupil diameter','mm');
    focalLengthTest = oiGet(theOI,'optics focal length','mm');

    assert(abs(focalLengthTest/pupilTest - desiredFNumber) < 1e-6);
    assert(abs(focalLengthTest - 4) < 1e-6);
end

%% END

end
