function out = lcc1(in) 
% Interpolation with color correction. (Not fully implemented).
%
%  out = lcc1(in) 
%
%   Not yet sure what that means.  From Ting Chen's implementation in my
%   class.  He liked it.
%
% Demosaic'ing algorithms estimate missing color information by
% interpolation of the known color information across different color
% planes.
%
% Copyright ImagEval Consultants, LLC, 2005.

% TODO:
% This implementation requires the color arrangement below.
% This is one of our colorOrder types.  But it should work for any of the
% RGB varieties, really., So, fix that. 
%
% The code is completely unreadable at present.
%
% Also, make the code readable.  And add the references to here.
% Finally, this code seems to assume an 8bit image.  Fix that.
%
% Perhaps this can't be included in ISET because the reference is:
% Reference:
%   Hamilton, Jr. et.al.,     
%   "Adaptive color plane interpolation in single sensor color electronic camera"    
%   U.S.Patent 5,629,734
%   How do we find out whether this method should (or should not) be
%   included in this simulator?
%
%  ------------------> x 
%  |  G R G R ... 
%  |  B G B G ... 
%  |  G R G R ... 
%  |  B G B G ... 
%  |  . . . . . 
%  |  . . . .  . 
%  |  . . . .   . 
%  | 
%  V y 
% 
% 
% Input : 
% 
% in : original image matrix (mxnx3), m&n even  ... I am not sure whether
% the input data are supposed to be between 0 and 1 or it can be anything.
% 
% Output : 
% 
% out : color interpolated image 
% 
% 

% error('lcc1 not yet working.');

m = size(in,1); n = size(in,2); 
inR = in(:,:,1); inG = in(:,:,2); inB = in(:,:,3); 
out = in; 
outR = inR; outG = inG; outB = inB; 

% G channel 
for i=4:2:m-2, 
    for j=3:2:n-3,
        
        delta_H = abs(inB(i,j-2)+inB(i,j+2)-2*inB(i,j)) + abs(inG(i,j-1)-inG(i,j+1)); 
        delta_V = abs(inB(i-2,j)+inB(i+2,j)-2*inB(i,j)) + abs(inG(i-1,j)-inG(i+1,j));
        
        if delta_H < delta_V, 
           outG(i,j) = 1/2*(inG(i,j-1)+inG(i,j+1))+ 1/4*(2*inB(i,j)-inB(i,j-2)-inB(i,j+2)); 
        elseif delta_H > delta_V, 
           outG(i,j) = 1/2*(inG(i-1,j)+inG(i+1,j))+1/4*(2*inB(i,j)-inB(i-2,j)-inB(i+2,j)); 
        else 
           outG(i,j) = 1/4*(inG(i,j-1)+inG(i,j+1)+inG(i-1,j)+inG(i+1,j))+1/8*(4*inB(i,j)-inB(i,j-2)-inB(i,j+2)-inB(i-2,j)-inB(i+2,j)); 
        end 
        
    end 
end 

for i=3:2:m-3, 
    for j=4:2:n-2, 
        delta_H = abs(inR(i,j-2)+inR(i,j+2)-2*inR(i,j))+abs(inG(i,j-1)-inG(i,j+1)); 
        delta_V = abs(inR(i-2,j)+inR(i+2,j)-2*inR(i,j))+abs(inG(i-1,j)-inG(i+1,j)); 
        if delta_H < delta_V, 
           outG(i,j) = 1/2*(inG(i,j-1)+inG(i,j+1))+1/4*(2*inR(i,j)-inR(i,j-2)-inR(i,j+2)); 
        elseif delta_H > delta_V, 
           outG(i,j) = 1/2*(inG(i-1,j)+inG(i+1,j))+1/4*(2*inR(i,j)-inR(i-2,j)-inR(i+2,j)); 
        else 
           outG(i,j) = 1/4*(inG(i,j-1)+inG(i,j+1)+inG(i-1,j)+inG(i+1,j))+1/8*(4*inR(i,j)-inR(i,j-2)-inR(i,j+2)-inR(i-2,j)-inR(i+2,j)); 
        end 
    end 
end 

outG = ieClip(outG,0,255);

% R channel 
for i=1:2:m-1, 
    outR(i,3:2:n-1) = 1/2*(inR(i,2:2:n-2)+inR(i,4:2:n))+1/4*(2*outG(i,3:2:n-1)-outG(i,2:2:n-2)-outG(i,4:2:n)); 
end 

for i=2:2:m-2, 
    outR(i,2:2:n) = 1/2*(inR(i-1,2:2:n)+inR(i+1,2:2:n))+1/4*(2*outG(i,2:2:n)-outG(i-1,2:2:n)-outG(i+1,2:2:n)); 
end 

for i=2:2:m-2, 
    for j=3:2:n-1, 
        delta_P = abs(inR(i-1,j+1)-inR(i+1,j-1))+abs(2*outG(i,j)-outG(i-1,j+1)-outG(i+1,j-1)); 
        delta_N = abs(inR(i-1,j-1)-inR(i+1,j+1))+abs(2*outG(i,j)-outG(i-1,j-1)-outG(i+1,j+1)); 
        if delta_N < delta_P, 
           outR(i,j) = 1/2*(inR(i-1,j-1)+inR(i+1,j+1))+1/2*(2*outG(i,j)-outG(i-1,j-1)-outG(i+1,j+1)); 
        elseif delta_N > delta_P, 
           outR(i,j) = 1/2*(inR(i-1,j+1)+inR(i+1,j-1))+1/2*(2*outG(i,j)-outG(i-1,j+1)-outG(i+1,j-1)); 
        else 
           outR(i,j) = 1/4*(inR(i-1,j-1)+inR(i-1,j+1)+inR(i+1,j-1)+inR(i+1,j+1))+1/4*(4*outG(i,j)-outG(i-1,j-1)-outG(i-1,j+1)-outG(i+1,j-1)-outG(i+1,j+1)); 
        end 
     end 
end 

outR = ieClip(outR,0,255);


% B channel 
for i=2:2:m, 
    outB(i,2:2:n-2) = 1/2*(inB(i,1:2:n-3)+inB(i,3:2:n-1))+1/4*(2*outG(i,2:2:n-2)-outG(i,1:2:n-3)-outG(i,3:2:n-1)); 
end 

for i=3:2:m-1, 
    outB(i,1:2:n-1) =  1/2*(inB(i-1,1:2:n-1)+inB(i+1,1:2:n-1))+1/4*(2*outG(i,1:2:n-1)-outG(i-1,1:2:n-1)-outG(i+1,1:2:n-1)); 
end 

for i=3:2:m-1, 
    for j=2:2:n-2, 
        delta_P = abs(inB(i-1,j+1)-inB(i+1,j-1))+abs(2*outG(i,j)-outG(i-1,j+1)-outG(i+1,j-1)); 
        delta_N = abs(inB(i-1,j-1)-inB(i+1,j+1))+abs(2*outG(i,j)-outG(i-1,j-1)-outG(i+1,j+1)); 
        if delta_N < delta_P, 
            outB(i,j) = 1/2*(inB(i-1,j-1)+inB(i+1,j+1))+1/2*(2*outG(i,j)-outG(i-1,j-1)-outG(i+1,j+1)); 
        elseif delta_N > delta_P, 
            outB(i,j) = 1/2*(inB(i-1,j+1)+inB(i+1,j-1))+1/2*(2*outG(i,j)-outG(i-1,j+1)-outG(i+1,j-1)); 
        else 
            outB(i,j) = 1/4*(inB(i-1,j-1)+inB(i-1,j+1)+inB(i+1,j-1)+inB(i+1,j+1))+1/4*(4*outG(i,j)-outG(i-1,j-1)-outG(i-1,j+1)-outG(i+1,j-1)-outG(i+1,j+1)); 
        end 
     end 
end 

outB = ieClip(outB,0,255);

out(:,:,1) = outR; 
out(:,:,2) = outG; 
out(:,:,3) = outB; 
  
return;