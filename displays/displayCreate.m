function d = displayCreate(displayName,varargin)
% Create a display structure.
%
% Synopsis
%  d = displayCreate(displayFileName,[wave])
%
% Brief description
%  Display (d) calibration data are stored in a display structure. These
%  are the spectral radiance distribution of its primaries and a gamma
%  function.
%
% Inputs:
%  displayName: Name of a file containing a calibrated display structure.
%
%               If no display is specified, the default is a special
%               display we created called 'reflectance-display'.  This
%               display converts the RGB values in the image as if they
%               were to be shown on an sRGB display. We figured out how to
%               set the SPD of the primaries such that if we assume a D65
%               illuminant and those primaries, the estimate surface
%               reflectances are within the first three linear basis
%               functions of natural surfaces.
%
%               To see how we did that, read s_displaySurfaceReflectance.
%
% Optional key/value pairs:
%   Settable display parameters as pairs.  Anything that works in
%   displaySet will work here
%
% Description
%   There are various calibrated displays in data/displays.  They contain a
%   variable ('d') that is a display structure.  See displayGet and
%   displaySet for the slots.
%
%   The 'reflectance-display' is designed to work well with sceneFromFile,
%   producing a scene whose reflectances are within the 3D basis functions
%   of natural surfaces and a D65 illuminant.
%
% sRGB definitions in terms of xy
%
%        Red     Green   Blue   White
%  x	0.6400	0.3000	0.1500	0.3127
%  y	0.3300	0.6000	0.0600	0.3290
%
%
%  Some displays have psf data, as well.  For example:
%
%   d = displayCreate('LCD-Apple');
%
% Copyright ImagEval Consultants, LLC, 2011.
%
% See Also:
%   sceneFromFile (RGB read in particular)
%

% Examples:
%{
  d = displayCreate;
  displayPlot(d,'spd');
  displayGet(d,'primaries xy')'
  displayGet(d,'white xy')'
%}
%{
   d = displayCreate;     % The default is 'reflectance-display'
   d = displayCreate('lcdExample');
   wave = 400:5:700; d = displayCreate('lcdExample',wave);
%}

%% Arguments

if ~exist('displayName','var') || isempty(displayName)
    displayName = 'reflectance-display'; 
end

% Identify the object type
d.type = 'display';

% This will change the filename to lower case which can cause problems.
% displayName = ieParamFormat(displayName);

d = displaySet(d,'name',displayName);

% We can create some displays, or if it is not on the list perhaps it is a
% file name that we load.  For the switch part, we close the spaces and
% force lower case.  But we retain displayName in case we need to load a
% file with that name.
sParam = ieParamFormat(displayName);
switch sParam
    case 'default'
        % This is the old default display with block matrix primaries.  The
        % modern default display is the 'reflectance-display'
        d = displayDefault(d);
        
    case 'equalenergy'
        % Make the primaries all the same and equal energy.  Thus, a
        % monochrome display.
        d = displayDefault(d);
        spd = ones(size(d.spd))*1e-3;
        d = displaySet(d,'spd',spd);
    otherwise
        % Read a file with calibrated display data.
        % This can include pixel psf data for some displays.
        if exist(displayName,'file') || exist([displayName,'.mat'],'file')
            tmp = load(displayName);
            if ~isfield(tmp,'d')
                % It might be a spectra/basis function file (ZLY, 2022)
                if isfield(tmp, 'wavelength') && isfield(tmp, 'data')
                    [primeSPD, wave] = ieReadSpectra(displayName, [], [], true);
                    d = displayCreate('default');
                    d = displaySet(d, 'wave', wave);
                    d = displaySet(d, 'spd', primeSPD);
                    % Use Apple display
                    dApple = displayCreate('LCD-Apple');
                    g = displayGet(dApple,'gamma');
                    d = displaySet(d,'gamma',g);
                else
                    error('No display struct in the file');
                end
            else
                d = tmp.d;
                d = displaySet(d,'name',displayName);
            end
            if isempty(displayGet(d,'dixel'))
                % Some displays do not have a spatial dixel.  For example,
                % the reflectance-display is entirely imaginary.  So, we
                % assign a dixel here from an existing display that was
                % calibrated.
                fprintf('Assigning the spatial dixel from LCD-Apple to the %s.\n', displayGet(d,'name'));
                tmp = load('LCD-Apple');
                d.dixel = tmp.d.dixel;
            end
        else
            error('Unknown display %s.',displayName);
        end
end

% Start out without an image.  Until we know what we should use.
d = displaySet(d,'image',[]);

%% Handle user-specified parameter values

% Now we only support user setting value of wavelength
if length(varargin) >= 1
    newWave = varargin{1};
    oldWave = displayGet(d,'wave');
    oldSpd = displayGet(d,'spd');
    newSpd = interp1(oldWave(:),oldSpd,newWave(:));
    % plot(newWave,newSpd,'k-',oldWave,oldSpd,'y-')
    d = displaySet(d,'wave',newWave);
    d = displaySet(d,'spd',newSpd);
end

end

%% Create a default display structure

function d = displayDefault(d)
% Create a default display that works well with the imageSPD rendering
% routine.  See vcReadImage for more notes.  Or move those notes here.

% I now think we should use one of the calibrated displays as the default.
% But I am reluctant to change for compatibility reasons (BW).

wave = 400:10:700;
spd = pinv(colorBlockMatrix(length(wave)))/700;  % Makes 100 cd/m2 peak
d = displaySet(d,'wave',wave);
d = displaySet(d,'spd',spd);

% Linear gamma function
N = 256; % 8 bit display
g = repmat((0:(N-1))'/N,1,3);
d = displaySet(d,'gamma',g);  % From digital value to linear intensity

% Spatial matters
d.dpi = 96;    % Typical display density?  This might be a little low
d.dist = 0.5;  % Typical viewing distance, 19 inches

end
