function [r,g,b] = jpgread(filename)
%JPGREAD Read a JPEG file from disk.
%      [R,G,B] = jpgread('filename') reads the specified file
%      and returns the Red, Green, and Blue intensity matrices.
%
%      Use IMSHOW to display the image, or RGB2IND to convert
%      to an indexed image.
%      Note: IMSHOW and RGB2IND are functions in the Image
%      Processing Toolbox.

[r,g,b] = jpegread(filename);
