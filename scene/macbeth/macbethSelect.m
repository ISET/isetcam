function [mRGB, mLocs, pSize, cornerPoints] = ...
    macbethSelect(obj,showSelection,fullData,cornerPoints)
%Identify Macbeth color checker patch positions from window image
%
% Synopsis
%  [mRGB mLocs, pSize, cornerPoints] =
%            macbethSelect(obj,showSelection,fullData,cornerPoints)
%
% Brief Description
%  This routine typically7 works within an ISET window, though this is not
%  needed when the corner points of the MCC are already known.
%
%  From the window, the user selects the four corner points on the MCC
%  (white, black, blue, brown). This function estimates the (row, column)
%  centers of the 24 MCC patches and the values near the center of each
%  patch.
%
%  The handles to the rects (mccRectHandles) are attached to the object.
%  This lets the macbethDrawRects() routine turn them on and off.
%
% Inputs
%   obj:  sensor, ip, scene
%   showSelection (boolean): Put up the rectangles so the user sees the
%     selected rects.
%   fullData:  Determines output in mRGB
%    If fullData = 0, the mean is returned, and mRGB is Nx3
%     RGB values.  Each row is computed as the mean RGB in a square
%     region around the center third of the Macbeth target. 
%    If fullData = 1, the values of every point in each patch is returned.
%     Use fullData = 1 for sensor images and calculate the means. This will
%     account for the NaNs that are returned. 
%   cornerPoints: Sometimes, the MCC corner point locations are stored.
%     In that case, you can send them in and the routine will skip the
%     graphical interaction.
%
% Outputs
%   mRGB: The data in each patch. The image processor and sensor
%       windows store linear RGB values. The scene stores spectral radiance
%       (photons) and the optical image (NYI) stores spectral irradiance
%       (photons).
%
%   mLocs: The locations for the mean calculation are returned in the mLocs
%        variable. This is a matrix that is Nx2, where there are N (24)
%        sample positions with a (row,col) coordinate.
%   pSize:           The size of the square region in the center of the patch
%   cornerPoints:    Corner points of the selected MCC
%
% In ISET the ordering of the Macbeth patches is:
%
%   Achromatic series at the bottom, with white at the left
%   The brown patch at the upper left is (1)
%   We then count down the first column.
%   The 4th entry is the white patch.
%   The gray series is 4:4:24
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also:  
%   macbethSensorValues, macbethRectangles, macbethROIs, chartRectangles,
%   chartPatchData

% Examples:
%{ 
% Uncomment to run, requires the user to make selections
%
%   scene = sceneCreate; sceneWindow(scene);
%   macbethSelect(scene); scene = ieGetObject('scene');
%}
%{
 scene = sceneCreate;
 cornerPoints =[
     0    64
    96    64
    96     1
     1     1];
 scene = sceneSet(scene,'mcc corner points',cornerPoints);
 sceneWindow(scene);
 macbethDrawRects(scene,'on');
%}
%{
 scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
 sensor = sensorCreate; sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'));
 sensor = sensorCompute(sensor,oi);
 ip = ipCreate; ip = ipCompute(ip,sensor);
 cornerPoints = [
   3   179
   240   179
   241    21
     2    21];
 ip = ipSet(ip,'mcc corner points',cornerPoints);
 ipWindow(ip); macbethDrawRects(ip,'on');
 data = macbethSelect(ip); 
%}
%{
 % See macbethSensorValues() for this functionality.
  sensor = vcGetObject('sensor');
  [fullRGB,locs,pSize] = macbethSelect(sensor,0,1);
  [fullRGB,locs,pSize] = macbethSelect(sensor);
%}
%{
  obj = vcGetObject('vcimage'); [rgb,locs] = macbethSelect(obj);
  dataXYZ = imageRGB2xyz(obj,rgb); whiteXYZ = dataXYZ(1,:);
  lab = ieXYZ2LAB(dataXYZ,whiteXYZ);
  plot3(lab(:,1),lab(:,2),lab(:,3),'o')
%}
%{
% This method is used to get the raw data of the gray series
  obj = ieGetObject('ip');
  mRGB = macbethSelect(obj,false);
  graySeries = mRGB(4:4:24,:);
%}
%{
  showSelection = 1;
  obj = vcGetObject('ip');
  [mRGB mLocs, pSize, cornerPoints]= macbethSelect(obj,showSelection);
%}

%%
if ieNotDefined('obj'), obj = vcGetObject('vcimage'); end
if ieNotDefined('showSelection'), showSelection = true; end
if ieNotDefined('fullData'), fullData = 0; end

%% Corner point 
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
    case {'scene'}
        handles = ieSessionGet('scene Window Handles');
        dataType = 'photons';
        obj = sceneSet(obj,'mcc Rect Handles',[]);
        vcReplaceObject(obj);
        if ieNotDefined('cornerPoints')
            cornerPoints = sensorGet(obj,'mcc corner points');
        end
    otherwise
        error('Unknown object type');
end

%% Deal with the interactive part

queryUser = false;
if isempty('cornerPoints')
    queryUser = true;
    % The user didn't send in any corner points, and there weren't any in
    % the structure, then we have the user select them in the window.
    cornerPoints = vcPointSelect(obj,4,...
        'Select (1) lower left, (2) lower right, (3) upper right, (4) upper left');
end

%% Save the corner points
switch vcEquivalentObjtype(obj.type)
    case 'VCIMAGE'
        obj = ipSet(obj,'mcc corner points',cornerPoints);
    case 'ISA'
        obj = sensorSet(obj,'mcc corner points',cornerPoints);
    case 'SCENE'
        obj = sceneSet(obj,'mcc corner points',cornerPoints);
end

%% Ask if the rects are OK. 
if queryUser
    macbethDrawRects(obj);
    rectsOK = ieReadBoolean('Are these rects OK?');
    if isempty(rectsOK)
        fprintf('%s: user canceled\n',mfilename);
        mRGB=[]; mLocs=[]; pSize=[]; cornerPoints=[];
        return;
    else
        while ~rectsOK   % False, a change is desired
            % Bring up the window
            switch vcEquivalentObjtype(obj.type)
                case {'VCIMAGE'}
                    ipWindow;
                case {'ISA'}
                    sensorWindow('scale',1);
                case {'SCENE'}
                    sceneWindow;
                otherwise
                    error('Unknown type %s\n',obj.type);
            end
            
            % These appear to come back as (x,y),(col,row).  The upper left of the
            % image is (1,1).
            cornerPoints = vcPointSelect(obj,4,...
                'Select (1) lower left, (2) lower right, (3) upper right, (4) upper left');
            
            switch vcEquivalentObjtype(obj.type)
                case 'VCIMAGE'
                    obj = ipSet(obj,'mcc corner points',cornerPoints);
                case 'ISA'
                    obj = sensorSet(obj,'mcc corner points',cornerPoints);
                case 'SCENE'
                    obj = sceneSet(obj,'mcc corner points',cornerPoints);
            end
            macbethDrawRects(obj);
            rectsOK = ieReadBoolean('Are these rects OK?');
        end
    end
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

end

