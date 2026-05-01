function tests = test_wvfPadPSF()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
% v_icam_wvfPadPSF
%
% Testing the problem with failure to pad with the
% ImageConvFrequencyDomain issue.
%
% NOTE:
% This will need to be changed when we shift the convention for
% calling opticsotf and opticspsf.
%
% Historically, I ran this with 'human wvf', but to keep it in the
% ISETCam validation, BW made it just 'wvf'.
%

%%  Set up the scene
ieInit;

% When the size is even, no shift.  When the size is odd, there is a
% one pixel shift.  See this by comparing the line d65 cases.

% N.B. For this scene the size is always constructed odd, even when we
% specify even! It has to do with the construction method.
% scene = sceneCreate('slanted edge');

% The agreement is better as imSize is larger
imSize = 512; scene = sceneCreate('grid lines',imSize,imSize/4);

% scene = sceneCreate('macbeth d65');
% scene = sceneCreate('line d65',255);  % Shift
% scene = sceneCreate('line d65',256);  % No shift

scene = sceneSet(scene,'fov',1);

%% This scene produced the error when using the old code

oi = oiCreate('wvf');

oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');

% With the old code, the plot rolls off to zero and does not stay at
% the mean level.
data1 = oiPlot(oi,'illuminance hline',round([1 sz(2)/2]),'nofigure');

%% Compare the opticsOTF  path.  It does not have the error.

oi = oiCreate('wvf');

oi = oiSet(oi,'compute method','opticsotf');

oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');

% Notice that the line rolls off to zero and does not stay at the mean
% level.
data2  = oiPlot(oi,'illuminance hline',round([1 sz(2)/2]),'nofigure');

%% Check that the two methods are close

% Have a look if you are here.
% ieNewGraphWin; plot(data1.pos,data1.data,'r-',data2.pos,data2.data,'ko');

% Fractional error is a couple of percent
assert(std( (data1.data ./ data2.data) ) < 4e-2)


%% Now check opticsPSF and opticsOTF with pad value of zero

% Use the non-human, diffraction limited, wvf.
oi = oiCreate('wvf');

oi = oiCompute(oi,scene,'pad value','zero','crop',false);
sz = oiGet(oi,'size');

% Notice that the line rolls off to zero and does not stay at the mean
% level.
uDataPSF = oiPlot(oi,'illuminance hline',round([1 sz(2)/2]),'nofigure');

oi = oiCreate('wvf');
oi = oiCompute(oi,scene,'pad value','zero','crop',false);
sz = oiGet(oi,'size');
uDataOTF = oiPlot(oi,'illuminance hline',round([1 sz(2)/2]),'nofigure');

%% Compare.  This is bigger than I would like. About 1.5 percent

d1 = ieScale(uDataOTF.data,1);
d2 = ieScale(uDataPSF.data,1);

ieNewGraphWin([],'tall');
tiledlayout(2,1);
nexttile;
plot(uDataOTF.pos,d1,'ro',uDataPSF.pos,d1,'gs');
grid on;  title('No shift'); legend({'OTF','PSF'});
nexttile;
plot(d1,d2,'k.');
identityLine;

assert(max( abs(d1 - d2) ) < 2e-2)


%% END


end
