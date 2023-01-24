function [point, status] = project2(bb, fitme, fac)
% [point, status] = project2(bb, fitme, fac)
% Projects the data in array bb along the direction defined by
%  npix = (1/slope)*nlin.  Used by sfrmat3, sfrmat4 functions.
% Data is accumulated in 'bins' that have a width (1/fac) pixel.
% The smooth, supersampled one-dimensional vector is returned.
%  bb = input data array
%  slope and loc are from the least-square fit to edge
%    y = loc + slope*cent(x)
%  fitme = polynomial fit for the edge (ncolor, npol+1), npol = polynomial
%          fit order. For a vertical edge, the fit is x = f(y). For a linear
%          fit, npol =1, e.g., fitme = [slope, offset]
%          
%  fac = oversampling (binning) factor, default = 4
%  Note that this is the inverse of the usual cent(x) = int + slope*x
%  status =1;
%  point = output edge profile vector
%  status = 1, OK
%  status = 1, zero counts encountered in binning operation, warning is
%           printed, but execution continues
%
% Copyright (c) Peter D. Burns, 2020
% Modified on 4 April 2017 to correct zero-count handling
%             24 June 2020
status =0;
[nlin, npix]=size(bb);

if nargin<3
 fac = 4 ;
end

slope = fitme(end-1);

nn = floor(npix *fac) ;

 slope =  1/slope;
  offset =  round(  fac*  (0  - (nlin - 1)/slope )   );

 del = abs(offset);
 if offset>0
     offset=0;
 end
 bwidth = nn + del+150;
 barray = zeros(2, bwidth);  %%%%%
 
 % Projection and binning
 p2 = zeros(nlin,1);
 
for m=1:nlin
    y = m-1;
    p2(m) =  polyval(fitme,y)-fitme(end);
end

% Projection and binning

for n=1:npix
    for m=1:nlin
        x = n-1;
        y = m-1;      
        ling =   ceil( (x - p2(m))*fac ) + 1 - offset;
        if ling<1
           ling = 1;
        elseif ling>bwidth     
           ling = bwidth;
        end
        barray(1,ling) = barray(1,ling) + 1;
        barray(2,ling) = barray(2,ling) + bb(m,n);
    end
end

 point = zeros(nn,1);
 start = 1+round(0.5*del); %*********************************

% Check for zero counts
  nz =0;
 for i = start:start+nn-1 % ********************************
% 
  if barray(1, i) ==0
   nz = nz +1;
   status = 0;  
   if i==1
    barray(1, i) = barray(1, i+1);
    barray(2, i) = barray(2, i+1); % Added the following steps
    elseif i==start+nn-1            
     barray(1, i) = barray(1, i-1);
     barray(2, i) = barray(2, i-1);
     
   else                           % end of added code
    barray(1, i) = (barray(1, i-1) + barray(1, i+1))/2;
    barray(2, i) = (barray(2, i-1) + barray(2, i+1))/2; % Added
   end
  end
 end
 % 
 if status ~=0
  disp('                            WARNING');
  disp('      Zero count(s) found during projection binning. The edge ')
  disp('      angle may be large, or you may need more lines of data.');
  disp('      Execution will continue, but see Users Guide for info.'); 
  disp(nz);
 end

 for i = 0:nn-1 
  point(i+1) = barray(2, i+start)/ barray(1, i+start);
 end
point = point';   % 4 Nov. 2019
return
