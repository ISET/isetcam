function im_res = im_norm(im);

min_min = min(im(:));
max_max = max(im(:));
im_res = (im-min_min)/(max_max-min_min);