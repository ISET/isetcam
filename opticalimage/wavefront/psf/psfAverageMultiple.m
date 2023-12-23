function [averagePSF] = psfAverageMultiple(inputPSFs, CHECKINSFDOMAIN)
% Returns an average of passed PSFs from a 3D array of PSFs
%
% Syntax:
%   [averagePSF] = psfAverageMultiple(inputPSFs, [CHECKINSFDOMAIN])
%
% Description:
%    The function produces an average of passed optical point spread
%    functions. Input is a 3D array of PSFs, with the averaging occuring
%    over the third dimension.
%
% Inputs:
%    inputPSFs       - 3D array of optical PSFs
%    CHECKINSFDOMAIN - Setting CHECKINSFDOMAIN = 1 executes a check that
%                      you get the same answer by using psf2otf, averaging, 
%                      and then using otf2psf. See comment in code as to
%                      why this might once (possibly) have been an
%                      interesting thing to do.
%
% Outputs:
%    averagePSF      - The PSF, averaged along the third dimension
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * TODO: Remove references to CHECKINSFDOMAIN since it is no longer
%      used in the function (and comment referenced in inputs section does
%      not exist)
%

% History:
%    07/19/07  dhb  Wrote it.
%    09/09/11  dhb  Do it in the space domain, optional check in sf domain.
%              dhb  Take array, not cell array.
%    11/13/17  jnm  Comments, formatting, and example
%    01/01/18  dhb  Example turning, get rid of frequency domain check.
%    01/18/18  jnm  Note, formatting update to match Wiki.

% Examples:
%{
    wvf0 = wvfCreate('calc wavelength', [400 550 700]');
    wvf0 = wvfCompute(wvf0);
    psfCell = wvfGet(wvf0, 'psf');
    [m, n] = size(psfCell{1});
    p = length(psfCell);
    psfMatrix = zeros(m, n, p);
    for kk = 1:p
        psfMatrix(:, :, kk) = psfCell{kk};
    end
    avgPsf = psfAverageMultiple(psfMatrix);

    figure;
    clf;

    subplot(2, 2, 1);
    mesh(psfCell{1});
    title('PSF 400 nm');
    zlim([0 0.02]);
    view(-37.5, 30);

    subplot(2, 2, 2);
    mesh(psfCell{2});
    title('PSF 550 nm');
    zlim([0 0.02]);
    view(-37.5, 30);

    subplot(2, 2, 3);
    mesh(psfCell{3});
    title('PSF 700 nm');
    zlim([0 0.02]);
    view(-37.5, 30);

    subplot(2, 2, 4);
    mesh(avgPsf);
    title('Average PSF');
    zlim([0 0.02]);
    view(-37.5, 30);
%}

% Not very hard
averagePSF = mean(inputPSFs, 3);

end