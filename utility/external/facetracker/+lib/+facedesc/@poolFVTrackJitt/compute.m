%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function desc = compute(obj, video, track_data, varargin)

     

    

    desc = single(zeros(obj.encoder.get_output_dim,1));
    
    for i=1:numel(track_data)
   
        frame_data = track_data(i);
        img = video.getFrame(frame_data.frame);
        
        cx = frame_data.rect(1) + (frame_data.rect(3)-frame_data.rect(1))/2;
        cy = frame_data.rect(2) + (frame_data.rect(4)-frame_data.rect(2))/2;
        scale = ((frame_data.rect(3)-frame_data.rect(1)) + (frame_data.rect(4)-frame_data.rect(2)))/4;
        scale = scale+0.15*scale;
        rect = [cx-scale cx+scale cy-scale cy+scale];
        rect = floor(rect);
        rect = max([1 1 1 1],rect);
        rect = min([size(img,2) size(img,2) size(img,1) size(img,1)],rect);
        
        faceImg = img(rect(3):rect(4),rect(1):rect(2),:);
        faceImg = imresize(faceImg,[150 nan],'bicubic');
 
        faceImg = im2single(faceImg);
        
        [tfeats tframes] = obj.featextr.compute(faceImg);
        desc = desc+ obj.encoder.encode(tfeats);

        faceImg = flipdim(faceImg, 2);
        
        [tfeats tframes] = obj.featextr.compute(faceImg);
        
        desc = desc+ obj.encoder.encode(tfeats);
        
    end
    
    desc = sign(desc) .* sqrt(abs(desc));
    code_norm = norm(desc, 2);
    desc = desc * (1 / max(code_norm, eps));
    
    
end
