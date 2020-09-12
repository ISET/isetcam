function obj = macbethDrawRects(obj,onoff)
% Draw the MCC rectangles given the cornerPoints in the structure
%
% Syntax:
%   obj = macbethDrawRects(obj,[onoff])
%
% Description:
%  Draw rectangles in each MCC patch as defined by the corner points of the
%  scene object.
%
% Inputs:
%   obj:    An ip, sensor or scene structure.  The object should contain a
%           the mcc corner points.
%   onoff:  
%    on:   Create the mcc rects, display and store them, refresh window
%    off:  Delete any existing mcc rects in the object, refresh window
%
% Outputs:
%    obj:   The rectangle handles (mccRectHandles) are attached to the
%           returned object 
%
% Copyright ImagEval Consultants, LLC, 2011.
%
% See also:
%   macbethROIs, macbethDrawRect, macbethSelect, macbethRectangles, chartROI
%   chart<TAB>
%

%%
if ieNotDefined('obj'), error('Structure required'); end
if ieNotDefined('onoff'), onoff = 'on'; end  % Default is on

%%


switch onoff
    case 'on'
        switch vcEquivalentObjtype(obj.type)
            case 'VCIMAGE'
                cornerPoints = ipGet(obj,'chart corner points');
                ipWindow;
            case 'ISA'
                % Always show the data scaled
                cornerPoints = sensorGet(obj,'chart corner points');
                sensorWindow;
            case 'SCENE'
                cornerPoints = sceneGet(obj,'chart corner points');
                sceneWindow;
            otherwise
                error('Unknown object type %s',obj.type);
        end
        
        if isempty(cornerPoints), error('No chart corner points'); end

        % From the corner points, calculate the macbeth patch center locations.
        rects = chartRectangles(cornerPoints,4,6,0.5);
        chartRectsDraw(obj,rects);
        
    case 'off'
        % Delete handles from current axis and update the object
        switch lower(obj.type)
            case 'vcimage'
                rects = ipGet(obj,'chart rects');
                delete(rects);
                obj = ipSet(obj,'mccRectHandles',[]);
                vcReplaceObject(obj);
                ipWindow;

            case {'isa','sensor'}
                rects = sensorGet(obj,'chart rects');
                delete(rects);
                obj = sensorSet(obj,'mccRectHandles',[]);
                vcReplaceObject(obj);
                sensorWindow;
                
            case {'scene'}
                rects = sceneGet(obj,'chart rects');
                if ~isempty(rects), delete(rects); end
                obj = sceneSet(obj,'mccRectHandles',[]);
                vcReplaceObject(obj);
                sceneWindow;
        end
        
    otherwise
        error('Unknown on/off %s\n',onoff);
end

end
