function [roiLocs,roi] = ieROISelect(obj,varargin)
% Select a rectangular region of interest (ROI)
%
% Syntax
%   [roiLocs,roi] = ieROISelect(obj,varargin)
%
% Description
%  The row and col locations of the region of interest (ROI) are returned
%  in the Nx2 matrix, roiLocs.
%
%  If requested, the selected rectangle (rect) is also returned.   The rect
%  corner positions are part of the roi.
%
% Input
%   obj - An ISETCam structure (scene, oi, sensor, ip)
%
% Optional key/val pairs
%
% Return
%   roiLocs:  The list of Nx2 (row,col) locations.
%   roi:      A Matlab Rectangle object where roi.Position is the rect
%
% We skip the Examples here because they all involve user interaction.  Run
% them by hand to test.
%
% See also:
%   ieRoiDraw, ieRect2Locs, ieRoiCreate

% Examples:
%{
 % ETTBSkip
 scene = sceneCreate; sceneWindow(scene);
 [~,rect] = ieROISelect(scene);
 r = ieROIDraw('scene','shape','rect','shape data',rect);
 delete(r);
%}
%{
 % ETTBSkip
 ip = ieGetObject('ip');
 [roiLocs, rect] = ieROISelect(ip);
 r = ieROIDraw('ip','shape','rect','shape data',rect);
%}
%{
 % ETTBSkip
 ip = ieGetObject('ip');
 ip = ipSet(ip,'roi',rect);
 ipPlot(ip,'roi');
%}

%%
if ieNotDefined('obj'), error('ISETCam object required (isa,oi,scene ...)'); end

% Get the associated window;
[app, appAxis] = ieAppGet(obj);
if isempty(app) || ~isvalid(app)
    error('No window availble');
end

%% Select points.

% Tell the user
% Select an ROI graphically. This should become a switch statement for the
% shape, ultimately.
ieInWindowMessage('Select a rectangle.',app)
roi  = drawrectangle(appAxis);
ieInWindowMessage('',app)

rect = round(roi.Position);

% If the user double clicks without selecting a rectangle, we treat the
% response as a single point.  We do this by making the size 1,1.
if rect(3) == 0 && rect(4) == 0
    rect(3) = 1;
    rect(4) = 1;
end

% Transform the rectangle into ROI locations
roiLocs = ieRect2Locs(rect);

end
