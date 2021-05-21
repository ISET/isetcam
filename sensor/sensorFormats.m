function sFormat = sensorFormats(formatName)
% Row/col size and sensor imaging area sizes of various formats
%
%        sFormat = sensorFormats([formatName])
%
%  The row/col formats specified are qcif, cif, qvga, vga, svga, xvga
%  uxvga.
%
%  The imaging area dimensions for standard sensor sizes are
%  returned in meters. Oddly the sizes are given in inches (e.g.,
%  halfinch, quarterinch and sixteenthinch) are also stored.
%
% Row/col sizes for all known sensor formats are returned using:
%
%  sFormat = sensorFormats;
%
% Examples:
%
%  sFormat = sensorFormats('qcif');
%  sFormat = sensorFormats('quarterinch');
%  sFormat = sensorFormats;   % All
%
% Copyright ImagEval Consultants, LLC, 2005

% TODO - We should put a units argument into the calling function
%

% These images could go either way because the sensor can be rotated.
% We put them in as smaller number of rows, larger number of columns.
t.qqcif = [72, 88];
t.qcif  = [144, 176];
t.qqvga = [120, 160];
t.qvga  = [240, 320];
t.cif   = [288, 352];
t.vga   = [480, 640];
t.svga  = [600,800];
t.xvga  = [768, 1024];
t.uvga  = [1024,1280];
t.uxvga = [1200,1600];   % Not sure about this one.

% Here are some more we could add
% HD1080 =[1920, 1080];
% HD720 = [1280  720];
% LCD  =  [1024  780];
% WVGA =  [800,  480];
% WUXGA = [1920 1200];
% WXGA1 = [1280  768];
% WXGA2 = [1280  800];
% WSXGAP= [1680,1050];
% WSVGA = [1020, 600];
% XGA   = [1024  768];
% UXGA  = [1600,1200];
% QXGA  = [2048,1536];
% SXGAP = [1400,1050];
% SXGA  = [1280,1024];
% SVGA  = [800,  600];
% VGA   = [640,  480];
% CGA   = [320,  200];
% QVGA  = [320,  240];
%
% MPEG1   = [352 240];
% iPhone  = [480 320];  % iPhone
% YouTube = [560 340];  % YouTube
% PAL     = [768 576];
% NTSC    = [720 480];

% Size (of what?) formats for sensors.  What units?  Looks like meters.
% Note: 25.4 mm/inch
% Aptina quoted an imaging area of 2.278  x 3.6 mm for quarter-inch.
t.halfinch      = [0.0048, 0.0064]; % 4.8 x 6.4 mm
t.quarterinch   = [0.0024, 0.0032]; % 2.4 x 3.2 mm
t.sixteenthinch = [0.0012, 0.0016]; % 1.2 x 1.6 mm

if ~exist('formatName','var') || isempty(formatName)
    sFormat = t;
    return;
end

switch ieParamFormat(formatName)
    case 'qqcif'
        sFormat = t.qqcif;
        
    case 'qcif'
        sFormat = t.qcif;
        
    case 'cif'
        sFormat = t.cif;
        
    case 'qqvga',
        sFormat = t.qqvga;
        
    case 'qvga',
        sFormat = t.qvga;
        
    case 'vga',
        sFormat = t.vga;
        
    case 'svga',
        sFormat = t.svga;
        
    case 'xvga'
        sFormat = t.xvga;
        
    case 'uvga'
        sFormat = t.uvga;
        
    case 'uxvga'
        % Not sure about this one.
        sFormat = t.uxvga;
        
        %%%%%%%%%%%%%%%%%Size parameters%%%%%%%%%%%%%%%%%
        % Size units are meters
        
    case {'halfinch','half'}
        sFormat = t.halfinch;
        
    case {'quarterinch','quarter'}
        % Standard quarter inch format is used in mobile phones.
        sFormat = t.quarterinch;
        
    case {'sixteenthinch','sixteenth'}
        sFormat = t.sixteenthinch;
        
    otherwise
        disp('Unknown format.  Returning the CIF/VGA list.  Or do you want halfinch or quarterinch?')
        sFormat = t;
end


return;
