function [support, spread, delta, coneMosaicImage] = conePlot(...
    xy, coneType, support, spread, delta, whiteBackground, absorptions)
% Plot a saturated image of the human cone mosaic
%
% Syntax:
%   [support, spread, delta, [coneMosaicImage]] = conePlot(xy, ...
%       coneType, [support], [spread], [delta], [whiteBackground], ...
%       [absorptions])
%
% Description:
%    Plot a saturated image of the human cone mosaic.
%
%    These images can be compared with the ones measured by Hofer et al. in
%    the J. Neuroscience paper and then published by Williams in a JOV
%    paper. I downloaded those from
%
%       http://www.journalofvision.org/5/5/5/article.aspx#tab1
%
%    Those data and the plotting routine for them are in the repository
%    under cone/data/williams.
%
%    This function contains examples of usage inline. To access, type 'edit
%    conePlot.m' into the Command Window.
%
% Inputs:
%    xy              - Matrix. Integer matrix of cone xy positions(microns)
%    coneType        - Vector. Vector containing integer(s) from 1:4 where
%                      1 means no cone (K), 2:4 are L, M, S support,
%                      spread, delta are gaussian blurring parameters for
%                      creating the image.
%    support         - (Optional) Vector. 1x2 Vector containing the number
%                      of rows and columns for each cone. The default is
%                      the cone-cone separation.
%    spread          - (Optional) Numeric. The spatial spread for each cone
%                      (computed by default). Default is 2.1.
%    delta           - (Optional) Numeric. Spacing between the cones
%                      (microns). Default is 0.25 microns.
%    whiteBackground - (Optional) Boolean. The boolean indicating whether
%                      to generate an image with white or black background.
%                      The default is false (black background)
% Outputs:
%    support         - Vector. 1x2 Vector containing the number of rows and
%                      columns comprising the image support. If not
%                      previously provided, the calculated values. Default
%                      is [8 8].
%    spread          - Numeric. The Gaussian  spread value. If not provided, then is
%                      the default, 2.1.
%    delta           - Numeric. The spacing in microns between samples of
%                      the coneMosaicImage. 
%                      Default value is 0.25.
%    coneMosaicImage - (Optional) The image. If this fourth output argument
%                      is present, the function returns the RGB image and
%                      does NOT plotting the image.
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    sensorConePlot, humanConeMosaic
%

% History:
%    xx/xx/09       Copyright ImagEval LLLC, 2009
%    06/12/18  jnm  Formatting
%    03/19/19  npc  Fixed example  to work with @coneMosaicHex

% Examples:
%{
    sz = [75, 75];
    densities = [0.4 .5 .6 .3];
    [xy, coneType] = humanConeMosaic(sz, densities);
    [support, spread, delta] = conePlot(xy, coneType(:));
%}

%%
if notDefined('delta'), delta = 0.25; end  % Sampling in microns
% support and spread are adjusted below, after the grid is built

% Grid the xy cone positions to the delta spacing using a fast method
% fgrid = ffndgrid(xy, coneType, delta);
fgrid = ffndgrid(xy, coneType(:), 0.25);
fgrid = full(fgrid);

% tic
% xMin = min(xy(:, 1));
% xMax = max(xy(:, 1));
% yMin = min(xy(:, 2));
% yMax = max(xy(:, 2));
% [xg, yg] = meshgrid(xMin:delta:xMax, yMin:delta:yMax);
% tic
% vq = griddata(xy(:, 1), xy(:, 2), coneType(:), xg, yg);
% toc

% Grid the cone absorption rates the same way
if exist('absorptions', 'var')
    % This is the interpolation of the absorption data
    dgrid = ffndgrid(xy, absorptions(:), delta);
    dgrid = fullgrid(dgrid);
end
% Could have an else dgrid = ones(size(xy, 1), 1) here and then eliminate
% the else below.

%% Find the positions of the empty (K) and three cone types
K = find(fgrid == 1);
L = find(fgrid == 2);
M = find(fgrid == 3);
S = find(fgrid == 4);

% Wherever there is a red cone, we put (1, 0, 0) and so forth for the
% other cone types.
% We start with a coneImage that is nCones x 3
coneImage = zeros(numel(fgrid), 3);

if exist('dgrid', 'var')
    coneImage(K, :) = repmat([0, 0, 0], length(K), 1);
    coneImage(L, :) = repmat([dgrid(L), 0, 0], length(L), 1);
    coneImage(M, :) = repmat([0, dgrid(M), 0], length(M), 1);
    coneImage(S, :) = repmat([0, 0, dgrid(S)], length(S), 1);
else
    % We set the L cone rows to red, ... and so forth
    coneImage(K, :) = repmat([0, 0, 0], length(K), 1);
    coneImage(L, :) = repmat([1, 0, 0], length(L), 1);
    coneImage(M, :) = repmat([0, 1, 0], length(M), 1);
    coneImage(S, :) = repmat([0, 0, 1], length(S), 1);
end

% Reshape the image to its actual (row, col, 3) size
coneImage = reshape(coneImage, size(fgrid, 1), size(fgrid, 2), 3);
% mp = [0 0 0 ; 1 0 0 ; 0 1 0; 0 0 1];
% image(fgrid);
% colormap(mp)

%% Blur the image by a Gaussian - we set blur and support here.

if notDefined('support')
    % Find cone positions and set support to spacing between the cones in
    % the coneImage
    conePos = find(coneImage(1,:));
    coneSep = conePos(2) - conePos(1);
    support = [coneSep,coneSep];
end

% Not sure that I have this right.  Setting this has a big impact on
% how the rendered mosaic looks.  Keep experimenting.  (BW).
if notDefined('spread')
    if support(1) < 20
        spread = (support(1)/3);
    elseif support(1) < 30
        spread = (support(1)/4);
    elseif support(1) < 40
        spread = (support(1)/5);
    else
        spread = (support(1)/6);
    end    
end

if notDefined('whiteBackground'), whiteBackground = false; end
if (whiteBackground)
    g = fspecial('gaussian', support, spread);
    g = g / max(g(:));
    g(g < 0.1) = 0;
    g = 1.5 * g .^ 0.3;
    g(g > 1) = 1.0;
else
    g = fspecial('gaussian', support, spread);
end

tmp = imfilter(coneImage, g);

if (whiteBackground)
    tmp = tmp / max(tmp(:));
    indices = all(tmp < .75, 3);
    tmp(repmat(indices, [1, 1, 3])) = 1;
end

%%
if (nargout < 4)
    % Show the image
    h = vcNewGraphWin;
    set(h, 'Name', 'ISET: Human cone mosaic');
    imagescRGB(tmp);
else
    % return the image
    coneMosaicImage = tmp / max(tmp(:));
end

end