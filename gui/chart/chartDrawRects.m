function rectHandles = chartDrawRects(obj,mLocs,delta,onoff)
% Draw the MCC rectangles given the cornerPoints in the structure
%
% ******** Not fully implemented - particularly the 'off' part ********
% ******** Unclear how to integrate with the macbeth<> functions ******
%
% Synopsis
%   rectHandles = chartDrawRects(obj,mLocs,delta,onoff)
%
% Brief description
%  Outline the center of each patch used for analysis. This routine works
%  for vcimages (ip) and sensors.  It might work for simple Matlab figures,
%  too.
%
% Inputs:
%   obj:    An ip or sensor structure.  
%   mLocs:  The center of each chart patch
%   delta:  The size of the regin
%   on/off:  
%     on:   Create the mcc rects, display and store them, refresh window
%     off:  Delete any existing mcc rects in the object, refresh window
%
% Returns:
%   rectHandles
%
% See also
%   macbethSelect, macbethDrawRects

% Examples:
%{
%}

%%
if ieNotDefined('obj'), error('Structure required'); end
if ieNotDefined('onoff'), onoff = 'on'; end  % Default is on

%%
switch onoff
    case 'on'
        switch vcEquivalentObjtype(obj.type)
            case 'VCIMAGE'
                a = get(ipWindow,'CurrentAxes');
            case 'ISA'
                a = get(sensorImageWindow,'CurrentAxes');
            case 'SCENE' 
                a = get(sceneWindow,'CurrentAxes');
            otherwise
                error('Unknown object type %s',obj.type);
        end
                
        % Plot the rectangles
        nLocs = size(mLocs,2);
        rectHandles = zeros(nLocs,1);
        for ii=1:nLocs
            % Get the locations around the center
            theseLocs = macbethROIs(mLocs(:,ii),delta);
            
            % Find the convex hull of the locations (a rect)
            corners = convhull(theseLocs(:,1),theseLocs(:,2));
            
            % Plot the convex hull
            hold(a,'on');
            rectHandles(ii) = plot(a,theseLocs(corners,2),theseLocs(corners,1),...
                'Color',[1 1 1], 'LineWidth',2);
        end
            
    case 'off'
        % Delete handles from current axis and update the object.  Not
        % fully implemented yet!  See macbethDrawRects
        switch lower(obj.type)
            case 'vcimage'
                ipWindow;

            case {'isa','sensor'}
                sensorImageWindow;
            
            case {'scene'}
                sceneWindow;
                
            case {'opticalimage'}
                oiWindow;
                
                
        end
        
    otherwise
        error('Unknown on/off %s\n',onoff);
end

return
