function xy = chromaticity( XYZ )
%Compute CIE chromaticity (xy) coordinates from XYZ data
%
%       xy = chromaticity( XYZ)
%
% Purpose:
%  The input (XYZ) data can be in XW (space-wavelength) or RGB format.
%  In XW format, we expect N rows corresponding to spatial positions and
%  three columns containing in X,Y and Z. The chromaticity coordinates
%  (x,y) are returned in the columns of an Nx2 matrix.  
%
%  If the data are in RGB format, the three planes should be (X,Y,Z) images.  The
%  returned data are in as a two dimensional image format, with each
%  spatial position containing the corresponding (x,y) value.
%
%  This routine can be (ab)used to calculate rg coordinates from RGB values. 
%
% Examples:
%    patchSize = 1;
%    macbethChart = sceneCreate('macbeth',patchSize); 
%    p = sceneGet(macbethChart,'photons'); wave = sceneGet(macbethChart,'wave'); 
%    e = Quanta2Energy(wave,p);
%    XYZ = ieXYZFromEnergy(e,wave);  
%    chromaticity(XYZ)
%
%    XYZ = XW2RGBFormat(XYZ,4,6);
%    chromaticity(XYZ)
%
% Copyright ImagEval Consultants, LLC, 2003.

if ndims(XYZ) == 2
   
   if size(XYZ,2) ~= 3
      error('The XW input data should be in the columns of a Nx3 matrix')
      % elseif size(XYZ,1) == size(XYZ,2)
      % warning('Chromaticity input is a 3x3 matrix.  Assuming columns are X,Y,Z');
  end
   
   ncols = size(XYZ,1);
   xy = zeros(ncols,2);
   
   s = sum(XYZ')';
   p = find(s ~= 0);
   xy(p,1) = XYZ(p,1) ./ s(p);
   xy(p,2) = XYZ(p,2) ./ s(p);
   
elseif ndims(XYZ) == 3

   [r c n] = size(XYZ);
   xy = zeros(r,c,2);
   
   s = XYZ(:,:,1) + XYZ(:,:,2) + XYZ(:,:,3);
   xy(:,:,1) = XYZ(:,:,1) ./ s;
   xy(:,:,2) = XYZ(:,:,2) ./ s;
else	
   error('Data must be either Nx3 with XYZ in columns or NxMx3 with XYZ in image planes');
end

return;


