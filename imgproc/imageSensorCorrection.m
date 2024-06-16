function [img,ip,Tsensor] = imageSensorCorrection(img,ip,sensor)
% Convert sensor color data (img) to an internal color space (ICS)
%
% Synopsis
%   [img,vci,Tsensor] = imageSensorCorrection(img,ip,sensor)
%
% Description
%
%  This routine applies a linear transform to the sensor data, converting
%  the data to an internal color space.  The internal space can be the
%  sensor space itself, in which case the transform is the identity.  Or it
%  can be a CIE space, such as XYZ or the cone space such as Stockman.
%
%  The current implementation only uses linear transforms of the data. In
%  the future, we will allow more complex transformations, such as those
%  that have locally linear transformations.
%
%  The absolute scale of the internal color space is arbitrary because we
%  don't know the absolute sensitivity of the input. For example, we don't
%  know the exposure duration or the sensitivity of the camera, and so
%  forth. For the case of XYZ, we scale the data so that the largest value
%  is 1.
%
%  The final scaling of the output data in RGB space is set so that
%  the largest RGB value is equal to the ratio between the largest
%  sensor data value in this image and maximum possible sensor value.
%
% The algorithm used is controlled by
%
%     ipGet(ip,'Sensor conversion method')
%
% Sensor conversion method options:
%
%    {'none'} - Sensor data are copied to the internal color space. The
%    color conversion transformation for this step is set to the identity
%    matrix
%
%    {'manual matrix entry'}  - The user is queried and enters a matrix
%    manually. Other transforms are set to null
%
%    {'current matrix'}  - The stored transform matrix in 'prodt' is used.
%    That should change, IMHO, because it includes the illuminant
%    correction.  I think this should only apply the current sensor
%    transform.  Or, perhaps 'current' should never come here at all.
%
%    {'mcc optimized'} - We calculate the (predicted) sensor responses to a
%    Macbeth color checker (MCC) under D65.  Call these P. We also
%    calculate the lRGB (linear sRGB) display values of the MCC under D65.
%    Call these L. Finally, we find the linear transform, T, from the
%    sensor MCC values (P) to the lRGB values (L). The lRGB values are
%    scaled so that the maximum is 1. The transform is stored in the color
%    conversion slot.
%
%    Unless the sensors are within a linear transform of the internal color
%    space (typically XYZ), there is no perfect linear transform from
%    sensor to the internal space. This method finds the linear transform
%    that optimizes the conversion to the internal space for a particular
%    target - the MCC under D65. It is possible to use a different set of
%    surfaces or a different illuminant with the MCC.  The choice of
%    surfaces and illuminant is a way to set the priorities for the linear
%    transformation.  This option sets the priorities as D65 for an MCC.
%
%    {'multisurface'}  - Optimize for 96 random surface reflectances.
%    These are chosen in imageColorTransform
%
%    {'esser optimized'} - As for MCC but using the Esser target. This case
%      is used for IR data because we have the Esser chart into the IR.
%
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:  
%   imageIlluminantCorrection, ipCompute, displayRender
%

%%

if ieNotDefined('img'), error('Image required'); end

% We should flag locations where at least one of the color channel
% pixels is saturated. The linear transformation doesn't make sense
% for those pixels.  We should make sure that the display at those
% locations is white.

param = ieParamFormat(ipGet(ip,'conversion method sensor'));
switch param
    case {'none','sensor'}
        % This case can be trouble when there are more than 3 color
        % channels.  In this condition, we don't have a plan for how to get
        % the data into sRGB space.
        N = ipGet(ip,'nSensorInputs');
        
        if N > 3
            % warndlg('Warning.  No sensor conversion but n sensors > 3');
        end
        % We are told not to transform, so set it to identity with
        % dimension of the sensor input
        Tsensor = eye(N,N);
        ip = ipSet(ip,'conversion transform sensor',Tsensor);
        
    case {'mccoptimized','esseroptimized','multisurface'}
        % Find a linear transformation using  the sensor spectral
        % sensitivities into the internal color space.  The transform is
        % chosen to optimize the representation of the surfaces in a
        % Macbeth Color Checker under a D65 illuminant.
        ics = ipGet(ip,'internal Color Space');                

        % This routine calculates the matrix transform between the two
        % spaces for an illuminant (D65) and some selection of surfaces.
        switch param
            case {'mccoptimized','mcc'}
                % Small, industry standard data set
                Tsensor = ieColorTransform(sensor,ics,'D65','mcc');
            case {'esseroptimized','esser'}
                % Used for IR calculations
                Tsensor = ieColorTransform(sensor,ics,'D65','esser');
            case 'multisurface'
                % Larger, better random selection of surfaces
                Tsensor = ieColorTransform(sensor,ics,'D65','multisurface');
        end
        
        % Apply the transform to the image data
        img = imageLinearTransform(img,Tsensor);
        
        % Do not allow negative values
        img = ieClip(img,0,[]);
        
        % Set the maximum value in the ICS to 1.
        mx = max(img(:));
        img = img/mx; 
       
        % Store the transform.  Note that because of clipping, this
        % transform alone may not do precisely the same job.
        ip = ipSet(ip,'conversion transform sensor',Tsensor);
        
    case {'manualmatrixentry','new'}
        
        % User types in a matrix
        Torig = ipGet(ip,'combined transform');
        Torig = Torig/max(Torig(:));
        Tsensor = ieReadMatrix(Torig,'%.3f   ','Color Transform');
        if isempty(Tsensor), img = []; return; end
        
        % Store and apply this transform.
        ip = ipSet(ip,'conversion transform sensor',Tsensor);
        img = imageLinearTransform(img,Tsensor);  % vcNewGraphWin; imagesc(img)
        
        % Set the other transforms to empty.
        ip = ipSet(ip,'correction method illuminant',[]);
        ip = ipSet(ip,'ics2display',[]);
        
    case 'currentmatrix'
        % Use the stored transform matrix, don't recompute.
        Tsensor   = ipGet(ip,'prodT');
        img = imageLinearTransform(img,Tsensor);
        
    otherwise
        error('Unknown sensor conversion transform method: �%s\n', param)
end

end
