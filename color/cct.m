function Tc = cct(uvs)
% Calculate  correlated color temperature from CIE uv coordinates
%
%   correlatedColorTemperature = cct(uvArray)
%
% The CIE has defined methods for estimating the relationship between
% chromaticity coordinates (uv, see xyz2uv) and the color temperature of a
% blackbody radiator. This routine accepts 1960 UCS chromaticity
% coordinates, uv, and returns the color temperature in degrees Kelvin of
% the correlated blackbody radiators.
%
% This correlated color temperature is often used to summarize the
% appearance properties of a light source.
%
% This routine requires the information in the file: cct.mat
%
% Reference: Wyszecki & Stiles pgs. 227-228
%
% correlatedColorTemperature
% UV  : [u1,u2,u3 ...; v1, v2, v3 ...] chromaticity coordinates as a column vector.
%
%Example:
%  colorTemp = cct([.31,.32]')
%
%
% See also: spd2cct, xyz2uv
%
% Copyright ImagEval Consultants, LLC, 2003.


% TODO:  Make this work for XYZ.  Make an xyY to uv conversion routine.
% Put the cct.mat file in the proper place and give it some decent
% structure.

if ieNotDefined('uvs'), error('uv coordinates are required');
elseif (size(uvs,1) ~= 2), error('uv must have two rows.');
end

cctData = load('cct.mat');

Nd = size(uvs,2);		% Number of uv coordinates
Nt = size(cctData.table,1);	    % Number of temperatures

T  = repmat(cctData.table(:,1),[1 Nd]);
u  = repmat(cctData.table(:,2),[1 Nd]);
v  = repmat(cctData.table(:,3),[1 Nd]);
t  = repmat(cctData.table(:,4),[1 Nd]);

us = repmat(uvs(1,:),[Nt 1]);
vs = repmat(uvs(2,:),[Nt 1]);

d  = ( (us-u) - t.*(vs-v) ) ./ sqrt( 1+t.^2 );

% Instead of dividing as explained in W&S and
% checking for negative values.  I look at the
% signs and took differences.  This avoids
% divide by zero errors.

% ds is padded by zeros to get the indices
% correct when doing the find operation.

ds = sign(d);
ds = ds.*(ds~=0) + 1.*(ds==0);
ds = [ds; zeros(1,Nd)];

j  = find( abs(diff(ds)) == 2 )';

if (length(j) ~= Nd)
    error(['Check input range. ' ...
        'U [' num2str(u(1,1)) ' ' num2str(u(end,1)) ']. ' ...]
        'V [' num2str(v(1,1)) ' ' num2str(v(end,1)) '].']);
end

Tc = 1 ./ ...
    ( 1./T(j) + d(j)./(d(j)-d(j+1)).*(1./T(j+1) - 1./T(j)) );

return;