function scene = sceneAddGrid(scene,pSize,gWidth)
% Add black grid lines to the photon data in a scene
%
%    scene = sceneAddGrid(scene,pSize,gWidth)
%
% Inputs:
%   scene:   ISET scene
%   pSize:   2-vector for row/col spacing of the grid lines
%   gWidth:  grid line width (i.e., width of the grid lines)
%
% The grid lines are placed at locations pSize, 2*pSize, and so forth, for
% both the row and column dimension.
%
% Example:
%   scene = sceneAddGrid(sceneCreate,[16,16],1);
%   ieAddObject(scene); sceneWindow;
%
% (c) Imageval Consultants, LLC, 2012

if ieNotDefined('scene'), scene = vcGetObject('scene'); end
if ieNotDefined('pSize')
    sz = sceneGet(scene,'size'); pSize = sz(1)/2;
end
if ieNotDefined('gWidth'), gWidth = 1; end
if length(pSize) == 1, pSize(2) = pSize(1); end

%% Add the row black lines
sz    = sceneGet(scene,'size');
nWave = sceneGet(scene,'n wave');
black = zeros(1,sz(2),nWave);
p     = sceneGet(scene,'photons');
eWidth = gWidth;
% max(floor(gWidth/2),1);
for gg = 1:eWidth
    p(gg,:,:) = black;
end
for rr = pSize(1):pSize(1):(sz(1)-1)
    for gg = rr:(rr+(gWidth-1))
        p(gg,:,:) = black;
    end
end
for gg = (sz(1) - eWidth + 1):sz(1)
    p(gg,:,:) = black;
end

%% Add the column black lines
black = zeros(sz(1),1,nWave);
for gg = 1:eWidth
    p(:,gg,:) = black;
end
for cc =pSize(2):pSize(2):(sz(2)-1)
    for gg = cc:(cc+(gWidth-1))
        p(:,gg,:) = black;
    end
end
for gg = (sz(2)-eWidth + 1):sz(2)
    p(:,gg,:) = black;
end

%% Put the photons back into the scene
scene = sceneSet(scene,'photons',p);

end

