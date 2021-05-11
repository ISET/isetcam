function [bayer_out] = FaultyBilinear(list, bayer_in)
% FAULTYBILINEAR: 2D linear interpolation.
%
% [ BAYER_OUT ] = FaultyBilinear( LIST, BAYER )
%
% Replace the faulty pixels by replicating the color pixel information that
% is closest to the missing pixel.
%
% Routine needs to be checked thoroughly
%
%------------------------------------------------
% BAYER_OUT: Corrected mosaiced image.
% LIST     : Location of faulty pixels.
%            [x1 y1; x2 y2; ...]
% BAYER_IN : Faulty input image.
%
% Copyright ImagEval Consultants, LLC, 2005.


% TODO:  Check arguments here
%

% Get the size of the image.
V = size(bayer_in, 1);
H = size(bayer_in, 2);

% Mirror the data around the border.
bayer_ex = [bayer_in(:, 3:4, :), bayer_in, bayer_in(:, (H - 3):(H - 2), :)];
bayer_ex = [bayer_ex(3:4, :, :); bayer_ex; bayer_ex((V-3):(V - 2), :, :)];
list_ex = list + 2;

% Determine color plane of faulty pixel.
color    = bayercolor( list );

% Interpolate missing information.

bayer_out = bayer_in;

for n = 1:size(list, 1)

    x = list_ex(n, 1);
    y = list_ex(n, 2);
    c = color(n);

    switch (c)
        case {1, 3},
            missing = 0.25 * ...
                (bayer_ex(y - 2, x, c) + bayer_ex(y, x - 2, c) + ...
                bayer_ex(y + 2, x, c) + bayer_ex(y, x + 2, c));
        case 2,
            missing = 0.25 * ...
                (bayer_ex(y - 1, x - 1, c) + bayer_ex(y - 1, x + 1, c) + ...
                bayer_ex(y + 1, x - 1, c) + bayer_ex(y + 1, x + 1, c));
    end

    bayer_out(list(n, 2), list(n, 1), c) = missing;

end

return;
