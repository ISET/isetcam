function [mRGB, mLocs, pSize, cornerPoints, mccRectHandles] = ...
    macbethSelect(obj,showSelection,fullData,cornerPoints)
%Identify Macbeth color checker RGB values and positions from window image
%
%  [mRGB mLocs, pSize, cornerPoints, mccRectHandles] =
%            macbethSelect(obj,showSelection,fullData,cornerPoints)
%
% This routine normally works within an ISET ip or sensor window. % By
% default, the obj is a vcimage (ip).  The function also works on sensor
% data, too.
%
% The user selects the four corner points on the MCC (white, black, blue,
% brown). This function estimates the (row, column) centers of the 24 MCC
% patches and the values near the center of each patch.
%
%Inputs
% obj:  sensor or ip
% showSelection (boolean): Put up the rectangles so the user sees the
%    selected rects.
% fullData:  Determines output in mRGB
% cornerPoints: Sometimes, the MCC corner point locations are stored.
%    In that case, you can send them in and the routine will skip the
%    graphical interaction.
%
%Outputs
% mRGB: The RGB values in each patch. The image processor and sensor
%       windows store linear RGB values. 
%       When fullData = 0, just the mean is returned, and mRGB is Nx3
%       RGB values.  Each row is computed as the mean RGB in a square
%       region around the center third of the Macbeth target. 
%       When fullData = 1, all of the values in the region are returned.
%       Always use fullData = 1 for sensor images and calculate the means,
%       accounting for the NaNs that are returned.
% mLocs: The locations for the mean calculation are returned in the mLocs
%        variable. This is a matrix that is Nx2, where there are N (24)
%        sample positions with a (row,col) coordinate.
% pSize:           The size of the square region in the center of the patch
% cornerPoints:    Corner points of the selected MCC
% mccRectHandles:  Graphical handles to rects shown.
%
% In ISET, the ordering of the Macbeth patches is assumed to be:
%
%   Achromatic series at the bottom, with white at the left
%   The white patch is 1 (one).
%   We count up the column, i.e., blue (2), gold (3), and brown (4).
%   Then we start at the bottom of the second column (light gray).
%   The achromatic series numbers are 1:4:24.
%   The blue, green, red patches are 2,6,10.
%
% Examples:
%  [mRGB,locs,pSize,cornerPoints] = macbethSelect;   %Defaults to vcimage
%  [mRGB,locs,pSize] = macbethSelect(vcGetObject('vcimage'));
%
% See macbethSensorValues() for this functionality.
%  sensor = vcGetObject('sensor');
%  [fullRGB,locs,pSize] = macbethSelect(sensor,0,1);
%  [fullRGB,locs,pSize] = macbethSelect(sensor);
%
%  obj = vcGetObject('vcimage'); [rgb,locs] = macbethSelect(obj);
%  dataXYZ = imageRGB2xyz(obj,rgb); whiteXYZ = dataXYZ(1,:);
%  lab = ieXYZ2LAB(dataXYZ,whiteXYZ);
%  plot3(lab(:,1),lab(:,2),lab(:,3),'o')
%
% This method is used to get the raw data of the gray series
%   mRGB = macbethSelect(obj,0,1);
%   graySeries = mRGB(1:4:24,:);
%
% See also:  macbethSensorValues, macbethRectangles, macbethROIs.  And
% there are corresponding (but slightly different) routines for arbitrary
% reflectances charts, such as chartPatchData, chartRectangles, ...
%
%  Example:
%     showSelection = 1;
%     obj = vcGetObject('vcimage');
%     [mRGB mLocs, pSize, cornerPoints]= macbethSelect(obj,showSelection);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('obj'), obj = vcGetObject('vcimage'); end
if ieNotDefined('showSelection'), showSelection = 1; mccRectHandles = []; end
if ieNotDefined('fullData'), fullData = 0; end
if ieNotDefined('cornerPoints'), queryUser = true; else, queryUser = false;end

% obj is either a vcimage or a sensor image
% In either case, we clear the mcc rect handles, put the object back, and
% then read the corner points (if they weren't sent in).
switch lower(obj.type)
    case 'vcimage'
        handles = ieSessionGet('vcimage handles');
        dataType = 'result';
        obj = ipSet(obj,'mcc Rect Handles',[]);
        vcReplaceObject(obj);
        if ieNotDefined('cornerPoints')
            cornerPoints = ipGet(obj,'mcc corner points');
        end
        
    case {'isa','sensor'} 
        handles = ieSessionGet('sensor Window Handles');
        dataType = 'dvorvolts';
        obj = sensorSet(obj,'mcc Rect Handles',[]);
        vcReplaceObject(obj);
        if ieNotDefined('cornerPoints')
            cornerPoints = sensorGet(obj,'mcc corner points');
        end
        
    otherwise
        error('Unknown object type');
end

% If the user didn't send in any corner points, and there weren't any in
% the structure, then we have the user select them in the window.
if isempty(cornerPoints)
    cornerPoints = vcPointSelect(obj,4,...
        'Select (1) lower left, (2) lower right, (3) upper right, (4) upper left');
end

%% We have corner points for sure now.  Set them and draw the Rects.
switch vcEquivalentObjtype(obj.type)
    case 'VCIMAGE'
        obj = ipSet(obj,'mcc corner points',cornerPoints);
    case 'ISA'
        obj = sensorSet(obj,'mcc corner points',cornerPoints);
end
%

%% Ask if the rects are OK. 
if queryUser,
    macbethDrawRects(obj);
    b = ieReadBoolean('Are these rects OK?');
else
    b = true;
end

if isempty(b)
    fprintf('%s: user canceled\n',mfilename);
    mRGB=[]; mLocs=[]; pSize=[]; cornerPoints=[]; mccRectHandles =[];
    return;
elseif ~b  % False, a change is desired
    switch vcEquivalentObjtype(obj.type)
        case {'VCIMAGE'}
            ipWindow;
        case {'ISA'};
            sensorWindow('scale',1);
        otherwise
            error('Unknown type %s\n',obj.type);
    end
    
    % These appear to come back as (x,y),(col,row).  The upper left of the
    % image is (1,1).
    cornerPoints = vcPointSelect(obj,4,...
        'Select (1) lower left, (2) lower right, (3) upper right, (4) upper left');
    % should be an ipSet
    obj = ipSet(obj,'mcc corner points',cornerPoints);
end

ieInWindowMessage('',handles);

%% Find rect midpoints and patch size.  

% mLocs are the 24 MCC patch middles in (row,col) format.
[mLocs,delta,pSize] = macbethRectangles(cornerPoints);

% Get the mean RGB data or the full data from the patches in a cell array
% The processor window is assumed to store linear RGB values, not gamma
% corrected.
mRGB = macbethPatchData(obj,mLocs,delta,fullData,dataType);

% Plot the rectangles.
if showSelection, macbethDrawRects(obj); end

ieInWindowMessage('',handles);

return;

