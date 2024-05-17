function pos = centerfig(width,height,scale)
%pos=centerfig(relwidth,relheight,scale) calculates the Position vector to center a figure on the screen
%  Author: Peter Burns, 19 Feb. 2007
%  Copyright (c) 2007 Peter D. Burns

if nargin < 3;
    scale = 0.65;
end

ms = get(0,'ScreenSize');
center = [ms(1)+ms(3)/2, ms(2)+ms(4)/2];

rat = width/height;
maxw = scale*ms(3)-ms(1);
maxh = scale*ms(4)-ms(2);
  fw = width/maxw;
  fh = height/maxh;

%if max(fw,fh) > 1;
  if fw > fh;
   width = maxw;
   height = width/rat;
  else
   height = maxh;
   width = height*rat;
 end
%end  
pos = [center(1)-width/2, center(2)-height/2, width, height];