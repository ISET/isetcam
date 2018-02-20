function algList = vcAlgorithms(algType)
%
%  algList = vcAlgorithms(algType)
%
%Author: ImagEval
%Purpose:
%   Cell array of the default  algorithms used in the pop-up menus.
%   This list includes the Add, Delete, and horizontal dashed line.
%
% Example:
%    algList = vcAlgorithms('demosaic');
%    algList = vcAlgorithms('balance');
%    csList  = vcAlgorithms('colorspace');
%    rList  = vcAlgorithms('render');
%    sList  = vcAlgorithms('sensorcompute');
%    algList  = vcAlgorithms('edgeAlgorithms');


if ieNotDefined('algType'), error('Algorithm class required.'); end

switch lower(algType)
    case {'demosaic','colordemosaic'}
        algList = {'Bilinear','Laplacian',...
                'Adaptive Laplacian','Nearest Neighbor',...
                'Add Custom','Delete Custom',...
                '----Custom List----'};
        
    case {'balance','colorbalance','whitebalance'}
        algList = {'None','Gray World',...
                'White World','Manual Matrix Entry',...
                'Add Custom','Delete Custom',...
                '----Custom List----'};
        
    case {'conversion','colorconversion'}
        algList = {'None','MCC Optimized',...
                'Manual Matrix Entry',...
                'Add Custom','Delete Custom',...
                '----Custom List----'};
        
    case {'colorspace'}
        % Not used yet.
        algList = {'Sensor','XYZ','Stockman',...
                'Add Custom','Delete Custom',...
                '----Custom List----'};
        
    case {'render'}
        % 
        algList = {'vcimageRender',...
                'Add Custom', 'Delete Custom', ...
                '----Custom List----'};
        
    case {'oicompute'}
        algList = {'oiCompute',...
                'Add Custom', 'Delete Custom', ...
                '----Custom List----'};
        
    case {'sensorcompute'}
        algList = {'sensorCompute',...
                'Add Custom', 'Delete Custom', ...
                '----Custom List----'};
        
    case {'edgealgorithm','edgealgorithms'}
        algList = {'edgeCompute',...
                'Add Custom', 'Delete Custom', ...
                '----Custom List----'};
    otherwise
        error('Unknown algorithm type');
end

return;