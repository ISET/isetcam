function imageOut = retinalImage(image, Cmatrices)
%
%  Compute the retinal image corresponding to an input image
%
%  imageOut = retinalImage(image, Cmatrices)
%
%	This routine implements the basic idea of taking
%	an RGB image, computing the fft in each of the color
%	images, using the calibration matrices (Cmatrix)
%	to find the amplitudes of the corresponding image.
%
%  the argument 'image' is a n by 3 matrix, with the three columns
%  corresponding to the r g b values, representing a 1-d image.
%  the 'Cmatrices' is a 9 by m matrix. Each column represents a
%  CImatrix (3x3) corresponding to one spatial frequency. Number
%  of columns correspond to the number of frequencies specified.
% 
%  The output is also a 3 column matrix, each column corresponding to
%  one cone class. 

image = image';
maxSF = size(Cmatrices, 2) - 1;
imageSize = size(image, 2);

% Image size has to be integer multiples of 2*maxSF
if ( mod(imageSize/2, maxSF)~=0 )
   error('The image is not matched to the OTF (too large).')
end

% If image size is larger than 2*maxSF, interpolate Cmatrices to match
% size of image
% if (imageSize > 2*maxSF)
%   step = 2*maxSF/imageSize;
%   Cmatrices = tableLookUp([0:step:maxSF], Cmatrices', [0:maxSF]);
%   Cmatrices = Cmatrices';
% end

%  Make an fft form of the rgb image
%
for i= 1:3
 imageFFT(i,:) = fft(image(i,:));
end

%  Convert each spatial frequency using the appropriate calibration
%  matrix
%
for f=0:maxSF   %   From DC to 32 cpd
 coneResponseFFT(:,f+1) = reshape(Cmatrices(:,f+1),3,3)*imageFFT(:,f+1);
end

% what does this part do?
% Ok, fft gives symmetrical frequency components. This is equivalent to
% the lower half of the frequencies
%
for f=maxSF+1:(2*maxSF - 1) %  From 33 cpd to 63 cpd
 coneResponseFFT(:,f+1) =  ...
   reshape(Cmatrices(:,2*(maxSF +1 ) - (f+1) ),3,3)*imageFFT(:,f+1);
end

%  Convert the spatial frequency representation back to space
for i = 1:3
 imageOut(i,:) = real(ifft(coneResponseFFT(i,:)));
end

imageOut = imageOut';












