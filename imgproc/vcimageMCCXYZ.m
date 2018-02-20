function [macbethXYZ, whiteXYZ, cornerPoints] = vcimageMCCXYZ(vci,cornerPoints,method)
%Estimate XYZ values of the MCC patches and the image white point from vci
%
%  [macbethXYZ, whiteXYZ] = vcimageMCCXYZ(vci,pointLoc,method)
%
% We assume the vci has an image of the MCC in its output field
%
% vci:       The virtual camera image structure 
% pointLoc:  Outer points of the MCC (usually selected by user)
% method:    We either assume the display is an sRGB display (method =
%            'sRGB'), or we use the model display in the processor window
%            (method = 'custom').
%
% macbethXYZ:  24 x 3
% whiteXYZ:    3 x 1, white point, which is macbethXYZ(4,:)
% pointLoc:    Locations of the points in the iamge
%
% The MCC white patch the fourth row, first column.
%
% Examples:
%  vci = vcGetObject('vcimage'); [macbethXYZ, whiteXYZ] = vcimageMCCXYZ(vci);
%  figure(1); clf; plot3(macbethXYZ(:,1),macbethXYZ(:,2),macbethXYZ(:,3),'o')
%  xy = chromaticity(macbethXYZ);
%  clf; plot(xy(:,1),xy(:,2),'o'); hold on; plotSpectrumLocus; 
%  grid on; axis equal
%
%  macbethLAB = ieXYZ2LAB(macbethXYZ,whiteXYZ, 1);
%  clf; plot3(macbethLAB(:,1),macbethLAB(:,2), macbethLAB(:,3),'o'); 
%  set(gca,'xlim',[0 105]); grid on
%
% See Also: macbethColorError, macbethEvaluationGraphs
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Check input variables
if ieNotDefined('vci'), vci = vcGetObject('vcimage'); end
if ieNotDefined('method'), method = 'sRGB'; end

% These pointLoc values are the coordinates of the corners of the MCC in
% the image.  
% The extracted rgbData from the processor window are assumed to be linear
% values, not sRGB values or gamma corrected.  They are the linear display
% primaries.
if ieNotDefined('cornerPoints')
    % macbethSelect will prompt the user to identify corners.
    [rgbData, mLocs, pSize, cornerPoints] = macbethSelect(vci);
    if isempty(rgbData)
        fprintf('%s: user canceled\n',mfilename);
        macbethXYZ = []; whiteXYZ = []; cornerPoints = [];
        return;
    end
    clear mLocs
    clear pSize
else
    % The user is not bothered
    rgbData = macbethSelect(vci,0,0,cornerPoints);
end

%% Compute the 

switch(lower(method))
    case 'srgb'
        % The display is treated as an sRGB.

        % We read the data and convert them into sRGB values.
        rgbLSRGB = lrgb2srgb(ieClip(rgbData,0,1));
        
        % When convert the sRGB values into XYZ values for the RGB*L data.
        % The format for sgb2xyz is (row,col,colorVector).  We treat the
        % MCC as one row, 24 columns, each with three entries.
        rgbLSRGB = XW2RGBFormat(rgbLSRGB,4,6);        
        macbethXYZ = srgb2xyz(rgbLSRGB);  % Y is in cd/m2
        % vcNewGraphWin; image(xyz2srgb(macbethXYZ)); 

    case 'custom'
        % The routine imageRGB2XYZ accounts for the currently loaded
        % display model, particularly the SPD of the display, to compute
        % the MCC's XYZ values on the display.
        rgbData = XW2RGBFormat(rgbData,4,6);
        macbethXYZ = imageRGB2XYZ(vci,rgbData);
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
