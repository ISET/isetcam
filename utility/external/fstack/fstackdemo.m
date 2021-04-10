clear, clc, close all

% Load image data:
load imdata.mat

% Show images:
showimages(imlist, focus);
close(gcf)
% Compute extended depth-of-field image with default values 
% using the selective all-in-focus algorithm [1]:
im = fstack(imlist, 'focus', focus);

%Display result
imshow(im), title('All-in-focus image')


% [1] Pertuz et. al. "Generation of all-in-focus images by
%   noise-robust selective fusion of limited depth-of-field
%   images" IEEE Trans. Image Process, 22(3):1242 - 1251, 2013.
