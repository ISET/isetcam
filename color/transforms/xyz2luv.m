function luv = xyz2luv(xyz, whitepoint)
% Convert CIE XYZ values to CIELUV values
%
%    luv = xyz2luv(xyz, whitepoint)
%
% The whitepoint is a 3-vector indicating the XYZ of a white object or
% patch in the scene. 
%
% xyz:  Can be in XW or RGB format.
% whitepoint: a 3-vector of the xyz values of the white point.
%     If not given, use [95.05 100 108.88] as default (not recommended).
%
% LUV is returned in the same format (RGB or XW) as the input matrix xyz.
%
% Formulae are taken from Hunt's book,page 116. I liked the irony that 116
% is prominent in the formula and that is the page number in Hunt.  Also,
% see Wyszecki and Stiles book.
%
% Examples:
%    [val,vci] = vcGetSelectedObject('VCIMAGE');
%    whitepoint = ipGet(vci,'whitepoint')
%    xyz = ipGet(vci,'XYZ')
%    xyz = [xyz; whitepoint]
%    xyz2luv(xyz,whitepoint)
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('xyz'), error('XYZ values required.'); end
if ieNotDefined('whitepoint'), error('White point required.'); end

if ( length(whitepoint)~=3 ),  error('whitepoint must be a three vector'); end

if ndims(xyz) == 3
    iFormat = 'RGB';
    [r,c,w] = size(xyz);
    xyz = RGB2XWFormat(xyz);
else
    iFormat = 'XW';
end

luv = zeros(size(xyz));

luv(:,1) = Y2Lstar(xyz(:,2),whitepoint(2));
[u,v]    = xyz2uv(xyz);
[un,vn]  = xyz2uv(whitepoint);

luv(:,2) = 13*luv(:,1).*(u - un);
luv(:,3) = 13*luv(:,1).*(v - vn);

% return CIELUV in the appropriate format.
% Currently it is a XW format.  If the input had three dimensions
% then we need to change it to that format.
if strcmp(iFormat,'RGB'), luv = XW2RGBFormat(luv,r,c); end

return;



