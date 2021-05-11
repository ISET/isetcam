function [hc, blur] = hcBlur(hc, sd)
% Blur each plane in a hypercube with conv2
%
%   hc = hcBlur(hc,sd)
%
% The spatial blur is a gaussian created by fspecial with a size of sd.
%
% (c) Imageval 2012

if ieNotDefined('hc'), error('Hypercube data required.'); end
if ieNotDefined('sd'), sd = 3; end

% blur has unit area and thus preserves the mean level.
blur = fspecial('gaussian', [sd, sd]);
nWave = size(hc, 3);
h = waitbar(0, 'Blurring');
for ii = 1:nWave
    waitbar(ii/nWave, h);

    % Forces hypercube data to be doubles
    hc(:, :, ii) = conv2(double(hc(:, :, ii)), blur, 'same');
end
close(h);

return