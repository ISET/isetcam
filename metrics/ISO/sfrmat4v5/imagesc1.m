function [h]=imagesc1(dat,h)

[nlin,noix,nc]=size(dat);
if nargin<2
    h=imagesc(dat); axis image
else
    figure(h);
    h=imagesc(dat); axis image
end
if nc==1
    colormap('gray(256)');
end