function rgb = ieBilinear( bayer, cfaPattern )
% Bilinear demosaic algorithm
%
%    rgb = ieBilinear( bayer, cfaPattern )
%
% This routine implements a within channel bilinear algorithm. N.B.  Matlab
% has a function called bilinear.  So, we call this one ieBilinear.
%
% Demosaicking algorithms estimate missing color information by
% interpolation of the known color information across different color
% planes.
%
% The image is mirrored so that the output image is same size as input
% image. In the previous version, the output image was smaller
%
% bayer:       The Bayer pattern image
% cfaPattern:
%
% TODO:
%  We should also implement a combined channel bilinear algorithm
%
% See also:  Demosaic
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Check parameters

if ieNotDefined('bayer'), error('bayer image required'); end
if ieNotDefined('cfaPattern'), error('cfaPattern required'); end

[r,c,nPlanes] = size(bayer);

% There are three basic configurations for a color sensor in a 2x2 block.
% The sensor can occupy a single location, a pair of locations in a common
% row/col, or a pair of locations in diagonal positions.  We use the
% appropriate linear interpolation kernel in each of these cases.

%% Manage data

% Mirror the data around the border, extending the Bayer pattern. This way
% the input and output image to have the same size. Otherwise, after
% convolution, the resulting image will be smaller since the boundary is
% removed.  We call the extended bayer pattern bayer_ex.
V = size(bayer,1);
H = size(bayer,2);
bayer_ex = [bayer(:,2,:) bayer bayer(:,(H-1),:)];
bayer_ex = [bayer_ex(2,:,:);bayer_ex;bayer_ex((V-1),:,:)];

%% Go through each of the color planes

rgb = zeros(r,c,nPlanes);
for ii=1:nPlanes
    thisPlane = bayer_ex(:,:,ii);
    l = (cfaPattern == ii);
    if ( l(1) == 1 && l(4) == 1) || (l(2) == 1 && l(3) == 1)
        % Data are in opposite corner positions
        rgb(:,:,ii) = conv2(thisPlane, [0 1/4 0; 1/4 1 1/4; 0 1/4 0], 'valid');
    else
        % Otherwise data are in every other position
        thisPlane   = conv2(thisPlane, [1/2 1 1/2] , 'valid');
        rgb(:,:,ii) = conv2(thisPlane, [1/2 1 1/2]', 'valid');
    end
end

end