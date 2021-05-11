% FAULTYNEARESTNEIGHBOR: Replicates known pixels.
%
% [ BAYER_OUT ] = ...
%   FaultyNearestNeighbor( LIST, BAYER )
%
% Demosaic algorithm that estimates faulty
% pixels by replicating the color pixel
% information that is closest to the missing
% pixel.
%
% Performance:
%   ADDS : 0 / Faulty pixel
%   MULTS: 0 / Faulty pixel
%
% Memory Reqs:
%   V*H Bytes (Bayer output image)
%
% BAYER_OUT: Corrected mosaiced image.
% LIST     : Location of faulty pixels.
%            [x1 y1; x2 y2; ...]
% BAYER_IN : Faulty input image.
%
% Last Updated: 10-11-01

function [bayer_out] = FaultyNearestNeighbor(list, bayer_in)

% Get the size of the image.

V = size(bayer_in, 1);
H = size(bayer_in, 2);

% Mirror the data around the border.

bayer_ex = [bayer_in(:, 3:4, :), bayer_in, bayer_in(:, (H - 3):(H - 2), :)];
bayer_ex = [bayer_ex(3:4, :, :); bayer_ex; bayer_ex((V-3):(V - 2), :, :)];
list_ex = list + 2;

% Determine color plane of the faulty pixel.

color = bayercolor(list);

% Find nearest neighbor and replicate.

bayer_out = bayer_in;

for n = 1:size(list, 1)

    x = list_ex(n, 1);
    y = list_ex(n, 2);
    c = color(n);

    switch (c)
        case {1, 3},
            missing = bayer_ex(y+2, x, c);
        case 2,
            missing = bayer_ex(y+1, x+1, c);
    end

    bayer_out(list(n, 2), list(n, 1), c) = missing;

end
