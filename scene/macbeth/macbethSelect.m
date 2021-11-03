function [pData, mLocs, pSize, cornerPoints, pStd] = ...
    macbethSelect(obj,showSelection,fullData,cornerPoints)
% Deprecated:  Use chartXXX routines
% Identify Macbeth color checker patch positions from window image
%
% Synopsis
%  [pData mLocs, pSize, cornerPoints, pStd] =
%            macbethSelect(obj,showSelection,fullData,cornerPoints)
%
% Brief Description
%  This routine typically works within an ISET window, though this is not
%  needed when the corner points of the MCC in the image are known.
%
%  The user selects the four corner points on the MCC (white, black, blue,
%  brown). This identifies the 24 MCC patch locations.  Then the data are
%  selected.
%
% Inputs
%   obj:  sensor, ip, scene.  Not sure why, but OI is not yet implemented.
%   showSelection (boolean): Put up the rectangles so the user sees the
%     selected rects.
%   fullData:  Determines output in mRGB
%    If fullData = 0, the mean is returned, and mRGB is Nx3
%     RGB values.  Each row is computed as the mean RGB in a square
%     region around the center third of the Macbeth target.
%    If fullData = 1, the values of every point in each patch is returned.
%     Use fullData = 1 for sensor images and calculate the means. This will
%     account for the NaNs that are returned.
%   cornerPoints: Sometimes, the MCC corner point locations are stored in
%     the scene struct. In that case, this routine will skip the graphical
%     interaction.
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
%   mRGBstd:  Standard deviation when the mean values are requested
%
% In ISET the ordering of the Macbeth patches is:
%
%   Achromatic series at the bottom, with white at the left
%   The brown patch at the upper left is (1)
%   We then count down the first column.
%   The 4th entry is the white patch.
%   The gray series is 4:4:24
%
% See examples:
%  ieExamplesPrint('macbethSelect');
%
% Programming TODO:
%   Should be refactored as (p means 'patch')
%
%     [pData, pSD, cornerPoints, mLocs, pSize] =
%        macbethSelect(obj,cornerPoints,dataType,showRects,fullData);
%
%   Also (a) more testing, and (b)oi implemented
%
% See also:
%   macbethSensorValues, macbethRectangles, macbethROIs, chartRectangles,
%   chartRectsData
%

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
 scene  = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
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

% This should be a parameter
queryUser = false;

%% Corner points

% To select the data, we start with the chart corner points.  They might be
%   * Sent in
%   * Attached to the object
%   * We choose in the window
switch lower(obj.type)
    case 'vcimage'
        dataType = 'result';
        % obj = ipSet(obj,'mcc Rect Handles',[]);
        % ieAddObject(obj); ipWindow;
        
        if ieNotDefined('cornerPoints')
            cornerPoints = ipGet(obj,'corner points');
            if isempty(cornerPoints)
                ipWindow;
                cornerPoints = chartCornerpoints(obj,wholeChart);
            end
        end
        obj = ipSet(obj,'chart corner points',cornerPoints);
        
    case {'isa','sensor'}
        % app = ieSessionGet('sensor window');
        dataType = 'dvorvolts';
        if ieNotDefined('cornerPoints')
            cornerPoints = sensorGet(obj,'corner points');
            if isempty(cornerPoints)
                sensorWindow;
                cornerPoints = chartCornerpoints(obj,wholeChart);
            end
        end
        obj = sensorSet(obj,'chart corner points',cornerPoints);
        
    case {'scene'}
        dataType = 'photons';
        cornerPoints = sceneGet(obj,'chart corner points');
        if ieNotDefined('cornerPoints')
            sceneWindow;
            cornerPoints = chartCornerpoints(obj);
        end
        obj = sceneSet(obj,'chart corner points',cornerPoints);
        
    otherwise
        error('Unknown object type');
end

%% Deal with the interactive part

%{
% In this scheme we should never ge here.
queryUser = false;
if isempty(cornerPoints)
    queryUser = true;
    % The user didn't send in any corner points, and there weren't any in
    % the structure, then we have the user select them in the window.
    cornerPoints = vcPointSelect(obj,4,...
        'Select (1) lower left, (2) lower right, (3) upper right, (4) upper left');
end
switch vcEquivalentObjtype(obj.type)
    case 'VCIMAGE'
        obj = ipSet(obj,'chart corner points',cornerPoints);
    case 'ISA'
        obj = sensorSet(obj,'chart corner points',cornerPoints);
    case 'SCENE'
        obj = sceneSet(obj,'chart corner points',cornerPoints);
end
%}


%% Ask if the rects are OK.
if queryUser
    macbethDrawRects(obj);
    rectsOK = ieReadBoolean('Are these rects OK?');
    if isempty(rectsOK)
        fprintf('%s: user canceled\n',mfilename);
        pData=[]; mLocs=[]; pSize=[]; cornerPoints=[];
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

%% Find rect midpoints and patch size.

% mLocs are the 24 MCC patch middles in (row,col) format.
[mLocs,delta,pSize] = macbethRectangles(cornerPoints);

% Get the mean RGB data or the full data from the patches in a cell array
% The processor window is assumed to store linear RGB values, not gamma
% corrected.
[pData,pStd] = macbethPatchData(obj,mLocs,delta,fullData,dataType);

% Plot the rectangles.
if showSelection, macbethDrawRects(obj); end

end

