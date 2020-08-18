function [roiLocs,roi] = ieROISelect(obj,varargin)
% Select a region of interest (ROI) from an image and calculate locations  
%
% Syntax
%   [roiLocs,roi] = ieROISelect(obj,varargin)
%
% Description
%  The row and col locations of the region of interest (ROI) are returned
%  in the Nx2 matrix, roiLocs.
%
%  If requested, the selected rectangle (rect) determining the region of
%  interest, [colmin,rowmin,width,height], is also returned.  
%
% Input
%   obj - An ISETCam structure (scene, oi, sensor, ip)
%
% Optional key/val pairs
%
% Return
%   roiLocs
%   rect
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also: 
%   ieRoiDraw, ieRect2Locs, ieRoiCreate

% Examples:
%{
 scene = sceneCreate; sceneWindow(scene);
 [~,rect] = ieROISelect(scene);
 r = ieROIDraw('scene','shape','rect','shape data',rect);
 delete(r);
%}
%{
 ip = ieGetObject('ip');
 [roiLocs, rect] = ieROISelect(ip);
 r = ieROIDraw('ip','shape','rect','shape data',rect);
%}
%{
 ip = ieGetObject('ip');
 ip = ipSet(ip,'roi',rect);
 ipPlot(ip,'roi');
%}

%%
if ieNotDefined('obj'), error('You must define an object (isa,oi,scene ...)'); end
app = vcGetFigure(obj);

%% Check that the window exists!

% If the returned figure is empty, the user probably did not set up the
% object window yet.  So we add the object to the database and open the
% window
if isempty(app)
    % We should add ieAddAndSelect()
    % ieAddObject(obj);
    % Should become ieOpenWindow(obj)
    switch obj.type
        case 'scene'
            app = sceneWindow(obj);
        case 'opticalimage'
            app = oiWindow(obj);
        case 'sensor'
            app = sensorWindow(obj);
        case 'vcimage'
            app = ipWindow(obj);
        otherwise
            error('Unknown obj type %s\n',obj.type);
    end
end


%% Select points.

% Tell the user
app.txtMessage.Text = 'Drag to select a region.';

% Select an ROI graphically. This should become a switch statement for the
% shape, ultimately. 
roi  = drawrectangle(app.sceneImage);
rect = round(roi.Position);

% Clear the in window message
app.txtMessage.Text = '';

% If the user double clicks without selecting a rectangle, we treat the
% response as a single point.  We do this by making the size 1,1.
if rect(3) == 0 && rect(4) == 0
    rect(3) = 1;
    rect(4) = 1;
end

% Transform the rectangle into ROI locations
roiLocs = ieRect2Locs(rect);

end
