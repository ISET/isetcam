function oi = oiCombineDepths(oiD)
% Combine defocused OI from multiple depths.  Always ordered back to front
%
%   oi = oiCombineDepths(oiD)
%
% oiD is a cell array of OIs.  The oiD are computed from the parts of a
% scene at different depths. They should have their own depth planes
% attached, but for now we send these in as the cell array dPlanes.
%
% We combine the irradiance data by superimposing the nearer ones on
% top of the farther ones. This algorithm has imperfections we are trying
% to improve upon.
%
% Copyright ImagEval Consultants, LLC, 2011.

if ieNotDefined('oiD'), error('OI cell array for depths required'); end

    % Basic parameters
    nDepths = length(oiD);
    nWave = oiGet(oiD{1}, 'nWave');
    wave = oiGet(oiD{1}, 'wave');

    % The oiD are ordered from nearest to farthest depth plane.

    % Allocate space for
    sz = oiGet(oiD{1}, 'size');
    dMaps = zeros(sz(1), sz(2), nDepths);

    % Maybe handle one wavelength at a time because of space issues.
    for ii = 1:nDepths
        dMaps(:, :, ii) = oiGet(oiD{ii}, 'depthMap');
    end

    % The depth map for the output will be the closest image plane at that
    % point.
    z = (dMaps == 0);
    mxDepth = 2 * max(dMaps(:));
    dMaps(z) = mxDepth;
    dMap = min(dMaps, [], 3);
    dMap(dMap == mxDepth) = 0;
    % figure; imagesc(dMap)

    % Output photons
    photons = zeros(sz(1), sz(2), nWave);

    for ii = 1:nDepths
        p = oiGet(oiD{ii}, 'photons');
        photons = photons + p;
    end

    % Should we adjust the points at the depth discontinuities?
    % [fx,fy] = gradient(dMap); g =sqrt(fx.^2 + fy.^2); g = g/max(g(:));
    % f = figure; imageSPD(photons,wave); hold on

    % I = sum(photons,3); I = I/max(I(:));
    % figure; h = imshow(I); set(h,'AlphaData',1- g)

    % l = del2(dMap); % Laplacian operator, more or less
    % imagesc(abs(l)) % 0 where there is no change.


    % dMap    = oiGet(oiD{nDepths},'depth map');   % figure; imagesc(dMap)
    % for ii=1:nWave
    %     % Outside of the logical area, we don't want to add
    %     p = photons(:,:,ii);
    %     p(~dMap) = 0;
    %     % Put the good ones back into photons
    %     photons(:,:,ii) = p;
    % end
    % figure; imageSPD(photons,wave);

    % Loop through nearer planes, adding their photons in turn
    % for jj=(nDepths-1):-1:1
    %
    %     % Combine the OI depth maps
    %     thisMap = oiGet(oiD{jj},'depth map');
    %     bothMap = thisMap & dMap;
    %     % Zero out photons from behind this map.
    %     for ii=1:nWave
    %         p = photons(:,:,ii);
    %         p(bothMap) = 0;
    %         % Put the good ones back into photons
    %         photons(:,:,ii) = p;
    %     end
    %     dMap = (dMap | thisMap);     % New cumulative depth map
    %
    %     % figure; imagesc(thisMap); figure; imagesc(dMap);
    %     % figure; imagesc(bothMap)
    %
    %     for ii=1:nWave
    %
    %         % Photons from this depth plane
    %         nPhotons = oiGet(oiD{jj},'photons',wave(ii));  % New photons
    %
    %         % Outside of the logical area, we don't want to add
    %         nPhotons(~thisMap) = 0;
    %
    %         % Accumulate the ones inside the area into the list
    %         photons(:,:,ii) = photons(:,:,ii) + nPhotons;
    %
    %     end
    %     % figure; imageSPD(photons,wave);
    % end


    % Create a new, combined oi with the combined photons and depth map
    oi = oiSet(oiD{1}, 'photons', photons);
    oi = oiSet(oi, 'depth map', dMap);
    % ieAddObject(oi); oiWindow

    return
