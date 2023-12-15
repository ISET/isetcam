function d = displayCreate(displayName, varargin)
% Create a display structure
%
% Syntax:
%   d = displayCreate(displayFileName, [varargin])
%
% Description:
%    Display (d) calibration data are stored in a display structure.
%    These are the spectral radiance distribution of its primaries and a
%    gamma function.
%
% Inputs:
%    displayName - String. Name of a file containing a calibrated
%                  display structure. The supported display files are
%                  stored in data/displays. The files should contain a
%                  variable ('d') as display structure. See displayGet
%                  and displaySet for the slots.
%    varargin    - (Optional) User defined parameter values, should be
%                  in key-value pairs. See the optional key/value pairs
%                  section, or displaySet for supported parameters.
%
% Outputs:
%    d           - Struct. The created display structure.
%
% Optional key/value pairs:
%    **NEEDS TO BE FILLED IN**
%
% See Also:
%    sceneFromFile, displayGet, displaySet
%

% History:
%    xx/xx/15  HJ   ISETBIO TEAM, 2015
%    05/14/18  jnm  Formatting

% Examples:
%{
    d = displayCreate;
    d1 = displayCreate('lcdExample');
    wave = 400:5:700;
    d2 = displayCreate('lcdExample', 'wave', wave);

    % Some displays have psf data, as well, e.g.
    d3 = displayCreate('LCD-Apple');
%}

%% Init Parameters
% Default changed on Nov. 30, 2015. The original default was far too
% bright for common practice.
if notDefined('displayName'), displayName = 'LCD-Apple'; end

% Identify the object type
d.type = 'display';

% This will change the filename to lower case which can cause problems.
% displayName = ieParamFormat(displayName);

d = displaySet(d, 'name', displayName);

% We can create some displays, or if it is not on the list perhaps it is
% a file name that we load.
switch displayName
    case 'default'
        % See comment about the default above. We should make it a
        % little closer to sRGB standard chromaticities.
        d = displayDefault(d);
        
    case {'equalenergy','equal energy'}
        % Make the primaries all the same and equal energy
        d = displayDefault(d);
        spd = ones(size(d.spd))*1e-3;
        d = displaySet(d,'spd',spd);
        
    otherwise
        % Read a file with calibrated display data.
        % This can include pixel psf data for some displays.
        if exist(displayName, 'file') || ...
                exist([displayName, '.mat'], 'file')
            tmp = load(displayName);
            if ~isfield(tmp, 'd')
                error('No display struct in the file');
            else
                d = tmp.d;
            end
        else
            error('Unknown display %s.', displayName);
        end

end

if length(varargin) == 1
    warning('ISETBIO: Should set wave as name-value pairs');
    d = displaySet(d, 'wave', varargin{1});
else
    assert(~isodd(length(varargin)), 'varargin should in pairs');
    for ii = 1:2:length(varargin)
        d = displaySet(d, varargin{ii}, varargin{ii + 1});
    end
end

% Set the default scene rgb for ISETBIO, using main display image window
d.mainimage = sceneGet(sceneCreate, 'rgb image');

end % end displayCreate

% Create a default display structure
function d = displayDefault(d)
% Create default display.
%
% Syntax:
%   d = displayDefault(d)
%
% Description:
%    Create a default display that works well with the imageSPD
%    rendering routine. See vcReadImage for more notes. Or move those
%    notes here.
%
% Inputs:
%    d - Struct. A display Structure.
%
% Outputs:
%    d - Struct. The modified display Structure.
%
% Optional key/value pairs:
%    None.
%

wave = 400:10:700;
% Make peak about 100 cd/m2
spd = pinv(colorBlockMatrix(length(wave))) / 700;
d = displaySet(d, 'wave', wave);
d = displaySet(d, 'spd', spd);

% Linear gamma function
N = 256; % 8 bit display
g = repmat(linspace(0, 1, N), 3, 1)';
d = displaySet(d, 'gamma', g);  % From digital value to linear intensity

% Spatial matters
d.dpi = 96;    % Typical display density
d.dist = 0.5;  % Typical viewing distance, 19 inches

end % end displayDefault