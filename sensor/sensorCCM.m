function [L,pointLoc] = sensorCCM(sensor,ccmMethod,pointLoc,showSelection)
%Compute a 3x3 color transform from sensor to linear display
%
%   [L, pointLoc] = sensorCCM(sensor, ccmMethod, pointLoc, showSelection)
%
% At present, only the Macbeth method is implemented.  We plan to write
% various ways of defining a color conversion matrix (CCM) from sensor data
% to display data.
%
% ccmMethod = 'macbeth'
%  In this method we acquire a sensor image of the Macbeth CC.  The user
%  selects the positions of the MCC (lower left = white, lower right =
%  black, upper right, upper left).  The algorithm extracts the data and
%  finds the 3x3 that maps the sensor values into an ideal MCC under d65
%  illuminant (linear srgb).
% 
% L: The linear transformation
% pointLoc: The macbeth method - and perhaps others - may need informaton
%   about the locations of particular targets in the sensor data.
%   Normally, this information is obtained by a user selection,
%   and the spatial information is returned in pointLoc.  If you
%   already know the pointLoc values, you can send them in as an
%   argument and skip the interactive part.
%
% If there is no return argument, evaluation graphs are displayed.
%
% See also: s_macbethDeltaE, macbethEvaluationGraphs
%
% Examples:
%   User selects corners; the routine makes graphs and prints the linear
%   transform L into work space 
%     sensorCCM;        
%
%  Returns L, no graphs are displayed
%     L = sensorCCM;
%
%  L and point locations
%    [L, pointLoc] = sensorCCM(vcGetObject('sensor'),'macbeth');
%
%  If pointLoc is returned from above, put it back in and show the
%  selection
%    [L, pointLoc] = sensorCCM(sensor,'macbeth',pointLoc,1)
%
% Copyright ImagEval Consultants, LLC, 2003.

%% Arguments
if ieNotDefined('sensor'),         sensor = vcGetObject('sensor'); end
if ieNotDefined('ccmMethod'),      ccmMethod = 'macbeth'; end
if ieNotDefined('pointLoc'),       pointLoc = []; end
if ieNotDefined('showSelection'),  showSelection = true; end
if ieNotDefined('showEvaluation'), showEvaluation = true; end

ccmMethod = ieParamFormat(ccmMethod);
switch lower(ccmMethod)
    case 'macbeth'
        cp = sensorGet(sensor,'chart corner points');
        if isempty(cp)
            cp = chartCornerpoints(sensor,false);  % Get the corner points
        end
        [rects,mLocs,pSize] = chartRectangles(cp,4,6,0.5);  % MCC parameters
        fullData = false;
        dataType = 'volts';
        delta = round(pSize(1)*0.5);
        
        % rgb are the 24x3 values (average) from the sensor at the macbeth positions.
        rgb = chartRectsData(sensor,mLocs,delta,fullData,dataType);
        
        % The desired rgb values
        idealRGB          = macbethIdealColor('d65','lrgb');
        
        % We want: idealRGB = rgb*L
        % So we calculate L = pinv(rgb)*idealRGB
        L = pinv(rgb)*idealRGB;
        
        if showEvaluation
            % We display error graphs if nothing is requested for return.
            sName = sprintf('SENSOR: %s',sensorGet(sensor,'name'));
            macbethEvaluationGraphs(L,rgb,idealRGB,sName);
        end
    otherwise
        error('Unknown method for determining color conversion matrix.')
end

if showSelection, chartRectsDraw(sensor,rects); end

end
