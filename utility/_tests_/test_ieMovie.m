function tests = test_ieMovie()
tests = functiontests(localfunctions);
end

function testSaveSteppedGrayscaleMovie(testCase)
tmpDir = tempname;
mkdir(tmpDir);
cleanupObj = onCleanup(@() rmdir(tmpDir,'s')); %#ok<NASGU>

movieFile = fullfile(tmpDir,'gray.mp4');
data = rand(64,64,5);

[returnedData, videoObj] = ieMovie(data, ...
    'vname', movieFile, ...
    'show', false, ...
    'step', 2, ...
    'FrameRate', 4);

verifyEqual(testCase,returnedData,data);
verifyTrue(testCase,isfile(movieFile));
verifyClass(testCase,videoObj,'VideoWriter');
verifyEqual(testCase,countVideoFrames(movieFile),3);
end

function testSaveSteppedRGBMovie(testCase)
tmpDir = tempname;
mkdir(tmpDir);
cleanupObj = onCleanup(@() rmdir(tmpDir,'s')); %#ok<NASGU>

movieFile = fullfile(tmpDir,'rgb.mp4');
data = rand(64,64,3,4);

ieMovie(data, ...
    'vname', string(movieFile), ...
    'show', false, ...
    'step', 2, ...
    'FrameRate', 4);

verifyTrue(testCase,isfile(movieFile));
verifyEqual(testCase,countVideoFrames(movieFile),2);
end

function framesNum = countVideoFrames(movieFile)
reader = VideoReader(movieFile);
framesNum = 0;
while hasFrame(reader)
    readFrame(reader);
    framesNum = framesNum + 1;
end
end
