function handles = metricsDescription(handles)
%Print descriptive text for upper right corner of Metrics Window.
%
%    handles = metricsDescription(handles)
%
% This text describes information about the metrics calculations.
%
% Copyright ImagEval Consultants, LLC, 2005.

[vci1, vci2] = metricsGetVciPair(handles);

% This string will be written into the upper right hand corner

% White point for each image.
txt = sprintf('Image 1:\n');
str = [];
str = addText(str,txt);

txt = sprintf('size: (%.0f,%.0f)\n',ipGet(vci1,'size'));
str = addText(str,txt);

wp = ipGet(vci1,'imagewhitepoint');
if isempty(wp), txt = sprintf('No image white point\n');
else txt = sprintf('White (X,Y,Z): (%.1f,%.1f,%.1f)\n',wp(1),wp(2),wp(3));
end
str = addText(str,txt);

str = addText(str,sprintf('\n-----------------\n\n'));
txt = sprintf('Image 2:\n');
str = addText(str,txt);

txt = sprintf('size: (%.0f,%.0f)\n',ipGet(vci2,'size'));
str = addText(str,txt);

wp = ipGet(vci2,'imagewhitepoint');
if isempty(wp), txt = sprintf('No image white point\n');
else txt = sprintf('White (X,Y,Z): (%.1f,%.1f,%.1f)\n',wp(1),wp(2),wp(3));
end
str = addText(str,txt);

set(handles.txtInfo,'String',str);

return;