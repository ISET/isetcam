function [roiLocs,rect] = vcROISelect(obj,app)
% Deprecated:  Use ieROISelect.
%
% Select a region of interest (ROI) from an image and calculate locations  
%
%   [roiLocs,rect] = vcROISelect(obj,[objFig])
%
%  The row and col locations of the region of interest (ROI) are returned
%  in the Nx2 matrix, roiLocs.
%
%  If requested, the selected rectangle (rect) determining the region of
%  interest, [colmin,rowmin,width,height], is also returned.  
%
% Example:
%  vci             = vcGetObject('VCIMAGE');
%  [roiLocs, rect] = vcROISelect(vci);
%  iData   = vcGetROIData(vci,roiLocs,'results');
%
% See also: ieRect2Locs
%
% Copyright ImagEval Consultants, LLC, 2005.

% TODO:  See proposal for ieOpenWindow below.  We should also add
% ieRoiSelect to plan for deprecation of the vcXXX routines.

warning('Please use ieROISelect');

%%
if ieNotDefined('obj'), error('You must define an object (isa,oi,scene ...)'); end
if ieNotDefined('objFig')
    [app, appAxis] = ieAppGet(obj); 
    if isempty(app)
        % We should add ieAddAndSelect()
        ieAddObject(obj);
        % Should become ieOpenWindow(obj)
        switch obj.type
            case 'scene'
                app = sceneWindow;
            case 'opticalimage'
                app = oiWindow;
            case 'sensor'
                app = sensorWindow;
            case 'vcimage'
                app = ipWindow;
            otherwise
                error('Unknown obj type %s\n',obj.type);
        end
    end
end

% Select points.  
msg = sprintf('Drag to select a region.');
ieInWindowMessage(msg,app);

% Select an ROI graphically.  Calculate the row and col locations.
% figure(objFig);
rect = round(getrect(appAxis));
ieInWindowMessage('',app);

% If the user double clicks without selecting a rectangle, we treat the
% response as a single point.  We do this by making the size 1,1.
if rect(3) == 0 && rect(4) == 0
    rect(3) = 1;
    rect(4) = 1;
end

% Transform the rectangle into ROI locations
roiLocs = ieRect2Locs(rect);

end
