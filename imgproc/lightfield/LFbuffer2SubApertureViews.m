function [image2dArray, imgCorners] = LFbuffer2SubApertureViews(image4d)
% Create an array of images showing the sub aperture views
%
% Synopsis
%   [image2dArray, imgCorners] = LFbuffer2SubApertureViews(image4d)
%
% Given a 4d image indexed M,N,v,u,c where
%
%   MxN is size of each individual index
%   u,v are the x,y index of each individual image
%   c is the color dimension
%
% Create an output image that is the 2d array of subaperture (smaller
% images) 
%
% From the Lightfield Toolbox by XXXX
%

%% Size of the lightfield data
[M,N,V,U,C] = size(image4d);

% This is where we will copy the data
image2dArray = zeros(M*V,N*U,C);

% Each image is the corresponding (x,y) locations in the light field, taken
% from all of the different apertures and colors.  The size of each image
% is (M,N).  We return the start points of the image so you can pull them
% out of the array if you wants
imgCorners = zeros(U,V,2);
for u = 1:U
    for v = 1:V
        imgCorners(u,v,:) = [(v-1)*M+1, (u-1)*N+1];
        image2dArray( (v-1)*M+1:v*M, (u-1)*N+1:u*N, :) = squeeze(image4d(:,:,v,u,:));
    end
end

end