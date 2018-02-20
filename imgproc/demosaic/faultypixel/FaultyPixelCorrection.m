function [ bayer_out ] = FaultyPixelCorrection( list, bayer_in, method, outsize )
% FAULTYPIXELCORRECTION: Corrects dead pixels.
%
%   [ BAYER_OUT ] = FaultyPixelCorrection( LIST, METHOD, BAYER_IN )
%
% Use a demosaic algorithm to correct faulty (dead) pixels.
%
% BAYER_OUT: Corrected bayer image.
%
% LIST     : Location of faulty pixels (Nx2) row,col positions.
%            Format: [x1 y1;x2 y2;...]
% METHOD   : Demosaic algorithm to use.
% BAYER_IN : Bayer image with bad pixels
%
% Copyright ImagEval Consultants, LLC, 2006.

% This method looks bad and needs a re-write - BW
%
error('FaultyPixelCorrection must be re-written');
return;

% Check inputs here ...

% 
if (size(list,2) ~= 2), error('LIST dimensions must be Nx2'); end
if (max(list) > size(bayer_in)), error('LIST values can not exceed image size'); end
if (min(list) < [1 1]), error('List values can not be zero or negative'); end
if (ischar(method) == 0), error('METHOD must be the name of a function'); end
if (mod(outsize,2) ~= 1), error('OUTSIZE must be an odd number'); end

% Perform pixel correction.
color = bayercolor(list);

center = (outsize+1)/2;
range  = (-(outsize-1)/2):((outsize-1)/2);

% Need mask, implied GBRG pattern, and color.

for n=1:size(list,1)
   
   bayer = zeros(outsize,outsize,3);

   if (color(n) == 2)       
      x_range      = list(1,n)+range;
      y_range      = list(2,n)+range;
      bayer(:,:,1) = bayer_in(y_range,x_range,2);
      temp         = feval(method,bayer)
      replacement  = temp(center,center,1);
   else
      x_range      = list(1,n)+2*range;
      y_range      = list(2,n)+2*range;
      bayer(:,:,2) = bayer_in(y_range,x_range,color(n));
      temp         = feval(method,bayer);
      replacement  = temp(center,center,2);     
   end
   
   bayer_out(list(2,n),list(1,n),color(n)) = replacement;
   
end
