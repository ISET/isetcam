function cpCompareImages(leftImage, rightImage, title)
%CPCOMPAREIMAGES Simple way to show two images side-by-side
%   Whether they are ip or rgb
if isstruct(leftImage)
    switch leftImage.type
        case 'vcimage'
            leftImageRendered = imageShowImage(leftImage, [],[], 0);
        otherwise
            %ipWindow(leftImage);
            leftImageRendered = imageShowImage(leftImage, [],[],0);
    end
else
    leftImageRendered = leftImage;
end
if isstruct(rightImage)
    switch rightImage.type
        case 'vcimage'
            rightImageRendered = imageShowImage(rightImage, [],[], 0);
        otherwise
            %ipWindow(rightImage);
            rightImageRendered = imageShowImage(rightImage,[],[],0);
    end
else
    rightImageRendered = rightImage;
end
% in a Live Script figure titles don't show until they are popped-out
% so output one also:
fprintf(title);
figure('Name',title);
imshowpair(leftImageRendered,rightImageRendered, 'montage');
text(.1,.1,title, 'Color','red','FontSize',16,'Units','normalized');
end
