% resdft =
% reconSFpyrLevs_o(pyr,pind,log_rad,Xrcos,Yrcos,angle,nbands,ifSave,band_in
% d,levs,bands,ncycs,angleCycs);
%
% Recursive function for reconstructing levels of a steerable pyramid
% representation.  This is called by reconSFpyr, and is not usually
% called directly.

% Eero Simoncelli, 5/97. modified by Yuanzhen Li, 5/05, to incorporate
% spatial and orientation oversampling.
% Then the pyramid is really really oversampled.

function resdft = reconSFpyrLevs_o(pyr,pind,log_rad,Xrcos,Yrcos,angle,nbands,ifSave,band_ind,levs,bands,ncycs,angleCycs);

lo_ind = nbands*angleCycs+1;;
dims = pind(1,:);
ctr = ceil((dims+0.5)/2);

%  log_rad = log_rad + 1;
Xrcos = Xrcos - log2(2);  % shift origin of lut by 1 octave.

if any(levs > 1)

  lodims = ceil((dims-0.5)/(2^((ncycs))));
  loctr = ceil((lodims+0.5)/2);
  lostart = ctr-loctr+1;
  loend = lostart+lodims-1;
  nlog_rad_ctr = log_rad(lostart(1):loend(1),lostart(2):loend(2));
  nlog_rad = zeros(dims);
  nlog_rad(lostart(1):loend(1),lostart(2):loend(2)) = nlog_rad_ctr;
  nangle = angle;
%  nangle = angle(lostart(1):loend(1),lostart(2):loend(2));

  if  (size(pind,1) > lo_ind)
      if ifSave == 0
          nresdft = reconSFpyrLevs_o( pyr(1+sum(prod(pind(1:lo_ind-1,:)')):size(pyr,1)),...
	            pind(lo_ind:size(pind,1),:), ...
	            log_rad, Xrcos, Yrcos, nangle, nbands, ifSave, band_ind+angleCycs*nbands, levs-1, bands, ncycs+1, angleCycs);
        else
            nresdft = reconSFpyrLevs_o( pyr,...
	            pind(lo_ind:size(pind,1),:), ...
	            log_rad, Xrcos, Yrcos, nangle, nbands, ifSave, band_ind+angleCycs*nbands, levs-1, bands, ncycs+1, angleCycs);
        end
  else
      if ifSave == 0
          nresdft = fftshift(fft2(pyrBand(pyr,pind,lo_ind)));
      else
          nresdft = fftshift(fft2(pyrBand(pyr,pind,1)));
      end
  end

  YIrcos = sqrt(abs(1.0 - Yrcos.^2));
  lomask = pointOp(nlog_rad, YIrcos, Xrcos(1), Xrcos(2)-Xrcos(1), 0);
%   lomask = zeros(dims);
%   lomask(lostart(1):loend(1),lostart(2):loend(2)) = lomask_ctr;

  resdft = zeros(dims);
  resdft = nresdft .* lomask;

else

  resdft = zeros(dims);

end

	
if any(levs == 1)

  lutsize = 1024;
  Xcosn = pi*[-(2*lutsize+1):(lutsize+1)]/lutsize;  % [-2*pi:pi]
  order = nbands-1;
  %% divide by sqrt(sum_(n=0)^(N-1)  cos(pi*n/N)^(2(N-1)) )
  const = (2^(2*order))*(factorial(order)^2)/(nbands*factorial(2*order));
  Ycosn = sqrt(const) * (cos(Xcosn)).^order;
  himask = pointOp(log_rad, Yrcos, Xrcos(1), Xrcos(2)-Xrcos(1),0);
  
  angle_increment = pi/nbands/angleCycs;
  ind = 1;
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
                  band_ind = band_ind+1;
              end
              banddft = fftshift(fft2(band));
              resdft = resdft + (sqrt(-1))^(nbands-1) * banddft.*anglemask.*himask/angleCycs;
              ind = ind + prod(dims);
          end
      end      
  end
end

