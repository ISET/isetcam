function imgRGB = Pocs(bayer_in, bPattern,iterN )
% Demosaicing Using Alternating Projections
%
%   imgRGB = Pocs(bayer,bPattern,iterN) 
%
% bayer_in is a Bayer pattern (must be 'rggb').  This routine applies the
% POCS algorithm (Projection onto convex sets).
%
% For details, please refer to the paper:
%   Color plane interpolation using alternating projections 
%	Gunturk, B.K.; Altunbasak, Y.; Mersereau, R.M. 
%	Image Processing, IEEE Transactions on , Volume: 11 Issue: 9 , Sept 2002 
%	Page(s): 997 -1013
%
% Source code derived from the distribution at
%
%  Bahadir K. Gunturk
%  School of Electrical and Computer Engineering
%  Georgia Institute of Technology
%  Email: bahadir@ece.gatech.edu
%  URL  : http://users.ece.gatech.edu/bahadir
%
% ISET implementation by Stephanie Kwan and Brian Wandell
%

if ieNotDefined('bayer_in'), error('Bayer rgb data required.'); end
if ieNotDefined('bPattern'), error('Bayer pattern info required.'); end
if ieNotDefined('iterN'), iterN = 10; end

% mosaicConverter transforms non-rggb into rggb.  This is the only format
% that works for the remaining part of the code.
bayer_in = mosaicConverter(bayer_in, bPattern, 'rggb');

%%%%% Get the color channels
 R = bayer_in(:,:,1); %figure; imshow(R);
 G = bayer_in(:,:,2); %figure; imshow(G);
 B = bayer_in(:,:,3); %figure; imshow(B);

 %%%%% Size of the image
[height,width] = size(G);

%%%%% Downsample according to the BAYER pattern
%
% R G
% G B
%
Rd = R(1:2:end-1,1:2:end-1);
Bd = B(2:2:end, 2:2:end);

%%%%% COMMENTS
% The implementation can be easily modified to have G sample at the upper left corner. (Does not affect much...)

% G channel is sampled and interpolated below 
% G channel is sampled and interpolated with the ``edge-sensitive interpolator''
Gdu = G;
G_bilinear = G;
for j=4:2:height-4, % Interpolate G over B samples (excluding borders)
   for i=4:2:width-4,
      
      %Gdu(j,i) = ( Gdu(j-1,i)+Gdu(j+1,i)+Gdu(j,i-1)+Gdu(j+1,i+1) )/4;
      G_bilinear(j,i) = ( Gdu(j-1,i)+Gdu(j+1,i)+Gdu(j,i-1)+Gdu(j,i+1) )/4;

      deltaH = abs( Gdu(j,i-1)-Gdu(j,i+1) ) + abs( 2*B(j,i)-B(j,i-2)-B(j,i+2) );
		deltaV = abs( Gdu(j-1,i)-Gdu(j+1,i) ) + abs( 2*B(j,i)-B(j-2,i)-B(j+2,i) );
      if deltaV>deltaH,
         Gdu(j,i) = ( Gdu(j,i-1)+Gdu(j,i+1) )/2 + ( 2*B(j,i)-B(j,i-2)-B(j,i+2) )/4;
      elseif deltaH>deltaV,
         Gdu(j,i) = ( Gdu(j-1,i)+Gdu(j+1,i) )/2 + ( 2*B(j,i)-B(j-2,i)-B(j+2,i) )/4;
      else
         Gdu(j,i) = (Gdu(j-1,i-1)+Gdu(j+1,i+1)+Gdu(j-1,i+1)+Gdu(j+1,i-1))/4 + ( 2*B(j,i)-B(j,i-2)-B(j,i+2) + 2*B(j,i)-B(j-2,i)-B(j+2,i))/8;
      end;
      
   end;
end;

for j=3:2:height-3, % Interpolate G over R samples (excluding borders)
   for i=3:2:width-3,
      
      %Gdu(j,i) = ( Gdu(j-1,i)+Gdu(j+1,i)+Gdu(j,i-1)+Gdu(j+1,i+1) )/4;
      G_bilinear(j,i) = ( Gdu(j-1,i)+Gdu(j+1,i)+Gdu(j,i-1)+Gdu(j+1,i+1) )/4;
      
      deltaH = abs( Gdu(j,i-1)-Gdu(j,i+1) ) + abs( 2*R(j,i)-R(j,i-2)-R(j,i+2) );
		deltaV = abs( Gdu(j-1,i)-Gdu(j+1,i) ) + abs( 2*R(j,i)-R(j-2,i)-R(j+2,i) );
      if deltaV>deltaH,
         Gdu(j,i) = ( Gdu(j,i-1)+Gdu(j,i+1) )/2 + ( 2*R(j,i)-R(j,i-2)-R(j,i+2) )/4;
      elseif deltaH>deltaV,
         Gdu(j,i) = ( Gdu(j-1,i)+Gdu(j+1,i) )/2 + ( 2*R(j,i)-R(j-2,i)-R(j+2,i) )/4;
      else
         Gdu(j,i) = (Gdu(j-1,i-1)+Gdu(j+1,i+1)+Gdu(j-1,i+1)+Gdu(j+1,i-1))/4 + ( 2*R(j,i)-R(j,i-2)-R(j,i+2) + 2*R(j,i)-R(j-2,i)-R(j+2,i))/8;
      end;

   end;
end;

GduTemp = Gdu;

%%%%% Bilinear interpolation
Rd2 = interp2(Rd,'linear');
Bd2 = interp2(Bd,'linear');

%%%%% Make sure that they have the same sizes...
Rdu = R; Rdu(1:height-1, 1:width-1) = Rd2; %figure; imshow(uint8(Rdu)); 
Bdu = B; Bdu(2:height, 2:width) = Bd2; %figure; imshow(uint8(Bdu));

%%%%% Output bilinearly interpolated image
 out_bilinear(:,:,1)=Rdu;
 out_bilinear(:,:,2)=G_bilinear;
 out_bilinear(:,:,3)=Bdu;
%  out_bilinear = uint8(out_bilinear);

%%%%% COMMENTS
% At this point Rdu and Bdu are bilinearly interpolated Red and Blue channels,
%	and Gdu is the interpolated Green channel using the edge-sensitive algorithm.

%%%%% Filters that will be used in subband decomposition 
h0 = [1 2 1]/4;
h1 = [1 -2 1]/4;
g0 = [-1 2 6 2 -1]/8;
g1 = [1 2 -6 2 1]/8;

%%%%% COMMENTS
% To try different wavelet filters from the MATLAB wavelet toolbox:
%[h0,h1,g0,g1] = wfilters(wname);
%
% To decompose the signal for another level, you can update the filters as follows
hh0 = dyadup(h0,2);
hh1 = dyadup(h1,2);
gg0 = dyadup(g0,2);
gg1 = dyadup(g1,2);


%%%%% Update Green channel
% Get the samples of Green channel on Red and Blue samples to form two small images. 
% 
Gd_R = Gdu(1:2:end - 1, 1:2:end - 1);
Gd_B = Gdu(2:2:end, 1:2:end);
%
% Update these small Green images using observed Red and Blue samples
[CA_Rr,CH_Rr,CV_Rr,CD_Rr] = rdwt2(Rd,h0,h1);
[CA_Gr,CH_Gr,CV_Gr,CD_Gr] = rdwt2(Gd_R,h0,h1); 
[CA_Bb,CH_Bb,CV_Bb,CD_Bb] = rdwt2(Bd,h0,h1);
[CA_Gb,CH_Gb,CV_Gb,CD_Gb] = rdwt2(Gd_B,h0,h1); 
%
Gd_R = ridwt2(CA_Gr, CH_Rr, CV_Rr, CD_Rr, g0,g1);
Gd_B = ridwt2(CA_Gb, CH_Bb, CV_Bb, CD_Bb, g0,g1);
%
Gdu(1:2:height,1:2:width)=Gd_R;  
Gdu(2:2:height,2:2:width)=Gd_B;
%

%%%%% Alternating projections algorithm starts here

for iter=1:iterN
    
   %%%%% Decompose into subbands 
   [CA_Rdu,CH_Rdu,CV_Rdu,CD_Rdu] = rdwt2(Rdu,h0,h1);
   [CA_Gdu,CH_Gdu,CV_Gdu,CD_Gdu] = rdwt2(Gdu,h0,h1);
   [CA_Bdu,CH_Bdu,CV_Bdu,CD_Bdu] = rdwt2(Bdu,h0,h1);
   
   %%%%% Second-level decomposition 
   % To decompose the signal further, set the following to 1
   % DO NOT FORGET TO REMOVE THE COMMENT-OUTS ABOVE TO GET hh0, hh1, gg0, gg1
   DoSecond = 1;
   if DoSecond == 1,
      [CAA_Rdu, CHH_Rdu, CVV_Rdu, CDD_Rdu] = rdwt2(CA_Rdu,hh0,hh1);
      [CAA_Gdu, CHH_Gdu, CVV_Gdu, CDD_Gdu] = rdwt2(CA_Gdu,hh0,hh1);
      [CAA_Bdu, CHH_Bdu, CVV_Bdu, CDD_Bdu] = rdwt2(CA_Bdu,hh0,hh1);
      %
      CA_Rdu = ridwt2(CAA_Rdu, CHH_Gdu, CVV_Gdu, CDD_Gdu, gg0,gg1);
      CA_Gdu = ridwt2(CAA_Gdu, CHH_Gdu, CVV_Gdu, CDD_Gdu, gg0,gg1);
      CA_Bdu = ridwt2(CAA_Bdu, CHH_Gdu, CVV_Gdu, CDD_Gdu, gg0,gg1);
   end;
   %%%%% End of Second-level decomposition
   
   %%%%% DETAIL PROJECTION
   %%%%% Replace R and B high-freq channels with G high-freq channels
   % This implementation corresponds to setting the threshold to zero. (See the paper.)
   x_replace(:,:,1) = ridwt2(CA_Rdu, CH_Gdu, CV_Gdu, CD_Gdu, g0, g1);
   x_replace(:,:,2) = ridwt2(CA_Gdu, CH_Gdu, CV_Gdu, CD_Gdu, g0, g1);
   x_replace(:,:,3) = ridwt2(CA_Bdu, CH_Gdu, CV_Gdu, CD_Gdu, g0, g1);
   
   %%%%% OBSERVATION PROJECTION
   %%%%% Make sure that R and B channels obey the data 
   Rdu = x_replace(:,:,1);
   Rdu(1:2:height,1:2:width) = Rd2(1:2:height,1:2:width); 
   %
   Bdu = x_replace(:,:,3);
   Bdu(2:2:height,2:2:width) = Bd2(1:2:height,1:2:width); 
   
end;

%%%%% COMMENTS
% Convolution of the channels with the filters may create artifacts along the borders. 
% Here, I replace the borders with the bilinear and edge-sensitive data..
temp = double(out_bilinear(:,:,1));
temp(4:height-4,4:width-4) = Rdu(4:height-4,4:width-4);
Rdu = temp;
temp = GduTemp;
temp(4:height-4,4:width-4) = Gdu(4:height-4,4:width-4);
Gdu = temp;
temp = double(out_bilinear(:,:,3));
temp(4:height-4,4:width-4) = Bdu(4:height-4,4:width-4);
Bdu = temp;

%%%%% Output the image...
% now put the R abd B in the correct locations
x_constrain(:,:,1) = Rdu;
x_constrain(:,:,2) = Gdu ;
x_constrain(:,:,3) = Bdu;

x_constrain (x_constrain < 0) = 0;
imgRGB = x_constrain ;

return;

%----------------------------------------
function y = dyadup(x,varargin)
%DYADUP Dyadic upsampling.
%   DYADUP implements a simple zero-padding scheme very
%   useful in the wavelet reconstruction algorithm.
%
%   Y = DYADUP(X,EVENODD), where X is a vector, returns
%   an extended copy of vector X obtained by inserting zeros.
%   Whether the zeros are inserted as even- or odd-indexed
%   elements of Y depends on the value of positive integer
%   EVENODD:
%   If EVENODD is even, then Y(2k-1) = X(k), Y(2k) = 0.
%   If EVENODD is odd,  then Y(2k-1) = 0   , Y(2k) = X(k).
%
%   Y = DYADUP(X) is equivalent to Y = DYADUP(X,1)
%
%   Y = DYADUP(X,EVENODD,'type') or
%   Y = DYADUP(X,'type',EVENODD) where X is a matrix,
%   return extended copies of X obtained by inserting columns 
%   of zeros (or rows or both) if 'type' = 'c' (or 'r' or 'm'
%   respectively), according to the parameter EVENODD, which
%   is as above.
%
%   Y = DYADUP(X) is equivalent to
%   Y = DYADUP(X,1,'c')
%   Y = DYADUP(X,'type')  is equivalent to
%   Y = DYADUP(X,1,'type')
%   Y = DYADUP(X,EVENODD) is equivalent to
%   Y = DYADUP(X,EVENODD,'c') 
%
%                  |1 2|                     |0 1 0 2 0|
%   Examples : X = |3 4|  ,  DYADUP(X,'c') = |0 3 0 4 0|
%
%                     |1 2|                      |1 0 2|
%   DYADUP(X,'r',0) = |0 0|  , DYADUP(X,'m',0) = |0 0 0|
%                     |3 4|                      |3 0 4|
%
%   See also DYADDOWN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 19-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.1 $

% Internal options.
%-----------------
% Y = DYADUP(X,EVENODD,ARG) returns a vector with even length.
% Y = DYADUP([1 2 3],1,ARG) ==> [0 1 0 2 0 3]
% Y = DYADUP([1 2 3],0,ARG) ==> [1 0 2 0 3 0]
% 
% Y = DYADUP(X,EVENODD,TYPE,ARG) ... for a matrix
%--------------------------------------------------------------

% Check arguments.
nbIn = nargin;
if nbIn < 1
  error('Not enough input arguments.');
elseif nbIn > 4
  error('Too many input arguments.');
end

% Special case.
if isempty(x) , y = []; return; end

def_evenodd = 1;
nbInVar = nargin-1;
[r,c]   = size(x);
evenLEN = 0;
if min(r,c)<=1
    dim = 1;
    switch nbInVar
        case {1,3}
           if ischar(varargin{1}) , dim = 2; end
        case 2
           if ischar(varargin{1}) || ischar(varargin{2}) , dim = 2; end
    end
else
    dim = 2;
end
if dim==1
    switch nbInVar
        case 0
            p = def_evenodd;
        case {1,2}
            p = varargin{1};
            if nbInVar==2 , evenLEN = 1; end
        otherwise
            errargt(mfilename,'too many arguments','msg'); error('*');
    end
    rem2    = rem(p,2);
    if evenLEN , addLEN = 0; 
    else addLEN = 2*rem2-1; 
    end
    l = 2*length(x)+addLEN;
    y = zeros(1,l);
    y(1+rem2:2:l) = x;
    if r>1, y = y'; end
else
    switch nbInVar
        case 0 , p = def_evenodd; o = 'c';
        case 1
            if ischar(varargin{1})
                p = def_evenodd; o = lower(varargin{1}(1));
            else
                p = varargin{1}; o = 'c';
            end
        otherwise
            if ischar(varargin{1})
                p = varargin{2}; o = lower(varargin{1}(1));
            else
                p = varargin{1}; o = lower(varargin{2}(1));
            end
    end
    if nbInVar==3 , evenLEN = 1; end
    rem2 = rem(p,2);
    if evenLEN , addLEN = 0; 
    else addLEN = 2*rem2-1; 
    end
    switch o
        case 'c'
            nc = 2*c+addLEN;
            y  = zeros(r,nc);
            y(:,1+rem2:2:nc) = x;

        case 'r'
            nr = 2*r+addLEN;
            y  = zeros(nr,c);
            y(1+rem2:2:nr,:) = x;

        case 'm'
            nc = 2*c+addLEN;
            nr = 2*r+addLEN;
            y  = zeros(nr,nc);
            y(1+rem2:2:nr,1+rem2:2:nc) = x;

        otherwise
            error('Invalid argument value.');
    end
end

%------------------
function [a,h,v,d] = rdwt2(x,h0,h1)
%
% RDWT2 -> 2D Redundant Discrete Wavelet Transform
%		RDWT2 decomposes an image into its subbands. 
%
%		[a,h,v,d] = rdwt2(x,h0,h1) 
%		x 			-> Input image 
%		h0,h1 	-> Low-pass and high-pass filters for subband decomposition
%		a,h,v,d 	-> approximation, horizontal detail, vertical detail, and diagonal detail subbands
%

[height,width] = size(x);
t0 = ceil(length(h0)/2);

% h0,h1,g0,g1 are row vectors...
z = conv2(x,h0);
a = conv2(z,h0'); a = a(t0:t0+height-1,t0:t0+width-1);
h = conv2(z,h1'); h = h(t0:t0+height-1,t0:t0+width-1);

z = conv2(x,h1);
v = conv2(z,h0'); v = v(t0:t0+height-1,t0:t0+width-1);
d = conv2(z,h1'); d = d(t0:t0+height-1,t0:t0+width-1);

return;

%-------------------
function x = ridwt2(a,h,v,d,g0,g1)
%
% RIDWT2 -> 2D Redundant Inverse Discrete Wavelet Transform
%		RIDWT2 reconstructs the image from its subbands. 
%
%		x = ridwt2(a,h,v,d,g0,g1) 
%		x 			-> Reconstructed image 
%		a,h,v,d 	-> approximation, horizontal detail, vertical detail, and diagonal detail subbands
%		g0,g1 	-> Synthesizing filters
%

[height,width] = size(a);
t0 = ceil(length(g0)/2);

x = conv2(g0,g0,a)+ ... % Approximation.
    conv2(g1,g0,h)+ ... % Horizontal Detail.
    conv2(g0,g1,v)+ ... % Vertical Detail.
    conv2(g1,g1,d);     % Diagonal Detail.

x = x(t0:t0+height-1,t0:t0+width-1);


return;
