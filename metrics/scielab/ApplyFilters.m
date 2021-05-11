function dstImage = ApplyFilters(srcImage, filters, dimension)
%
%     ApplyFilters(oppImg, filters, dimension)
%
% Author: X. Ding
% Purpose:
%   Filter the source image.  The routine applies different filters applied
%   to the different color planes of the source image. The parameter
%   "filters" should be a cell array. If it is not a cell and instead it is a
%   single array, it will be applied to across all color planes. The
%   incoming image "srcImage" should be in Rows x Cols x Colors format.
%
%   The parameter dimension ....?
%
% Example:
%

disp('ApplyFilters:  Obsolete');
evalin('caller', 'mfilename');

[M, N, L] = size(srcImage);

if ~iscell(filters)
    for i = 1:L;
        temp = filters;
        filters{i} = temp;
    end;
end;

for i = 1:L;

    if (dimension == 1)
        dstImage(:, :, i) = conv(srcImage(:, :, i), filters{i}, 'same');
    else
        dstImage(:, :, i) = ieConv2FFT(srcImage(:, :, i), filters{i}, 'same');
    end;

end;