function lsf = psf2lsf(psf,varargin)
% Derive the line spread from the pointspread
%
% Synopsis
%  lsf = psf2lsf(psf,varargin)
%
% Brief
%  Compute a line spread from a point spread.
%
% Input
%   psf - Pointspread function.  3rd dimension is wavelength
%
% Optional key/val
%    'direction' - {'horizontal','vertical'} default is horizontal
%
% Output
%    lsf - line spread function.  The columns are the lsf for each
%       wavelength.
%
% Description:
%   We compute the FFT2 of the PSF.  Then we use the first row of the FFT
%   as a one-dimensional measure, and compute the IFFT.  This is the
%   linespread in one direction.
%
%   If the PSF is circularly symmetric, the 1D LSF is all you need.  If the
%   PSF is not circularly symmetric, you might want to choose a different
%   line though the FFT2 of the PSF.  That code, which may require some
%   interpolation in the transform domain, is waiting to be written.
%
% See also
%    psf2otf

% Examples:
%{
   % Gaussian broad horizontal and narrow vertical
   psf = gauss2(8,128,32,128);
   imagesc(psf); axis image

   % Passes fewer frequencies because the broad direction
   lsf = psf2lsf(psf);
   ieNewGraphWin; plot(lsf)

   % More frequencies because the narrow direction
   lsf = psf2lsf(psf,'direction','vertical');
   ieNewGraphWin; plot(lsf)
%}
%{
   % Loops through wavelengths
   psf = randn(128,128,6);
   lsf = psf2lsf(psf);
   ieNewGraphWin; surf(lsf)
%}

%%
p = inputParser;
p.addRequired('psf',@isnumeric);
p.addParameter('direction','horizontal',@(x)(ismember(x,{'horizontal','vertical'})));
p.parse(psf,varargin{:});

direction = p.Results.direction;

%%
nWave = size(psf,3);

if nWave > 1
    lsf = zeros(size(psf,2),nWave);
    
    % Loop over all wavelengths
    for ii = 1:nWave
        thisPSF   = psf(:,:,ii);
        thisPSFF  = fft2(thisPSF);
        switch direction
            case 'horizontal'
                lsf(:,ii) = ifft(thisPSFF(:,1));
            case 'vertical'
                lsf(:,ii) = ifft(thisPSFF(1,:));
        end
    end
else
    thisPSF = psf;
    thisPSFF = fft2(thisPSF);
    switch direction
        case 'horizontal'
            lsf = ifft(thisPSFF(:,1));
        case 'vertical'
            lsf = ifft(thisPSFF(1,:));
    end
end

end
