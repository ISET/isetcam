function lsf = PsfToLsf(psf,varargin)
%PSFTOLSF  Convert a line spread function to a point spread function
%    lsf = PSFTOLSF(psf,varargin)
%
%    This works by convolving a horizontal line with a psf and returning the
%    vertical slice through the center.  The spatial support of the lsf is
%    equal to the spatial support of the vertical slice through the passed
%    psf.  The passed psf should be square.
%
%    The returned lsf is normalized to have a peak amplitude of 1.
%
%    See also LSFTOPSF.

% Get passed row and column dimension.
[m,n] = size(psf);
if (m ~= n)
    error('Passed psf should have square support.')
end
centerPosition = floor(m/2)+1;

% Create a 2D image of a line across the center row.
aLine2D = zeros(size(psf));
aLine2D(centerPosition,:) = 1;

% Convolve with the psf
aLineConvolved = conv2(aLine2D,psf,'same');

% Extract the center column and normalize
lsf = aLineConvolved(:,centerPosition);
lsf = lsf/max(lsf(:));

end