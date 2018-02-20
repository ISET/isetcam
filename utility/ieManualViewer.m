function ieManualViewer(mType)
%View ISET manual information located at ImageVal.com
%
%   ieManualViewer(mType)
%
% Open a browser into the ImagEval web-site to show different parts of the
% user manual.
%
% Examples:
%   ieManualViewer
%   ieManualViewer('imageval')
%   ieManualViewer('imageval code');
%   ieManualViewer('application notes') - NYI
%
%   ieManualViewer('iset functions')
%
%   ieManualViewer('scene functions')
%
%   ieManualViewer('oi functions')
%   ieManualViewer('optics functions')
%
%   ieManualViewer('sensor functions')
%   ieManualViewer('pixel functions')
%
%   ieManualViewer('ip functions')
%   ieManualViewer('metrics functions')
%
% Copyright ImagEval Consultants, LLC, 2006.

% TODO:  Should we have a more graceful response if the user is offline?

% Defaults
if ieNotDefined('mType')
    web('http://imageval.com/documentation/','-browser');
    return;
else
    mType = ieParamFormat(mType);
    switch mType
        case {'functions','isetfunctions'}
            web('http://imageval.com/Functions/iset-manual/iset/index.html','-browser');
        case {'home','imageval'}
            web('http://www.imageval.com','-browser');
        case {'imagevalcode'}
            web('http://www.imageval.com/code/','-browser');
        case {'scenefunctions'}
            web('http://imageval.com/Functions/iset-manual/iset/scene/index.html','-browser');
        case {'oifunctions'}
            web('http://imageval.com/Functions/iset-manual/iset/opticalimage/index.html','-browser');
        case {'opticsfunctions'}
            web('http://www.imageval.com/Functions/iset-manual/iset/opticalimage/optics/index.html','-browser');
        case {'sensorfunctions'}
            web('http://imageval.com/Functions/iset-manual/iset/sensor/index.html','-browser');
        case {'pixelfunctions'}
            web('http://imageval.com/Functions/iset-manual/iset/sensor/pixel/index.html','-browser');
        case {'ipfunctions'}
            web('http://imageval.com/Functions/iset-manual/iset/imgproc/index.html','-browser');
        case {'metricsfunctions'}
            web('http://imageval.com/Functions/iset-manual/iset/metrics/index.html','-browser');
        case {'applicationnotes'}
            error('Not yet implemented')
            web('http://imageval.com/application-notes/','-browser');
        otherwise
            web('http://imageval.com/code','-browser');
    end
end

return



