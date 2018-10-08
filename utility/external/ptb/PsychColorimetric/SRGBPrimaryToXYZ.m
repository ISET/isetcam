function XYZ = SRGBPrimaryToXYZ(rgb)
% XYZ = SRGBPrimaryToXYZ(rgb)
%
% Convert between sRGB primaries and CIE XYZ.
% The rgb are linear device coordinates for the primaries of the sRGB
% standard.  One would expect these to be in the range 0-1, although
% any scaling will simply propogate through to the XYZ coordinates.
%
% See XYZToSRGBPrimary
%
% 5/1/04	dhb	 Wrote it.
% 7/8/10    dhb  To ensure consistency, get matrix from XYZToSRGBPrimary rather than hard coded here.

[nil,M] = XYZToSRGBPrimary([]);
XYZ = inv(M)*rgb;

