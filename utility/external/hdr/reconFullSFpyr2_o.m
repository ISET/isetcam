function res = reconFullSFpyr2_o(pyr, pind, nsc, nor, angleCycs, ifSave, levs, bands, twidth)
%
% res = reconFullSFpyr2_o(pyr, pind, nsc, nor, angleCycs, ifSave, levs,
% bands, twidth)
% reconstruct image from an oversampled (in both space and angle) pyramid
% built from:
% [pyr,pind,steermtx,harmonics] = buildFullSFpyr2_o(im, ht, order,
% angleCycs, ifSave, twidth)
%

% Reconstruct image from its steerable pyramid representation, in the Fourier
% domain, as created by buildSFpyr.
% Unlike the standard transform, subdivides the highpass band into
% orientations.
% J. Portilla and E. Simoncelli. 
% Modified by Yuanzhen Li 05/05, to incorporate spatial and orientaion oversampling.
% see buildFullSFpyr2_o for details about the input parameters.

%%------------------------------------------------------------
%% DEFAULTS:

if (exist('levs') ~= 1)
  levs = 'all';
end
if (exist('ifSave') ~= 1)
    ifSave = 0;
end

if (exist('bands') ~= 1)
  bands = 'all';
end

if (exist('twidth') ~= 1)
  twidth = 1;
elseif (twidth <= 0)
  fprintf(1,'Warning: TWIDTH must be positive.  Setting to 1.\n');
  twidth = 1;
end

%%------------------------------------------------------------

nbands = nor; %spyrNumBands(pind)/2;

maxLev =  nsc+2; %2+spyrHt(pind(nbands+1:size(pind,1),:));
if strcmp(levs,'all')
  levs = [0:maxLev]';
else
  if (any(levs > maxLev) | any(levs < 0))
    error(sprintf('Level numbers must be in the range [0, %d].', maxLev));
  end
  levs = levs(:);
end

if strcmp(bands,'all')
  bands = [1:nbands]';
else
  if (any(bands < 1) | any(bands > nbands))
    error(sprintf('Band numbers must be in the range [1,3].', nbands));
  end
  bands = bands(:);
end

%----------------------------------------------------------------------

dims = pind(2,:);
ctr = ceil((dims+0.5)/2);

[xramp,yramp] = meshgrid( ([1:dims(2)]-ctr(2))./(dims(2)/2), ...
    ([1:dims(1)]-ctr(1))./(dims(1)/2) );
angle = atan2(yramp,xramp);
log_rad = sqrt(xramp.^2 + yramp.^2);
log_rad(ctr(1),ctr(2)) =  log_rad(ctr(1),ctr(2)-1);
log_rad  = log2(log_rad);

%% Radial transition function (a raised cosine in log-frequency):
[Xrcos,Yrcos] = rcosFn(twidth,(-twidth/2),[0 1]);
Yrcos = sqrt(Yrcos);
YIrcos = sqrt(1.0 - Yrcos.^2);

if (size(pind,1) == 2)
  if (any(levs==1))
    resdft = fftshift(fft2(pyrBand(pyr,pind,2)));
  else
    resdft = zeros(pind(2,:));
  end
else
    if ifSave == 0
        resdft = reconSFpyrLevs_o(pyr(1+sum(prod(pind(1:nbands*angleCycs+1,:)')):size(pyr,1)), ...
            pind(nbands*angleCycs+2:size(pind,1),:), ...
            log_rad, Xrcos, Yrcos, angle, nbands, ifSave, nbands*angleCycs+2, levs, bands, 1, angleCycs);
    else
        resdft = reconSFpyrLevs_o(pyr, pind(nbands*angleCycs+2:size(pind,1),:), ...
            log_rad, Xrcos, Yrcos, angle, nbands, ifSave, nbands*angleCycs+2, levs, bands, 1, angleCycs);
    end
end
 
lo0mask = pointOp(log_rad, YIrcos, Xrcos(1), Xrcos(2)-Xrcos(1), 0);
resdft = resdft .* lo0mask;

%% Oriented highpass bands:
if any(levs == 0)
  lutsize = 1024;
  Xcosn = pi*[-(2*lutsize+1):(lutsize+1)]/lutsize;  % [-2*pi:pi]
  order = nbands-1;
  %% divide by sqrt(sum_(n=0)^(N-1)  cos(pi*n/N)^(2(N-1)) )
  const = (2^(2*order))*(factorial(order)^2)/(nbands*factorial(2*order));
  Ycosn = sqrt(const) * (cos(Xcosn)).^order;

  hi0mask = pointOp(log_rad, Yrcos, Xrcos(1), Xrcos(2)-Xrcos(1), 0);
  
  angle_increment = pi/nbands/angleCycs;
  
  ind = 1;
  band_ind = 2;
  for b = 1:nbands
      if any(bands == b)
          angle_start = Xcosn(1)+pi*(b-1)/nbands;
          for jj = 1:angleCycs
              anglemask = pointOp(angle,Ycosn,angle_start+(jj-1)*angle_increment,Xcosn(2)-Xcosn(1));
              if ifSave == 0
                  band = reshape(pyr(ind:ind+prod(dims)-1), dims(1), dims(2));
              else
                  band_name = sprintf('band_%04d.dat', band_ind);
                  fp = fopen(band_name, 'r');
                  sz = fread(fp, 2, 'int32');
                  band = fread(fp, sz', 'float32');
                  fclose(fp);
                  band_ind = band_ind + 1;
              end
              banddft = fftshift(fft2(band));
              % make real the contents in the HF cross (to avoid information loss in these freqs.)
              % It distributes evenly these contents among the nbands orientations
              Mask = (sqrt(-1))^(nbands-1) * anglemask.*hi0mask;
              Mask(1,:) = ones(1,size(Mask,2))/sqrt(nbands);
              Mask(2:size(Mask,1),1) = ones(size(Mask,1)-1,1)/sqrt(nbands);
              
              resdft = resdft + banddft.*Mask/angleCycs;
              ind = ind + prod(dims);
          end
      end
  end
end

res = real(ifft2(ifftshift(resdft)));
