function res = final_touch(im)

% res = final_touch(im)
% % we find a trick can often make the result "open up" a bit, the trick 
% % being adding 15% of a histogram equalized layer to the result. 

ht = size(im, 1);
wth = size(im, 2);
nch = size(im, 3);
im_int = reshape(im, [ht*wth nch]);
im_int = histeq(real(im_int), 255);
im_int = reshape(im_int, [ht wth nch]);
res = im + 0.15*im_int;