function macbethDrawRects(obj, onoff)
% Draw Macbeth CC rectangles from the stored cornerPoints
%
% Syntax:
%   macbethDrawRects(obj,[onoff])
%
% Description:
%  Draw rectangles in each MCC patch as defined by the corner points of the
%  object.
%
% Inputs:
%   obj:    A scene, oi, sensor or ip scene structure.  The structure
%           should contain the corner points.
%
%   onoff:
%    on:   Create the rects and display them
%    off:  Refresh window, which eliminates the displayed rectangles
%
% Outputs:
%    N/A
%
% Copyright ImagEval Consultants, LLC, 2011.
%
% See also:
%   macbethSelect, chart<TAB>
%

%%
if ieNotDefined('obj'), error('Structure required'); end
if ieNotDefined('onoff'), onoff = 'on'; end % Default is on

%% Turn the rectangles on or off

switch onoff
    case 'on'
        switch vcEquivalentObjtype(obj.type)
            case 'VCIMAGE'
                cornerPoints = ipGet(obj, 'chart corner points');
                ipWindow;
            case 'ISA'
                % Always show the data scaled
                cornerPoints = sensorGet(obj, 'chart corner points');
                sensorWindow;
            case 'SCENE'
                cornerPoints = sceneGet(obj, 'chart corner points');
                sceneWindow;
            otherwise
                error('Unknown object type %s', obj.type);
        end

        if isempty(cornerPoints), error('No chart corner points'); end

        % From the corner points, calculate the macbeth patch center locations.
        rects = chartRectangles(cornerPoints, 4, 6, 0.5);
        chartRectsDraw(obj, rects);

    case 'off'
        % This is just a refresh.
        switch lower(obj.type)
            case 'vcimage'
                ipWindow;

            case {'isa', 'sensor'}
                sensorWindow;

            case {'scene'}
                sceneWindow;
        end

    otherwise
        error('Unknown on/off %s\n', onoff);
end

end
