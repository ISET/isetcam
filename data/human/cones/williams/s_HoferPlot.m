% Plot the cone mosaic data from the Hofer et al. J. Neurosci paper
%
% Syntax:
%   s_HoferPlot
%
% Description:
%    Plot the cone mosaic data from the Hofer et al. J. Neurosci paper.
%
% Inputs:
%    None.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%

curDir = pwd;
pDir = fullfile(synapseRootPath, 'receptors', 'data', 'williams');
chdir(pDir)

% How did we get these?  From some xls spreadsheet on the web.
subj = {'HS', 'AP', 'BS', 'MD', 'YY'};
for ii = 1:length(subj)
    load(subj{ii})
    [r, c] = size(psf{1});
    x = (1:c) * umPerPixel;
    x = x - mean(x);
    y = (1:r) * umPerPixel;
    y = y - mean(y);

    % mesh(x, y, psf{2})

    % Now, show the positions of the cone types
    % L = coneType == 1;
    % M = coneType == 2;
    % S = coneType == 3;
    % plot(xy(L, 1), xy(L, 2), 'ro', xy(M, 1), xy(M, 2), 'go', ...
    %     xy(S, 1), xy(S, 2), 'bo');

    % coneColorMap = [.5 .5 .5; 1 0 0 ; 0 1 0 ; 0 0 1];
    % The Hofer data are not on a perfect grid. For creating an image we
    % need to place them on a grid. The ffndgrid() routine is pretty cool.
    delta = 0.4;
    % The range of the xy data
    low = floor(min(xy(1, :)));
    high = ceil(max(xy(1, :)));
    [fgrid, xvec] = ffndgrid(xy, coneType, delta);

    % We have the grid. Figure out where the cone types are and make an
    % image
    fgrid = full(flipud(fgrid));

    L = find(fgrid == 1);
    M = find(fgrid == 2);
    S = find(fgrid == 3);

    coneImage = zeros(numel(fgrid), 3);
    coneImage(L, :) = repmat([1, 0, 0], length(L), 1);
    coneImage(M, :) = repmat([0, 1, 0], length(M), 1);
    coneImage(S, :) = repmat([0, 0, 1], length(S), 1);
    coneImage = reshape(coneImage, size(fgrid, 1), size(fgrid, 2), 3);

    g = fspecial('gaussian', [11, 11], 3);
    tmp = imfilter(coneImage, g);

    figure(ii);
    imagescRGB(tmp);
    title(sprintf('Subject %s', subj{ii}));
end

chdir(curDir)
