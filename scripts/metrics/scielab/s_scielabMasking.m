%% s_scielabMasking
%
% In s_scielabMTF, we calculate the delta E between
% a uniform patch and a targets with different frequencies at 50% contrast.
% Plotting delta E as function of target frequency gives us an MTF
%
% In this script,we keep the frequency and contrast of a background (mask) constant and
% increase the contrast of the target until we reach a fixed delta E value
% (e.g. DE = 5).  We record this as contrast treshold and plot it as a
% function of the background contrast

%
% Copyright Imageval 2012

%%  Initialize ISET and the parameters
ieInit

%%
% List of frequencies to test
fList = [2,4,8,16,32];
nFreq = length(fList);
% List of mask contrasts to test
mList = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, .7, 0.8, 0.9];
nMaskContrast = length(mList);
% List of target contrasts to test
tList = (0.05:0.05:0.2);
nTargetContrast = length(tList);

% Allocate space for the two types of delta E values
dE = ones(nTargetContrast,1);
dES = ones(nTargetContrast,1);

%% fixed parameters
parms.ph = 0; parms.ang= 0;
parms.row = 128; parms.col = 128;
parms.GaborFlag=0;
%% could vary frequency later
parms.freq = fList(2);
%%
maskContrast = 0.8;
parms.contrast = maskContrast;
Mask = sceneCreate('harmonic',parms);
Mask= sceneSet(Mask,'fov',1);
Mask = sceneSet(Mask,'name','Mask');
vcAddAndSelectObject(Mask); sceneWindow;
whiteXYZ    = sceneGet(Mask,'illuminant xyz')* 2;
illuminantE = sceneGet(Mask,'illuminant energy');
wave   = sceneGet(Mask,'wave');
nWave  = sceneGet(Mask,'nwave');
lambda = (1:nWave)/nWave;

% Make a target with same spatial frequency as mask but increase contrast
for ii = 1:nTargetContrast
    parms.contrast = tList(ii);
    Target = sceneCreate('harmonic',parms);
    Target = sceneSet(Target,'fov',1);
    Target = sceneSet(Target,'name','Target');
    uTarget = sceneAdd(Mask,Target,'remove spatial mean');
    uTarget = sceneSet(uTarget,'name','Target + Mask');
    vcAddAndSelectObject(uTarget); sceneWindow;
    
    % Compute CIELAB difference
    xyz1   = sceneGet(Mask,'xyz');    xyz1(xyz1<0) = 0;
    xyz2   = sceneGet(uTarget,'xyz'); xyz2(xyz2<0) = 0;
    tmp    = deltaEab(xyz1,xyz2,whiteXYZ,'2000');
    dE(ii) = mean(tmp(:));
    
    % Compute S-CIELAB difference map
    tmp = scielab(xyz1,xyz2,whiteXYZ,scParams);
    dES(ii) = mean(tmp(:));
    
end


%% Compare delta E values computed the two ways
vcNewGraphWin;
semilogx(tList,dES(:),'-s',tList,dE(:),':o')
set(gca,'ylim',[0 max(dE(:))*1.2])
xlabel('Target Contrast')
ylabel('delta E')
title(sprintf('Frequency = %.2f, Mask Contrast = %0.2f',parms.freq,maskContrast));
grid on
legend('S-CIELAB','CIELAB')

%% End
