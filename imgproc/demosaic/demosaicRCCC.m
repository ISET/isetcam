function demosaicImage = demosaicRCCC(mosaicImage)
% Convert RCCC sensor data into a monochrome image
%
% Syntax:
%   demosaicImage = demosaicRCCC(mosaicImage)
%
% Description
%   Implements an Analog.com algorithm for demosaicking an RCCC sensor into
%   a monochrome sensor.  The algorithm does not make a lot of sense to BW,
%   but it exists.  We could try an L3 variant of this, IMHO.
%
% Input
%  mosaicImage:   RCCC planar sensor image
%
% Optional key/value
%   N/A
%
% Output
%   demosaicImage - Monochrome image with interpolated values for the R
%                   pixels
%
% Suggested algorithm from:
%   https://www.analog.com/media/en/technical-documentation/application-notes/EE358.pdf
%
% Author: Zhenyi Liu, BW
%
% See also
%   Demosaic, ipCompute, cameraCompute

%% Kernel recommended by analog.com

kernel = ...
    [0  0 -1  0  0;
    0  0  2  0  0;
    -1 2  4  2 -1;
    0  0  2  0  0;
    0  0 -1  0  0]/8;

%%  Pull out components
[V,H,~] = size(mosaicImage);
c = mosaicImage(:,:,2);

% Extending the image in some way by rows and columns
mosaicImage_ex = [mosaicImage(:,2,:) mosaicImage mosaicImage(:,(H-1),:)];
mosaicImage_ex = [mosaicImage_ex(2,:,:); mosaicImage_ex; mosaicImage_ex((V-1),:,:)];

% Red pixels
r_ex = mosaicImage_ex(:,:,1);
r_mask = r_ex; r_mask(r_mask~=0)=1;

% Clear pixels
c_ex = mosaicImage_ex(:,:,2);

% Matrix of red and clear, I suppose
imageMix = r_ex + c_ex;

%% Convolution with the kernel

imageMix_conv = conv2(imageMix,kernel,'same');

% Pull out the red pixels
r_conv = imageMix_conv.*r_mask;

r_conv(1,:,:)  = [];
r_conv(:,1,:)  = [];
r_conv(end,:,:)= [];
r_conv(:,end,:)= [];

% Combined the clear with the red interpolated
demosaicImage = c + r_conv;
% ieNewGraphWin; imagesc(demosaicImage); colormap(gray)
end