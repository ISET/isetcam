%% S-CIELAB calculation as a function of spatial frequency
%
% The S-CIELAB color difference matches CIELAB with a uniform background.
% But for a pattern, they differ.  This shows the difference.
%
% See also:  s_scielabPatches - shows no difference for uniform patches,
% like the 0 spatial frequency in this chart.
%
% Copyright Imageval 2012

%% Initialize ISET and the parameters
ieInit

%% List of frequencies to test
fList = [1,2,4,8,16,32];
nFreq = length(fList);

% Color parameters
w1 = 0.0; w2 = 0.0;

%% Calculate the delta E of S-SCIELAB between a uniform and grating

% Here is a uniform patch (0 contrast)
parms.freq = fList(1); 
parms.contrast = 0.0; parms.ph = 0; parms.ang= 0; 
parms.row = 128; parms.col = 128;
parms.GaborFlag=0;
uStandard = sceneCreate('harmonic',parms);
uStandard = sceneSet(uStandard,'fov',1);
uStandard = sceneSet(uStandard,'name','standard');
ieAddObject(uStandard); sceneWindow;

whiteXYZ    = sceneGet(uStandard,'illuminant xyz');
illuminantE = sceneGet(uStandard,'illuminant energy');
wave   = sceneGet(uStandard,'wave');
nWave  = sceneGet(uStandard,'nwave');
lambda = (1:nWave)/nWave;

%% Make a test harmonic of a slightly different color than the background.

% These weights can be used to set the color.  When they are both 0, then
% the harmonic has the same color as the background.
parms.contrast = 0.5;

% Allocate space for the two types of delta E valkues
dE = ones(nFreq,1);
dES = ones(nFreq,1);

% Create harmonic scene that will add to uniform
for ii=1:nFreq    
    parms.freq = fList(ii);
    uTest = sceneCreate('harmonic',parms);
    uTest = sceneSet(uTest,'fov',1);

    % Funny way to adjust the color.  We should figure out a way that
    % specifies the XYZ of the uniform field directly, without this kind of
    % a cheap trick.
    if (w1 ~= 0) || (w2 ~= 0)
        eAdjust1 = w1*sin(2*pi*lambda);
        eAdjust2 = w2*cos(2*pi*lambda);
        newIlluminant = illuminantE .*  (w1*eAdjust1 + w2*eAdjust2 + 1);
        uTest = sceneAdjustIlluminant(uTest,newIlluminant);
    end
    
    uTest = sceneAdd(uStandard,uTest,'remove spatial mean');
    uTest = sceneSet(uTest,'name',sprintf('Test %d',fList(ii)));
    ieAddObject(uTest); sceneWindow;
    
    % Compute CIELAB difference
    xyz1   = sceneGet(uStandard,'xyz');
    xyz2   = sceneGet(uTest,'xyz');
    tmp    = deltaEab(xyz1,xyz2,whiteXYZ,'2000');
    dE(ii) = mean(tmp(:));
    
    % Compute S-CIELAB difference map
    tmp = scielab(xyz1,xyz2,whiteXYZ,scParams);
    dES(ii) = mean(tmp(:));
    
end


%% Compare delta E values computed the two ways
vcNewGraphWin;

p = semilogx(fList,dES(:),'-s',fList,dE(:),':o');
set(p,'linewidth',2);

set(gca,'ylim',[0 max(dES(:))*1.2]); grid on
xlabel('Spatial frequency (cpd)'); ylabel('\Delta E');
title('CIELAB and S-CIELAB MTF');
legend('S-CIELAB','CIELAB');

%%
