%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef imgPlot < handle
    
    
    properties
        path
	aviobj 
    end

    methods

       function obj = imgPlot()
       end
        
       function img = plotDet(obj,img,det,track,fp)

        det = floor(det);
        if(det(3) <6 || det(4) <6)
            return
        end
		l = det(1);
		l = max(1,l);
		t = det(2);
		t = max(1,t);
		r = det(1)+det(3);
		r = min(r,size(img,2));
		b = det(2)+det(4);
		b = min(b,size(img,1));
        l = floor(l);
        r = floor(r);
        t = floor(t);
        b = floor(b);
		dd = 5;
		dd1 = 5;
		img1 = img;

		if(~fp)
			img1(t:t+dd,l:r,:)=255;
			img1(b-dd:b,l:r,:)=255;
			img1(t:b-1,l:l+dd,:)=255;
			img1(t:b-1,r-dd:r,:)=255;
		else
			img1(t:t+dd,l:r,:)=0;
			img1(t:t+dd,l:r,1)=255;
			img1(b-dd:b,l:r,:)=0;
			img1(b-dd:b,l:r,1)=255;
			img1(t:b-1,l:l+dd,:)=0;
			img1(t:b-1,l:l+dd,1)=255;
			img1(t:b-1,r-dd:r,:)=0;
			img1(t:b-1,r-dd:r,1)=255;
		end
		img = img1;
        img = insertText(img,[l,t],num2str(track));
       end

       function write(obj)
		obj.aviobj = close(obj.aviobj);
       end
    end

	
end
