function RGB = MOTarget(pattern,parms)
% Create a circular moire pattern target
%
%  RGB = MOTarget(pattern,parms)
%
% pattern:  A string defining the contrast pattern (default)
%   'squareim', 'sinusoidalim_line', 'squareim_line', 'flat'

% parms:    A structure containing parameters.  These differ by case
%
%  .sceneSize - any case
%  .????
%
% See Also:
%
% Examples:
%  im = MOTarget('sinusoidalim');
%
%(c) Imageval Consulting, 2013

%% Test input parameters

if ieNotDefined('pattern'), pattern = 'sinusoidalim'; end
pattern = ieParamFormat(pattern);

if ieNotDefined('parms'), parms = struct; end

sceneSize = 512;   % Samples
if isfield(parms,'sceneSize'), sceneSize = parms.sceneSize; end

%% Create Scene

% A constant that controls initial frequency Goal is to avoid aliasing in
% this image but still make it hard for a camera to render the scene
% properly.  We will have to experiment to find out what value is best
% here. Remember this is the scene so even an ideal sensor should have a
% lower resolution version of this.

% f=1/pixelwidth/10*4;        %seems to be at Nyquist limit at edges, too hard
% f=1/pixelwidth/10*2;        %1/2 Nyquist at edges, perhaps still too hard

f    = 1/sceneSize/10;        %1/4 Nyquist at edges, more feasible
if isfield(parms,'f'), f = params.f; end

[x,y]= meshgrid(1:sceneSize);
dist = sqrt(x.^2+y.^2);

switch lower(pattern)
    case 'sinusoidalim'
        %% Generate sinusoidal and square chirps
        im=sin(2*pi*f/2*dist.^2);
        
    case 'squareim'
        %% threshold the sinusoidal pattern to get the square pattern
        im = sin(2*pi*f/2*dist.^2);
        im = (1+sign(im-.5))/2;
    case 'sinusoidalim_line'
        %% Generate sinusoidal and square chirps
        %% Line Parameters
        f_line         =.001;  %frequency
        if isfield(parms,'f_line'), f_line = parms.f_line; end
        
        theta_line     = pi/2; %orientation angle
        if isfield(parms,'theta_line'), theta_line = parms.theta_line; end
        
        spacing_line   = 1:500;  %number of pixels on a side of the final image, we should make sure this is much higher than in our sensor later
        if isfield(parms,'spacing_line'), spacing_line = parms.spacing_line; end
        
        
        [x_line,y_line]= meshgrid(2*pi/f_line*spacing_line,spacing_line');
        
        im=sin(f_line*(cos(theta_line)*x_line+sin(theta_line)*y_line).^2);
    case 'squareim_line'
        %% Line Parameters
        f_line         =.001;  %frequency
        theta_line     = pi/2; %orientation angle
        spacing_line   = 1:500;  %number of pixels on a side of the final image, we should make sure this is much higher than in our sensor later
        [x_line,y_line]= meshgrid(2*pi/f_line*spacing_line,spacing_line');
        
        %% threshold the sinusoidal pattern to get the square pattern
        im=sin(f_line*(cos(theta_line)*x_line+sin(theta_line)*y_line).^2);
        im=(1+sign(im-.5))/2;
    case 'flat'
        %% threshold the sinusoidal pattern to get the square pattern
        im=ones(500,500).*255;
    otherwise
        error('MOTarget:  Unrecognized pattern');
end

im = im';
RGB = repmat(im,[1 1 3]);

end

%
% squareim=(1+sign(sinusoidalim-.5))/2;
%
% %% Make images
% imwrite(sinusoidalim, 'sinusoidalim.jpg');
% imwrite(squareim, 'squareim.jpg');
%
% %% Show images
% figure(1)
% imagesc(sinusoidalim)
% axis square
% colormap(gray(64))
% title('Sinusoidal Image')
%
% figure(2)
% imagesc(squareim)
% axis square
% colormap(gray(64))
% title('Square Image')