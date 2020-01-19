function t = imageIncreaseImageRGBSize(im,s)
% Increase the size of an rgb-style image (r,c,w) by pixel replication.
%
%    t = imageIncreaseImageRGBSize(im,s)
%
% The parameter s is the scale factor.  If the input image is [1,1,w], the
% output image is [s, s, w].   
%  
% Example:
%    [img,p] = imageHarmonic;
%    t = imageIncreaseImageRGBSize(img,3);
%    imagesc(t); colormap(gray)
%
% Copyright ImagEval Consultants, LLC, 2003.

% We used to check to make sure that there are 3dimensions.  But this made
% problems for monochromatic images, so I took it out.
%
% if ndims(im)~=3,  error('Input must be rgb image (row x col x w)'); end

if ndims(im) == 3 
    w = size(im,3);
elseif (ndims(im) == 2)
    w = 1;
else
    error('Unexpected input matrix dimension');
end

if length(s) == 1, s = round([s,s]); end

r = size(im,1); c = size(im,2);

t = zeros(r*s(1),c*s(2),w);
for ii=1:size(im,3), t(:,:,ii) = kron(im(:,:,ii),ones(s(1),s(2))); end

end