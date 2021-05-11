function ieManualViewer(mType)
%View ISET manual information.
%
%   ieManualViewer(mType)
%
% Open a browser into the m2html web-site to show the functions and the
% source code.  This is not as good an overview as going to the ISETCam
% gitHub directory itself, but ...
%
% Examples:
%   ieManualViewer('github');
%
% Copyright ImagEval Consultants, LLC, 2006.

%{
ieManualViewer;
%}
%{
ieManualViewer('github');
%}
%{
ieManualViewer('iset functions');
%}
%{
ieManualViewer('scene functions');
%}

%%  Defaults
if ieNotDefined('mType')
    % Take them to the ISETCam wiki
    web('https://github.com/iset/isetcam/wiki', '-browser');
    return;
end

%% Options

mType = ieParamFormat(mType);
switch mType
    case {'isetfunctions'}
        % m2html overview for old-timers
        web('https://scarlet.stanford.edu/~brian/isetcam/manuals/index.html', '-browser');
    case {'github'}
        % Main
        web('https://github.com/ISET/isetcam', '-browser')
        % Separate directories
    case {'scenefunctions'}
        web('https://github.com/ISET/isetcam/tree/master/scene', '-browser');
    case {'oifunctions'}
        web('https://github.com/ISET/isetcam/tree/master/opticalimage', '-browser');
    case {'opticsfunctions'}
        web('https://github.com/ISET/isetcam/tree/master/opticalimage/optics', '-browser');
    case {'sensorfunctions'}
        web('https://github.com/ISET/isetcam/tree/master/sensor', '-browser');
    case {'pixelfunctions'}
        web('https://github.com/ISET/isetcam/tree/master/sensor/pixel', '-browser');
    case {'ipfunctions'}
        web('https://github.com/ISET/isetcam/tree/master/imgproc', '-browser');
    case {'metricsfunctions'}
        web('https://github.com/ISET/isetcam/tree/master/metrics', '-browser');
    case {'displayfunctions'}
        web('https://github.com/ISET/isetcam/tree/master/displays', '-browser');
    otherwise
        web('https://github.com/iset/isetcam/wiki', '-browser');
end
end
