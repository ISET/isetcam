function url = ieManualViewer(mType,varargin)
%View ISET manual information.
%
%   ieManualViewer(mType)
%   url = ieManualViewer(mType,'open',false)
%
% Optional key/value:
%   open - Open the browser (default true). False only returns the URL.
% Returns:
%   url - Documentation URL for the requested manual type.
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
ieManualViewer('iset tutorials');
%}
%{
ieManualViewer('scene functions');
%}

%% Defaults and browser control
if ieNotDefined('mType'), mType = 'isetcam wiki'; end
p = inputParser;
p.addParameter('open',true,@(x) islogical(x) && isscalar(x));
p.parse(varargin{:});

%% Options

mType = ieParamFormat(mType);
switch mType
    case {'isetcamwiki'}
        url = 'https://github.com/iset/isetcam/wiki';
    case {'isetfunctions','isettutorials'}
        % m2html overview for old-timers
        url = 'https://github.com/ISET/isetcam/wiki/Tutorials-and-scripts';
    case {'github'}
        % Main
        url = 'https://github.com/ISET/isetcam';
        % Separate directories
    case {'scenefunctions'}
        url = 'https://github.com/ISET/isetcam/tree/master/scene';
    case {'oifunctions'}
        url = 'https://github.com/ISET/isetcam/tree/master/opticalimage';
    case {'opticsfunctions'}
        url = 'https://github.com/ISET/isetcam/tree/master/opticalimage/optics';
    case {'sensorfunctions'}
        url = 'https://github.com/ISET/isetcam/tree/master/sensor';
    case {'pixelfunctions'}
        url = 'https://github.com/ISET/isetcam/tree/master/sensor/pixel';
    case {'ipfunctions'}
        url = 'https://github.com/ISET/isetcam/tree/master/imgproc';
    case {'metricsfunctions'}
        url = 'https://github.com/ISET/isetcam/tree/master/metrics';
    case {'displayfunctions'}
        url = 'https://github.com/ISET/isetcam/tree/master/displays';
    otherwise
        url = 'https://github.com/iset/isetcam/wiki';
end
if p.Results.open, web(url,'-browser'); end

end
