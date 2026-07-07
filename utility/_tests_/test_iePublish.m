function tests = test_iePublish()
tests = functiontests(localfunctions);
end

function testPublishToSourceDirectory(testCase)
repoRoot = isetRootPath;
srcFile = fullfile(repoRoot,'tutorials','scene','t_sceneIntroduction.m');

tmpDir = tempname;
mkdir(tmpDir);
cleanupObj = onCleanup(@() rmdir(tmpDir,'s')); %#ok<NASGU>

tmpMFile = fullfile(tmpDir,'t_sceneIntroduction.m');
copyfile(srcFile,tmpMFile);

htmlFile = iePublish(tmpMFile,'evalCode',false);

verifyTrue(testCase,exist(htmlFile,'file') == 2);
[htmlDir,htmlName,htmlExt] = fileparts(htmlFile);
verifyEqual(testCase,htmlDir,tmpDir);
verifyEqual(testCase,[htmlName,htmlExt],'t_sceneIntroduction.html');
end

function testPublishEmbedsMarkedVideo(testCase)
tmpDir = tempname;
mkdir(tmpDir);
cleanupObj = onCleanup(@() rmdir(tmpDir,'s')); %#ok<NASGU>

movieName = 'tinyMovie.mp4';
movieFile = fullfile(tmpDir,movieName);
videoObj = VideoWriter(movieFile,'MPEG-4');
videoObj.FrameRate = 4;
open(videoObj);
writeVideo(videoObj,zeros(16,16,3));
writeVideo(videoObj,ones(16,16,3));
close(videoObj);

tmpMFile = fullfile(tmpDir,'t_videoMarker.m');
fid = fopen(tmpMFile,'w');
fprintf(fid,'%%%% Video Marker\n');
fprintf(fid,'%% iePublishVideo: %s\n',movieName);
fprintf(fid,'disp(''done'');\n');
fclose(fid);

htmlFile = iePublish(tmpMFile,'evalCode',false);
htmlText = fileread(htmlFile);

verifyNotEmpty(testCase,regexp(htmlText,'<video controls preload="metadata" width="512">','once'));
verifyNotEmpty(testCase,regexp(htmlText,'data:video/mp4;base64,','once'));
verifyFalse(testCase,isfile(movieFile));
end
