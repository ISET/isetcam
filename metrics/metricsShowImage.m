function handles = metricsShowImage(handles)
%Display the vci images in the two image axes.
%
%    handles = metricsShowImage(handles)
%
% The images in the vcimages selected in the popup windows and handles.img2
% are displayed.   
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('handles'), error('Metric window handles not valid.'); end

[vci1, vci2] = metricsGetVciPair(handles);
gamma = str2num(get(handles.editGamma,'String'));

% Display the two rendered images in the two axes of the metrics window
% I am not sure which imaging operation we should use for the displays
% here.  I think they differ from the imagescM one used in the 3rd axes.
img1 = ipGet(vci1,'result');
if ~isempty(img1)
    axes(handles.img1);
    imagescRGB(img1,gamma);
end

v = get(handles.popImageList2,'Value');
img2 = ipGet(vci2,'result');
if ~isempty(img2)
    axes(handles.img2);
    imagescRGB(img2,gamma);
end

return;

