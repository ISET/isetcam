% [pyr,pind] =
% buildSFpyrLevs_o(lodft,log_rad,Xrcos,Yrcos,angle,ht,nbands,ncycs,angleCyc
% s,ifSave,curScale);
%
% Recursive function for constructing levels of a steerable pyramid.  This
% is called by buildSFpyr, and is not usually called directly.

% Eero Simoncelli, 5/97. modified by Yuanzhen Li, 5/05, to incorporate
% spatial and orientation oversampling. 
% Then the pyramid is really really oversampled.

function [pyr,pind] = buildSFpyrLevs_o(lodft,log_rad,Xrcos,Yrcos,angle,ht,nbands,ncycs,angleCycs,ifSave,curScale);

if nargin < 10
    ifSave = 0;
    curScale = 0;
    % current scale, determining the index of the band to be saved
end

% oversampled steerable pyramids

if (ht <= 0)

  lo0 = ifft2(ifftshift(lodft));
  pyr = real(lo0(:));
  pind = size(lo0);

else

  bands = zeros(prod(size(lodft)), nbands);
  bind = zeros(nbands,2);

%  log_rad = log_rad + 1;
  Xrcos = Xrcos - log2(2);  % shift origin of lut by 1 octave.

  lutsize = 1024;
  Xcosn = pi*[-(2*lutsize+1):(lutsize+1)]/lutsize;  % [-2*pi:pi]
  order = nbands-1;
  %% divide by sqrt(sum_(n=0)^(N-1)  cos(pi*n/N)^(2(N-1)) )
  %% Thanks to Patrick Teo for writing this out :)
  const = (2^(2*order))*(factorial(order)^2)/(nbands*factorial(2*order));
  Ycosn = sqrt(const) * (cos(Xcosn)).^order;
  himask = pointOp(log_rad, Yrcos, Xrcos(1), Xrcos(2)-Xrcos(1), 0);
  
  angle_increment = pi/nbands/angleCycs;
  for b = 1:nbands
      angle_start = Xcosn(1)+pi*(b-1)/nbands;
      for jj = 1:angleCycs
          anglemask = pointOp(angle, Ycosn, angle_start+(jj-1)*angle_increment, Xcosn(2)-Xcosn(1));
          banddft = ((-sqrt(-1))^(nbands-1)) .* lodft .* anglemask .* himask;
          band = ifft2(ifftshift(banddft));
          
          if ifSave == 0
              bands(:,(b-1)*angleCycs+jj) = real(band(:));
          else
              bands_here = real(band(:));
              band_ind = (curScale-1)*nbands*angleCycs + (b-1)*angleCycs + jj + 1;
              band_name = sprintf('band_%04d.dat', band_ind);
              fp = fopen(band_name, 'w');
              fwrite(fp, size(band), 'int32');
              fwrite(fp, bands_here, 'float32');
              fclose(fp);
              bands = [];
          end
          bind((b-1)*angleCycs+jj,:)  = size(band);
      end
  end

  dims = size(lodft);
  ctr = ceil((dims+0.5)/2);
  lodims = ceil((dims-0.5)/(2^ncycs));
  loctr = ceil((lodims+0.5)/2);
  lostart = ctr-loctr+1;
  loend = lostart+lodims-1;

  log_rad_ctr = log_rad(lostart(1):loend(1),lostart(2):loend(2));
  log_rad = zeros(dims);
  log_rad(lostart(1):loend(1),lostart(2):loend(2)) = log_rad_ctr;
%   angle = angle(lostart(1):loend(1),lostart(2):loend(2));
%   angle = imresize(angle, dims, 'bicubic');
%   lodft = lodft(lostart(1):loend(1),lostart(2):loend(2));
%   lodft = imresize(lodft, dims, 'bicubic');
  
  YIrcos = abs(sqrt(1.0 - Yrcos.^2));
  lomask = pointOp(log_rad, YIrcos, Xrcos(1), Xrcos(2)-Xrcos(1), 0);

  lodft = lomask .* lodft;

  [npyr,nind] = buildSFpyrLevs_o(lodft, log_rad, Xrcos, Yrcos, angle, ht-1, nbands, ncycs+1, angleCycs, ifSave, curScale+1);

  pyr = [bands(:); npyr];
  pind = [bind; nind];

end

