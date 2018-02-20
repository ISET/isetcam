function [rx, ry ,bx ,by, g1x, g1y, g2x, g2y] = bayerIndices(bPattern,sz,clip)
%Identify pixel positions in a Bayer array
%
%   [rx, ry ,bx ,by, g1x, g1y, g2x, g2y] = bayerIndices(bPattern,sz,[clip])
%
% This routine is called by AdaptiveLaplacian and other demosaicking
% routines.  The locations of the various pixel types are returned in the
% parameters.  An array of all the r pixels in a mosaic can be calculated
% as bayerData(ry,rx)
%
%  bPattern is a string (e.g., 'rggb')
%  sz:  the array size (e.g., 128).  It can be specified as a single
%       number or as a 2-vector (row,col)
%  clip: 
%    In some cases, we only want the locations of the pixels in a certain
%    region of sensor, say in from the edge.  For example in
%    AdaptiveLaplacian, we want indices that start at 3,4 and end at
%    Hex-2,Vex-2. So, we allow a special parameter, clip, that lets the
%    measurements start a 1+clip and end at Hex/Vex - clip.
%
% Example:
%   [rx, ry ,bx ,by, g1x, g1y, g2x, g2y] = bayerIndices('grbg',[16,16]);
%   [rx, ry ,bx ,by, g1x, g1y, g2x, g2y] = bayerIndices('gbrg',16);
%   [rx, ry ,bx ,by, g1x, g1y, g2x, g2y] = bayerIndices('rggb',16,2);
%   [rx, ry ,bx ,by, g1x, g1y, g2x, g2y] = bayerIndices('gbrg',16);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('bPattern'), error('Array Bayer pattern must be specified');end
if ieNotDefined('sz'),       error('Array size must be specified'); end
if ieNotDefined('clip'),     clip = 0; end

% Horizontal and vertical extent of the mosaic.
if length(sz)==2, Hex = sz(2); Vex = sz(1);
else              Hex = sz;    Vex = sz;
end

switch lower(bPattern(:)')
    case 'grbg'
        g1x = (1+clip):2:(Hex-clip);
        g1y = (1+clip):2:(Vex-clip);
        
        rx  = (2+clip):2:(Hex-clip);
        ry  = (1+clip):2:(Vex-clip);
        
        bx  = (1+clip):2:(Hex-clip);
        by  = (2+clip):2:(Vex-clip); 
        
        g2x = (2+clip):2:(Hex-clip);
        g2y = (2+clip):2:(Vex-clip);
        
    case 'rggb'
        g1x = (2+clip):2:(Hex-clip);
        g1y = (1+clip):2:(Vex-clip);
        
        rx  = (1+clip):2:(Hex-clip);
        ry  = (1+clip):2:(Vex-clip);
        
        bx  = (2+clip):2:(Hex-clip);
        by  = (2+clip):2:(Vex-clip); 
        
        g2x = (1+clip):2:(Hex-clip);
        g2y = (2+clip):2:(Vex-clip);
        
     case 'gbrg'
        g1x = (1+clip):2:(Hex-clip);
        g1y = (1+clip):2:(Vex-clip);
        
        rx  = (1+clip):2:(Hex-clip);
        ry  = (2+clip):2:(Vex-clip);
        
        bx  = (2+clip):2:(Hex-clip);
        by  = (1+clip):2:(Vex-clip); 
        
        g2x = (2+clip):2:(Hex-clip);
        g2y = (2+clip):2:(Vex-clip);
    
    case 'bggr'
        g1x = (2+clip):2:(Hex-clip);
        g1y = (1+clip):2:(Vex-clip);
        
        rx  = (2+clip):2:(Hex-clip);
        ry  = (2+clip):2:(Vex-clip);
        
        bx  = (1+clip):2:(Hex-clip);
        by  = (1+clip):2:(Vex-clip); 
        
        g2x = (1+clip):2:(Hex-clip);
        g2y = (2+clip):2:(Vex-clip);
        
    otherwise
        error('Unsupported Bayer pattern.');
        
end

return;

