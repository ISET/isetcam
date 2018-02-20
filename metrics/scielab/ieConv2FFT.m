function z=ieConv2FFT(A, B, method)
%Obsolete: Compute 2d-convolution by FFT => IFFT on 2D data
%
%   z = ieConv2FFT(A, B, method)
%
%  A, B are the input 2D matrices. Method can be either 'same' or none [].
%
% Should probably not be called.  This routine pads both A and B with zeros
% to sum of their sizes and then applies the fft2 to them both.  The
% zero-padding is kind of special and can screw a lot of stuff up.
%

% evalin('caller','mfilename')
% disp('Calling ieConv2FFT')

[M, N] = size(A);
[P, Q] = size(B);

% The arrays are padded with zeros to become the same size. It's not just
% that the smaller one is padded up to the bigger one.  They are both
% padded with zeros, no matter what, to the sum of the two sizes.  This is
% not good.
if isempty(method)
    z = real(ifft2(fft2(A, M+P-1, N+Q-1).*fft2(B, M + P - 1, N + Q - 1)));
else
    %'same', can reduce some computation
    dx=floor(Q/2);
    dy=floor(P/2);
    z=real(ifft2(fft2(A, M+P-1, N+Q-1).*fft2(B, M + P - 1, N + Q - 1)));
    z=z(dy+1:dy+M, dx+1:dx+N);
end;

return;