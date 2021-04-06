function cpCompareImages(leftImage, rightImage, title)
%CPCOMPAREIMAGES Simple way to show two images side-by-side
%   Whether they are ip or rgb
if isstruct(leftImage)
    %ipWindow(leftImage);
    leftImageRendered = imageShowImage(leftImage, [],[],0);
else
    leftImageRendered = leftImage;
end
if isstruct(rightImage)
    %ipWindow(rightImage);
    rightImageRendered = imageShowImage(rightImage,[],[],0);
else
    rightImageRendered = rightImage;
end
% in a Live Script figure titles don't show until they are popped-out
% so output one also:
fprintf(title);
figure('Name',title);
imshowpair(leftImageRendered,rightImageRendered, 'montage');
text(.1,.1,title, 'Color','red','FontSize',28,'Units','normalized');
end