function desc = computeFrame(obj,faceImg, box,pts,varargin)

opts.imSize = 256;
opts.doPooling = false;
opts.compMirrorFeat = true;
opts = vl_argparse(opts,varargin);


desc = zeros(4096,1);

bw = box(3)-box(1); bh = box(4)-box(2);
cx = box(1)+bw/2; cy = box(2)+bh/2;

ny1 = cy-1.1*bh; ny2 = cy+0.75*bh;
nx1 = cx-0.75*bw;nx2 = cx+0.75*bw;

nbox = floor([nx1 ny1 nx2 ny2]);
nbox = max([1 1 1 1; nbox]);
nbox = min([size(faceImg,2) size(faceImg,1) size(faceImg,2) size(faceImg,1);nbox]);
faceImg = faceImg(nbox(2):nbox(4),nbox(1):nbox(3),:);

if(size(faceImg,1)<size(faceImg,2))
    faceImg = imresize(faceImg,[opts.imSize NaN],'bicubic');
elseif(size(faceImg,1)>size(faceImg,2))
    faceImg = imresize(faceImg,[NaN opts.imSize],'bicubic');
else
    faceImg = imresize(faceImg,[opts.imSize opts.imSize],'bicubic');
end
faceImg = single(faceImg);

sy =  size(obj.net.normalization.averageImage,1);
sx = size(obj.net.normalization.averageImage,2);

diffY = size(faceImg,1)-sy;
diffX = size(faceImg,2)-sx;


cropx = size(faceImg,2)-sx+1;
cropy = size(faceImg,1)-sy+1;


cx = size(faceImg,2)/2;
cy = size(faceImg,1)/2;


cropDim = [1 1;...
    cropx 1;...
    1 cropy;...
    cropx cropy;...
    floor(cx-(sx/2)) floor(cy-(sy/2))];

count = 0 ;
for i=1:size(cropDim,1)

    x = cropDim(i,1);
    y = cropDim(i,2);
    faceImgCrop = faceImg(y:y+sy-1,x:x+sx-1,:);
    faceImgCrop = faceImgCrop - obj.net.normalization.averageImage;
    res   = vl_simplenn(obj.net,faceImgCrop,[],[],'disableDropout',false);
    desc = desc + squeeze(res(end-2).x);
    count = count + 1;

    faceImgCrop = faceImg(y:y+sy-1,x:x+sx-1,:);
    faceImgCrop = flipdim(faceImgCrop, 2);

    faceImgCrop = faceImgCrop - obj.net.normalization.averageImage;
    res   = vl_simplenn(obj.net,faceImgCrop,[],[],'disableDropout',false);

    desc = desc + squeeze(res(end-2).x);
    count = count + 1;
end

if(count>0)
    desc = desc./count;
end


end

