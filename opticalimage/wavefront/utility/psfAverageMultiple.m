function [averagePSF] = psfAverageMultiple(inputPSFs,CHECKINSFDOMAIN)
% [averagePSF] = psfAverageMultiple(inputPSFs,[CHECKINSFDOMAIN])
%
% Produces an average of passed optical point spread functions.
% Input is a 3D array of PSFs, with the averaging occuring over
% the third dimension.
%
% Setting CHECKINSFDOMAIN = 1 executes a check that you get the
% same answer by using psf2otf, averaging, and then using otf2psf.
% See comment in code as to why this might once (possibly) have been
% an interesting thing to do.
%
% 7/19/07  dhb  Wrote it.
% 9/9/11   dhb  Do it in the space domain, optional check in sf domain.
%          dhb  Take array, not cell array.

averagePSF = mean(inputPSFs,3);

% Optional check in SF domain.
%
% Note from DHB: I really have no idea why I wrote this bit,
% as it really just verifies the the Fourier transform is
% invertible.  But now that it's here, I left it.  It may
% be that I once thought it was a good idea to average the
% modulus of the otf, and started down that road without
% going all the way down it.  If we ever want to average
% the modulus, one could start with this check code.
if (nargin < 2 || isempty(CHECKINSFDOMAIN))
    CHECKINSFDOMAIN = 0;
end
    
if (CHECKINSFDOMAIN)
    nInputs = size(inputPSFs,3);
    inputOTFs = zeros(size(inputPSFs));
    for i = 1:nInputs
        inputOTFs(:,:,i) = psf2otf(inputPSFs(:,:,i));
    end
    averageOTF = mean(inputOTFs,3);
    averagePSFCheck = otf2psf(averageOTF);
    checkDiff = averagePSF(:)-averagePSFCheck(:);
    if (max(abs(checkDiff)) > 1e-8)
        error('AveragePSF space/sf domain disagreement\n');
    else
        %fprintf('AveragePSF space/sf domain agreement\n');
    end
end

