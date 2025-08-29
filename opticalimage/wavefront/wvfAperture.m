function [im, params] = wvfAperture(wvf, varargin)
% Create a synthetic aperture
%
% Synopsis
%   [im, params] = wvfAperture(wvf, varargin)
%
% Brief description:
%   Returns a pupil aperture function. A main application is creating
%   scattering flare. Returns an N x N monochromatic image emulating a
%   pupil aperture with small disks (dust) and lines (scratches).  The
%   disks and polylines have random size and opacity to an otherwise clear
%   aperture.
%
% Inputs
%   wvf: wavefront structure
%
% Optional key/val parameters
%  shape -  'rectangle','polygon' (Default: polygon)
%   n sides - Number of polygon sides
%   aspect ratio - rectangle aspect ratio
%
%  Line parameters
%   line mean - Number of lines
%   line sd   - Standard deviation of lines
%   line opacity -
%   line width   -
%   segment length -
%
%  Dot parameters
%   dot mean  - Number of dots
%   dot sd
%   dot opacity
%   dot radius
%
% Output
%  im: A matrix of values in the [0, 1] range. 0 means completely
%     opaque and 1 means completely transparent. The returned matrix
%     is real-valued.  We ignore any phase shift that may be
%     introduced by the "dust" and "scratches".
%
% See also
%   piFlareApply, RandomDirtyAperture
%

% Examples:
%{
    wvf = wvfCreate;
    im = wvfAperture(wvf); % Default with some scratches and dust.
    ieNewGraphWin; imagesc(im); colormap(gray); axis image
%}
%{
    % Diffraction limited, circular (no scratches or dust)
    wvf = wvfCreate;
    im = wvfAperture(wvf,'dot mean',0,'dot sd',0,'line mean',0,'line sd',0); 
    ieNewGraphWin; imagesc(im); colormap(gray); axis image
%}
%{
    wvf = wvfCreate;
    im = wvfAperture(wvf,'segment length',100); % Default
    ieNewGraphWin; imagesc(im); colormap(gray); axis image
%}
%{
    wvf = wvfCreate;
    [im,params] = wvfAperture(wvf,'n sides',8); 
    ieNewGraphWin; imagesc(im); colormap(gray); axis image
%}
%{
    wvf = wvfCreate;
    [im,params] = wvfAperture(wvf,'shape',...
                       'rectangle','aspect ratio',[2 1], ...
                       'dot mean',0,'dot sd',0,...
                       'line mean',0,'line sd',0); 
    ieNewGraphWin; imagesc(im); colormap(gray); axis image

%}

%% Inputs

varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('wvf',@isstruct);
p.addParameter('shape','polygon',@ischar);

p.addParameter('dotmean',20,@isnumeric);
p.addParameter('dotsd',5,@isnumeric);
p.addParameter('dotopacity',0.5,@isnumeric);
p.addParameter('dotradius',[],@isnumeric);

p.addParameter('linemean',20,@isnumeric);
p.addParameter('linesd',5,@isnumeric);
p.addParameter('lineopacity',0.5,@isnumeric);
p.addParameter('linewidth',2,@isnumeric);

p.addParameter('segmentlength',600,@isnumeric);

% Not sure what this is.  I think texture file is the name of an image
% file that represents the texture of the apodization function.
p.addParameter('texfile',[]);

p.addParameter('nsides',0, @(x)(isnumeric(x) && (x > 2 || x <= 0)));
p.addParameter('aspectratio',[1 1],@isvector);  % row, col
p.addParameter('imagerotate',[],@isnumeric);


p.parse(wvf,varargin{:});

shape       = p.Results.shape;        % Polygon or rectangle
aspectRatio = p.Results.aspectratio;  % [row,col] lengths of the rectangle
nSides      = p.Results.nsides;       % Number of polygon sides
rotatedeg   = p.Results.imagerotate;  % Rotate the final image in degrees

dotMean     = p.Results.dotmean;
dotSD       = p.Results.dotsd;
dotOpacity  = p.Results.dotopacity;
dotRadius   = p.Results.dotradius;
lineMean       = p.Results.linemean;
lineSD         = p.Results.linesd;
lineOpacity    = p.Results.lineopacity;
lineWidth      = p.Results.linewidth;
segmentLength  = p.Results.segmentlength;

texFile = p.Results.texfile;

%% Adjust sampling
imageSize = wvfGet(wvf, 'spatial samples');
im = ones([imageSize,imageSize], 'single');

%% Create the line and dot scratches.  If everything is 0, then no scratches.
if isempty(texFile)
    
    if isempty(dotRadius), dotRadius = round(imageSize/200); end
    
    %% Add dots (circles), simulating dust.

    % We should do more to control the random variable
    num_dots = randn(1,1)*dotSD + dotMean;
    num_dots = round(num_dots);

    % Make circles, but limit their size.
    % BW: Not sure why we don't just clip.
    max_radius = dotRadius*5;
    for i = 1:num_dots
        radius = max(round(dotRadius + rand*5),0);
        radius = min(radius,max_radius);
        circle_xyr = rand(1, 3, 'single') .* [imageSize, imageSize, radius];
        opacity = dotOpacity + (rand * 0.5);
        opacity = min(opacity,1);

        % Computer vision toolbox
        im = insertShape(im, 'FilledCircle', circle_xyr, 'Color', 'black', ...
            'Opacity', opacity);
    end

    %% Add polylines, simulating scratches.

    num_lines = randn(1,1)*lineSD + lineMean;
    num_lines = round(num_lines);

    % max_width = max(0, round(5 + randn * 5));
    for i = 1:num_lines

        num_segments = randi(16);
        segment_length = rand * segmentLength;

        % Start position
        start_xy = rand(2, 1) * imageSize;
        %
        segments_xy = RandomPointsInUnitCircle(num_segments) * segment_length;
        vertices_xy = cumsum([start_xy, segments_xy], 2);
        vertices_xy = reshape(vertices_xy, 1, []);

        % Width of the scratches
        width = round(max(1,lineWidth + randn*(lineWidth/2)));

        % Note: the 'Opacity' option doesn't apply to lines, so we have to change the
        % line color to achieve a similar effect. Also note that [0.5 .. 1] opacity
        % maps to [0.5 .. 0] in color values.
        opacity = lineOpacity + (rand * 0.5);
        im = insertShape(im, 'Line', vertices_xy, 'LineWidth', width, ...
            'Color', [opacity, opacity, opacity]);
    end
else
    % There is a texture file that must be an image
    im = imread(texFile);
    try
        im = rgb2gray(im);
    catch
        % do nothing
    end
    im = double(im);
    im = im/max2(im);

    if mean2(im)<0.2
        im = 1-im;
    end
    im(im<0.95) = im(im<0.95)-rand(1);
    im(im<0)=0;
    im = imresize(im, [imageSize, imageSize]);
end
centerPoint = [imageSize/2 + 1, imageSize/2+1];
radius = (imageSize - 1)/2;

%% Make the basic outline shape
switch shape
    case 'polygon'
        if nSides > 0
            % create n-sided polygon
            pgon1 = nsidedpoly(nSides, 'Center', centerPoint, 'radius', radius);
            % create a binary image with the polygon
            pgonmask = poly2mask(floor(pgon1.Vertices(:,1)), floor(pgon1.Vertices(:,2)), imageSize, imageSize);
            im = im.*pgonmask;
        end
    case 'rectangle'
        % Make the rectangle a little smaller than image size
        % aspectRatio = [1 2];  % Row, Col
        im = imresize(im, [imageSize, imageSize]);
        mx = max(aspectRatio); 
        
        % These are the two lengths of the rectangle.  Do we want to
        % be able to rotate? 
        rectSides = round((aspectRatio/(1.1*mx))*imageSize);
        
        % Middle of the image plus and minus half the rectangle sizes.
        ll = [imageSize/2 - rectSides(2)/2,imageSize/2 - rectSides(1)/2];
        ul = [imageSize/2 - rectSides(2)/2,imageSize/2 + rectSides(1)/2];
        ur = [imageSize/2 + rectSides(2)/2,imageSize/2 + rectSides(1)/2];
        lr = [imageSize/2 + rectSides(2)/2,imageSize/2 - rectSides(1)/2];
        
        % Four corners, lowerleft, lower right moving clockwise
        corners = round([ll(1),ll(2); ul(1),ul(2); ur(1),ur(2); lr(1),lr(2)]);
        pgonmask = poly2mask(floor(corners(:,1)), floor(corners(:,2)), imageSize, imageSize);
        im = im.*pgonmask;
        
        % ieFigure; plot(corners(:,1),corners(:,2),'o'); axis equal
        % ieFigure; imshow(pgonmask); axis image
        % ieFigure; imshow(im); axis image
    otherwise
        error('Unknown shape:  %s\n',shape);
end

% Color image to gray. In some cases, when there are no dots or scratches,
% im is just gray scale.
if ndims(im) == 3
    im = rgb2gray(im);
end
% ieNewGraphWin; imagesc(im); colormap(gray); colorbar; axis image

switch shape
    case 'polygon'
        % Now make the pattern circular
        [X,Y] = meshgrid((1:imageSize) - centerPoint(1),(1:imageSize) - centerPoint(2));
        imRadius = sqrt(X.^2 + Y.^2);
        % ieNewGraphWin; imagesc(imRadius); colormap(gray); colorbar; axis image
        idx = (imRadius > radius);
        im(idx) = 0;

        % Not sure why we did a random rotation in this case.  Zhenyi
        % may know.  Not me (BW).  I added a parameter to specifically
        % control this rotation. 
        if isempty(rotatedeg), im = imrotate(im,randi(30));
        else,                  im = imrotate(im,rotatedeg);
        end
    case 'rectangle'
        if ~isempty(rotatedeg)
            im = imrotate(im,rotatedeg);
        end
    otherwise
end

%% Return parameters
if nargout == 2
    params.dotMean = dotMean;
    params.dotSD = dotSD;
    params.dotOpacity = dotOpacity;
    params.dotRadius = dotRadius;
    params.lineMean = lineMean;
    params.lineSD = lineSD;
    params.lineOpacity = lineOpacity;
    params.lineWidth = lineWidth;
    params.segmentLength = segmentLength;
    params.nsides = nSides;
end

end

%% Utility function

function xy = RandomPointsInUnitCircle(num_points)
% Random point generation within the unit circle

r = rand(1, num_points, 'single');   % Between 0 and 1

theta = rand(1, num_points, 'single') * 2 * pi; % Between 0 and 2pi

xy = [r .* cos(theta); r .* sin(theta)];  % Convert r,theta to xy

end
