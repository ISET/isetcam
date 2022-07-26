%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function desc = compute(obj, video, track_data, varargin)

     

    data_sel_idx = floor(linspace(1,numel(track_data),10));
    track_data = track_data(data_sel_idx);
    selIdx = [1 3 2 4];

    desc = single(zeros(4096,1));
    
     for j=1:numel(track_data)
        img = video.getFrame(track_data(j).frame);
        box = track_data(j).rect;
        w = box(3) - box(1); h = box(4) - box(2);
        w1 = w*0.2; h1 = h*0.2;
        w2 = w*0.2; h2 = h*0.2;
        box = box + [-w1 -h1 w2 h2]';
        desc = desc + obj.computeFrame(img,box, [],'doPooling', true, 'compMirrorFeat', true,'imSize',256);
        desc = desc + obj.computeFrame(img,box, [],'doPooling', true, 'compMirrorFeat', true,'imSize',384);
        desc = desc + obj.computeFrame(img,box, [],'doPooling', true, 'compMirrorFeat', true,'imSize',512);
    end
    desc = desc./numel(track_data);
    desc = bsxfun(@time,descs,1./sqrt(max(sum(desc.^2),0.001))); 
    
end
