function img = imgZonePlate(sz, amp, ph)
% imgZonePlate - Make a zone plate image
%
% img = ieZonePlate([SZ], [AMP], [PHASE])
%
% The zone plate function is  AMP * cos( r^2 + PHASE) + 1
% 
% SZ   -- image size (default = 256)
% AMP  --  (default = 1) 
% PHASE (default = 0) 
%
% Examples:
%   img = imgZonePlate(256);  imagesc(img); axis image; colormap(gray(256)); 
%   img = imgZonePlate([384,384],255); imagesc(img);    colormap(gray(256));   axis image
%   img = imgZonePlate([384,384],255,pi/2); imagesc(img); colormap(gray(256)); axis image
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sz'),  sz = [256 256]; end
if ieNotDefined('amp'), amp = 1; end
if ieNotDefined('ph'),  ph = 0;   end

if (length(sz) == 1),  sz = [sz,sz]; end

mxsz = max(sz(1),sz(2));

% Almost ordinary, except we adjus to a minimum value of 0
img = amp * cos( (pi/mxsz) * imgRadialRamp(sz,2) + ph ) + 1;
% img = ieScale(img,0,1);

return;


