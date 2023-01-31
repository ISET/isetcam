function [select, coord] = getroi(array1, dialtext, tol)
% [select, coord] = getroi(array, dialtext, tol)  Select and return region of interest
%
% [select, coord] = getroi(array, dialtext, tol) GUI, region of interest select
% Select and return image region of interest (ROI) via a GUI window and
% 'right-button-mouse' operation. If the mouse button is clicked and
%  released without movement, the entire displayed image will be selected.
%  array    = input image array(nlin, npix [, ncolor])
%  dialtext = (optional) string for title of dialog box (e.g. data id)
%  tol      = tolerance in pixels less than which whole image is selected
%             default = 10 (simple click selects all)
%           = negative  If negative, the ROI rectangle is taken as a single
%             line or column. If the smaller dimension of ROI is less than
%              abs(tol), then that dimension is taken as 1.
%  select (double) - output ROI as an array(newlin, newpix[, ncolor])
%  coord is list of coordinates of ROI (upperleft(x,y),lowerright(x,y))
%
% Author: Peter Burns, pdburns@ieee.org
% 30 June 2021 updated to handle greater than 3 color records
%******************************************************************
aflag = 0;
[nn,mm,nc] = size(array1);
fac = round((nn+mm)/1600);
fac = max(fac,1);
array = array1(1:fac:end, 1:fac:end, :);
if nargin < 3
 tol =10;
end

if nargin == 2
 test = class(dialtext);
 if strcmp(test(1:3), 'cha')==1
  dialtext = [dialtext];
  tol = 10;
 else tol = dialtext;
  dialtext = 'Select ROI';
 end
end  % nargin == 2

if nargin < 2
 dialtext = 'Select ROI';
 tol = 10;
end

lflag = 0;
if tol < 0
 lflag = 1;
end

tol = round(abs(tol));

% end of added 19 Aug 2003

dim = size(array);
nlin = dim(1);
npix = dim(2);
if size(dim)==[1 2]
  ncol =1;
else
  ncol = dim(3);
end
 if ncol>3
     arraytemp = array;
     array = array(:,:,1:3);
 end
 screen = 0.95*(get(0, 'ScreenSize')); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ms = get(0,'ScreenSize');
pos = centerfig(0.6*ms(3)+0.05*ms(3),0.7*ms(4));
fig=figure; set(gcf,'Position', pos,'Menu','none','Name',' Region selection',...
    'NumberTitle','off');
 title(dialtext)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ');
disp('Select ROI with right mouse button, no move = all');
disp(' ');

temp = class(array);

if strcmp(temp(1:5), 'uint8')==1
%    gg = axes;
imagesc(array),

else
 %   gg = axes;
imagesc( double(array)/double(max(max(max(array)))))

end 
 title(dialtext) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 axis image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ncol == 1
 colormap('gray')
end

%axis off,

junk=waitforbuttonpress;
ul=get(gca,'CurrentPoint');

final_rect=rbbox;
lr=get(gca,'CurrentPoint');
ul=round(ul(1,1:2));
lr=round(lr(1,1:2));

if ul(1,1) > lr(1,1)              % sort x coordinates
   mtemp = ul(1,1);
   ul(1,1) = lr(1,1);
   lr(1,1) = mtemp;
 end
 if ul(1,2) > lr(1,2)            % sort y coordinates
   mtemp = ul(1,2);
   ul(1,2) = lr(1,2);
   lr(1,2) = mtemp;
 end 

% Added 17 Nov. 2003

if lr(1,1) < 1                     %Check for out of bounds
   lr(1,1)=1;
end
if lr(1,2) < 1
   lr(1,2)=1;
end
if lr(1,1) > npix
   lr(1,1)=npix;
end
if lr(1,2) > nlin
   lr(1,2)=nlin;
end
if ul(1,1) < 1                   
   ul(1,1)=1;
end
if ul(1,2) < 1
   ul(1,2)=1;
end
if ul(1,1) > npix
   ul(1,1)=npix;
end
if ul(1,2) > nlin
   ul(1,2)=nlin;
end

% end of  Added 17 Nov. 2003

if tol ~= 0    % added/edited  19 Aug 2003

 roi = [lr(2)-ul(2)  lr(1)-ul(1)];  % if del x,y <tol pixels, select line

 if lflag == 1
   
   if roi(1) < tol
    ul(2) = round((lr(2)+ul(2))/2);
    lr(2) = ul(2);
   end

  if roi(2) < tol
    ul(1) = round((lr(1)+ul(1))/2);
    lr(1) = ul(1);
  end  % if

 else

  if roi(1) < tol           % if del x,y <tol pixels, select whole array
    ul(2) = 1;
    lr(2) =nlin;
  end
  if roi(2) < tol
    ul(1) = 1;
    lr(1) =npix;
  end % if

end  % lflag == 1

end % tol ~= 0

% end of added/edited  19 Aug 2003

ul = round(1 + fac*(ul-1));
lr = round(1 + fac*(lr-1));
select= array1(ul(2):lr(2), ul(1):lr(1), :);
coord = [ul(:,:), lr(:,:)];

close;
 % Flush graphics so console is visible
 pause(0.05)
 drawnow
