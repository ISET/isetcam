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
[app, appAxis] = vcGetFigure(obj);

switch onoff
    case 'on'
        switch vcEquivalentObjtype(obj.type)
            case 'VCIMAGE'
                cornerPoints = ipGet(obj,'mcc corner points');
            case 'ISA'
                % Always show the data scaled
                cornerPoints = sensorGet(obj,'mcc corner points');
            case 'SCENE'
                cornerPoints = sceneGet(obj,'mcc corner points');
            otherwise
                error('Unknown object type %s',obj.type);
        end
        
        % Can't draw them if there are no corner points.  We could call
        % chartCornerpoints here.  But for now, we throw an error.
        if isempty(cornerPoints), error('No mcc corner points'); end
        
        % From the corner points, calculate the macbeth patch center locations.
        [mLocs, delta] = macbethRectangles(cornerPoints);
        
        % Plot the rectangles
        rectHandles = zeros(24,1);
        for ii=1:24
            % Get the locations around the center
            theseLocs = macbethROIs(mLocs(:,ii),delta);
            
            % Find the convex hull of the locations (a rect). The rect
            % should be returned by macbethROIs, by the way. Not sure why
            % it isn't.  I did that for chartROIs, I think.
            [~,rect] = chartROI(mLocs(:,ii),delta);
            % corners = convhull(theseLocs(:,1),theseLocs(:,2));
            
            % Plot the rects
            rectHandles(ii) = drawrectangle(appAxis, 'DrawingArea',rect,'Color',[1 1 1]);
            % theseLocs(corners,2),theseLocs(corners,1),...
            %     'Color',[1 1 1], 'LineWidth',2);
            % rectHandles(ii) = plot(a,theseLocs(corners,2),theseLocs(corners,1),...
            %     'Color',[1 1 1], 'LineWidth',2);
        end
        
        % Store rectHandles
        switch lower(obj.type)
            case 'vcimage'
                obj = ipSet(obj,'mccRectHandles',rectHandles);
            case {'isa','sensor'}
                obj = sensorSet(obj,'mccRectHandles',rectHandles);
            case 'scene'
                obj = sceneSet(obj,'mccRectHandles',rectHandles);
        end
        vcReplaceObject(obj);
    
    case 'off'
        % Delete handles from current axis and update the object
        switch lower(obj.type)
            case 'vcimage'
                rects = ipGet(obj,'mcc Rect Handles');
                delete(rects);
                obj = ipSet(obj,'mccRectHandles',[]);
                vcReplaceObject(obj);
                ipWindow;

            case {'isa','sensor'}
                rects = sensorGet(obj,'mcc Rect Handles');
                delete(rects);
                obj = sensorSet(obj,'mccRectHandles',[]);
                vcReplaceObject(obj);
                sensorImageWindow;
                
            case {'scene'}
                rects = sceneGet(obj,'mcc Rect Handles');
                if ~isempty(rects), delete(rects); end
                obj = sceneSet(obj,'mccRectHandles',[]);
                vcReplaceObject(obj);
                sceneWindow;
        end
        
    otherwise
        error('Unknown on/off %s\n',onoff);
end

end
