function d = displayCreate(displayName,varargin)
% Create a display structure.
%
%  d = displayCreate(displayFileName,[wave])
%
% Display (d) calibration data are stored in a display structure. These are
% the spectral radiance distribution of its primaries and a gamma function.
%
% displayName: Name of a file containing a calibrated display structure.
%   There are various examples in data/displays.  They contain a variable
%   ('d') that is a display structure.  See displayGet and displaySet for
%   the slots.
% 
% See Also:  sceneFromFile (RGB read in particular)
%
% Example:
%   d = displayCreate;
%   d = displayCreate('lcdExample');
%   wave = 400:5:700; d = displayCreate('lcdExample',wave);
%
%  Some displays have psf data, as well.  For example:
%
%   d = displayCreate('LCD-Apple');
%  
% Copyright ImagEval Consultants, LLC, 2011.


%% sRGB definitions in terms of xy
%
%     Red     Green   Blue   White
% x	0.6400	0.3000	0.1500	0.3127
% y	0.3300	0.6000	0.0600	0.3290
%
% The default is a set of block primaries.  They are close to this.  We
% should make one that is perfect. The default is shown below, and the
% white point xy is a little too much x.  The file lcdExample.mat is a
% little closer.
%
% d = displayCreate;
% displayGet(d,'primaries xy')'
% displayGet(d,'white xy')'
%


%% Arguments
if ieNotDefined('displayName'), displayName = 'default'; end

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
        % See comment about the default above.  We should make it a little
        % closer to sRGB standard chromaticities.
        d = displayDefault(d);
 
    case 'equalenergy'
        % Make the primaries all the same and equal energy
        d = displayDefault(d);
        spd = ones(size(d.spd))*1e-3;
        d = displaySet(d,'spd',spd);
    otherwise
        % Read a file with calibrated display data.
        % This can include pixel psf data for some displays.
        if exist(displayName,'file') || exist([displayName,'.mat'],'file') 
            tmp = load(displayName);
            if ~isfield(tmp,'d')
                error('No display struct in the file');
            else  d = tmp.d;
            end
        else error('Unknown display %s.',displayName);
        end

end

% Handle user-specified parameter values
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
