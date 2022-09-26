%% Calculate the CIELAB and S-CIELAB color difference for uniform patches.
%
% There is no difference because S-CIELAB was designed to match CIELAB in
% the uniform case.
%
% There are differences, however, when there is spatial structure in the
% image and we compare a point-wise CIELAB with S-CIELAB.
%
% See also:  s_scielabMTF - shows the effect of spatial frequency on the
% color difference measure.
%
% Copyright Imageval 2012

%%
ieInit

%%  Here is a standard uniform patch
uStandard = sceneCreate('uniform');
% vcAddAndSelectObject(uStandard); sceneWindow;

whiteXYZ    = sceneGet(uStandard,'illuminant xyz');
illuminantE = sceneGet(uStandard,'illuminant energy');
wave   = sceneGet(uStandard,'wave');
nWave  = sceneGet(uStandard,'nwave');
lambda = (1:nWave)/nWave;

% vcNewGraphWin; plot(wave,eAdjust1);
% vcNewGraphWin; plot(wave,eAdjust2);

%% Make a second uniform test field, but with a different color
[w1,w2] = meshgrid(-0.3:.1:.3,-0.3:.1:.3);
wgts = [w1(:),w2(:)];
nPairs = size(wgts,1);
dE = ones(nPairs,1);
dES = ones(nPairs,1);
showBar = ieSessionGet('waitbar');
if showBar, wBar = waitbar(0,'Patches'); end

%%
for ii=1:size(wgts,1)
    if showBar, wBar = waitbar(ii/size(wgts,1),wBar,'Patches'); end
    
    w1 = wgts(ii,1); w2 = wgts(ii,2);
    % fprintf('Weights: %.2f, %.2f\n',w1,w2);
    
    % Funny way to adjust the illuminant.  We should figure out a way that
    % specifies the XYZ of the uniform field directly, without this kind of
    % a cheap trick.
    eAdjust1 = w1*sin(2*pi*lambda);
    eAdjust2 = w2*cos(2*pi*lambda);
    newIlluminant = illuminantE .*  (w1*eAdjust1(:) + w2*eAdjust2(:) + 1);
    uTest = sceneAdjustIlluminant(uStandard,newIlluminant);
    % vcAddAndSelectObject(uTest); sceneWindow;
    
    %% Compute CIELAB difference
    xyz1 = sceneGet(uStandard,'xyz');
    xyz2 = sceneGet(uTest,'xyz');
    tmp = deltaEab(xyz1,xyz2,whiteXYZ,'2000');
    dE(ii) = mean(tmp(:));
    
    % fprintf('Mean delta E for S-CIELAB %f\n',mean(dE(:)));
    % vcNewGraphWin; mesh(dE)
    % mean(RGB2XWFormat(xyz1))
    % mean(RGB2XWFormat(xyz2))
    
    %% Compute S-CIELAB difference map
    tmp = scielab(xyz1,xyz2,whiteXYZ,scParams);
    dES(ii) = mean(tmp(:));
    % fprintf('Mean delta E for S-CIELAB %f\n',mean(dES(:)));
end
if showBar, close(wBar); end

% vcNewGraphWin; mesh(dES)
% mean(RGB2XWFormat(xyz1))
% mean(RGB2XWFormat(xyz2))

%% Compare delta E values
%%
%
% # ITEM1
% # ITEM2
%
ieNewGraphWin;
plot(dE(:),dES(:),'o')
title('CIELAB vs. SCIELAB for uniform patches')
xlabel('CIELAB \Delta E')
ylabel('SCIELAB \Delta E')
axis on; grid on; identityLine;

% Store a hash of the quantized dES values.
s = 2; hsh = s * round(dES/s);
assert(isequal(md5(sprintf('%s',hsh)),'00347c470fdb59dc96ddf0e53797b46a'))


%% End