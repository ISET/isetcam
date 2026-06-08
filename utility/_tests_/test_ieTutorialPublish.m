function tests = test_ieTutorialPublish()
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

htmlFile = ieTutorialPublish(tmpMFile,'evalCode',false);

verifyTrue(testCase,exist(htmlFile,'file') == 2);
[htmlDir,htmlName,htmlExt] = fileparts(htmlFile);
verifyEqual(testCase,htmlDir,tmpDir);
verifyEqual(testCase,[htmlName,htmlExt],'t_sceneIntroduction.html');
end
