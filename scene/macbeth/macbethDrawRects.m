function obj = macbethDrawRects(obj,onoff)
% Draw the MCC rectangles given the cornerPoints in the structure
%
%   obj = macbethDrawRects(obj,[onoff])
%
% Outline the center of each MCC patch used for analysis. This routine
% works for vcimages (ip) and sensors.  It might work for simple Matlab
% figures, too.
%
% obj:    An ip or sensor structure.  The object should contain a the mcc
%         corner points.
% on/off:  
%    on:   Create the mcc rects, display and store them, refresh window
%    off:  Delete any existing mcc rects in the object, refresh window
%
% Example:
%
% Copyright ImagEval Consultants, LLC, 2011.

if ieNotDefined('obj'), error('Structure required'); end
if ieNotDefined('onoff'), onoff = 'on'; end  % Default is on

switch onoff
    case 'on'
        switch vcEquivalentObjtype(obj.type)
            case 'VCIMAGE'
                if ~isequal(vcGetObject('vcimage'),obj)
                    % Put this object in place
                end
                cornerPoints = ipGet(obj,'mcc corner points');
                a = get(ipWindow,'CurrentAxes');
            case 'ISA'
                % Make sure the current object matches this object
                if ~isequal(vcGetObject('sensor'),obj)
                    % Put this object in place
                end
                % Always show the data scaled
                cornerPoints = sensorGet(obj,'mcc corner points');
                a = get(sensorImageWindow,'CurrentAxes');
                g = ieSessionGet('sensor guidata'); set(g.btnDisplayScale,'Value',1);
            otherwise
                error('Unknown object type %s',obj.type);
        end
        
        % Can't draw them if there are no corner points.  We could call
        % chartCornerpoints here.  But for now, we throw an error.
        if isempty(cornerPoints), error('No mcc corner points'); end
        
        % From the corner points, get the macbeth patch center locations.
        [mLocs, delta] = macbethRectangles(cornerPoints);
        
        % Plot the rectangles
        rectHandles = zeros(24,1);
        for ii=1:24
            % Get the locations around the center
            theseLocs = macbethROIs(mLocs(:,ii),delta);
            % Find the convex hull of the locations (a rect)
            corners = convhull(theseLocs(:,1),theseLocs(:,2));
            % Plot the convex hull
            hold(a,'on');
            rectHandles(ii) = plot(a,theseLocs(corners,2),theseLocs(corners,1),...
                'Color',[1 1 1], 'LineWidth',2);
        end
        
        % Store rectHandles
        % A refresh will delete them also, apparently.
        switch lower(obj.type)
            case 'vcimage'
                obj = ipSet(obj,'mccRectHandles',rectHandles);
            case {'isa','sensor'}
                obj = sensorSet(obj,'mccRectHandles',rectHandles);
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
        end
        
    otherwise
        error('Unknown on/off %s\n',onoff);
end

return
