function [macbethXYZ, whiteXYZ, cornerPoints] = ipMCCXYZ(ip,cornerPoints,method)
%Estimate XYZ values of the MCC patches and the image white point from ip
%
%  [macbethXYZ, whiteXYZ] = ipMCCXYZ(ip,pointLoc,method)
%
% We assume the ip has an image of the MCC in its output field
%
% ip:        The virtual camera image structure
% pointLoc:  Outer points of the MCC (usually selected by user)
% method:    We either assume the display is an sRGB display (method =
%            'sRGB'), or we use the model display in the processor window
%            (method = 'custom').
%
% macbethXYZ:  24 x 3
% whiteXYZ:    3 x 1, white point, which is macbethXYZ(4,:)
% pointLoc:    Locations of the points in the image
%
% The MCC white patch the fourth row, first column.
%
% ieExamplesPrint('ipMCCXYZ');
%
% See Also:
%    macbethColorError, macbethEvaluationGraphs
%

% Examples:
%{
  ip = ieGetObject('ip');
 [macbethXYZ, whiteXYZ] = ipMCCXYZ(ip);
 ieNewGraphWin;
 plot3(macbethXYZ(:,1),macbethXYZ(:,2),macbethXYZ(:,3),'o')
 xy = chromaticity(macbethXYZ);
 clf; plot(xy(:,1),xy(:,2),'o'); hold on; plotSpectrumLocus;
 grid on; axis equal

 macbethLAB = ieXYZ2LAB(macbethXYZ,whiteXYZ, 1);
 clf; plot3(macbethLAB(:,1),macbethLAB(:,2), macbethLAB(:,3),'o');
 set(gca,'xlim',[0 105]); grid on
%}


%% Check input variables
if ieNotDefined('ip'), ip = ieGetObject('ip'); end
if ieNotDefined('method'), method = 'sRGB'; end

% These pointLoc values are the coordinates of the corners of the MCC in
% the image.
% The extracted rgbData from the processor window are assumed to be linear
% values, not sRGB values or gamma corrected.  They are the linear display
% primaries.
if ieNotDefined('cornerPoints')
    % macbethSelect will prompt the user to identify corners.
    [rgbData, mLocs, pSize, cornerPoints] = macbethSelect(ip);
    if isempty(rgbData)
        fprintf('%s: user canceled\n',mfilename);
        macbethXYZ = []; whiteXYZ = []; cornerPoints = [];
        return;
    end
    clear mLocs
    clear pSize
else
    % The user is not bothered
    rgbData = macbethSelect(ip,0,0,cornerPoints);
end

%% Compute the

switch(lower(method))
    case 'srgb'
        
        disp('Converting rgb to XYZ values from an sRGB display');
        
        % We read the data and convert them into sRGB values.
        rgbLSRGB = lrgb2srgb(ieClip(rgbData,0,1));
        
        % When convert the sRGB values into XYZ values for the RGB*L data.
        % The format for sgb2xyz is (row,col,colorVector).  We treat the
        % MCC as one row, 24 columns, each with three entries.
        rgbLSRGB   = XW2RGBFormat(rgbLSRGB,4,6);
        macbethXYZ = srgb2xyz(rgbLSRGB);  % Y is in cd/m2
        % vcNewGraphWin; image(xyz2srgb(macbethXYZ));
        
    case 'custom'
        
        fprintf('Converting rgb to XYZ assuming linear display (%s)\n',ipGet(ip,'display name'));
        
        % The routine imageRGB2XYZ uses the currently loaded display model,
        % particularly the SPD of the display, to compute the MCC's XYZ
        % values on the display.
        rgbData    = XW2RGBFormat(rgbData,4,6);
        macbethXYZ = imageRGB2XYZ(ip,rgbData);
        % vcNewGraphWin; image(xyz2srgb(macbethXYZ))
        
end

% Squeeze the singleton dimension
% Also, the data are now single format.  For various CIELAB calculations
% they need to be double.  So double() them here.
macbethXYZ = double(RGB2XWFormat(macbethXYZ));

% We pull out the white point to be a 3-vector from the more complex image
% structure.
whiteIndex = 4;
whiteXYZ   = double(macbethXYZ(whiteIndex,:));


end
