function ipDescription(ip,handles)
%
%   ipDescription(vci,handles)
%
% Summarize settings for display model and image processing in the
% Processor window.
%
% Copyright ImagEval Consultants, LLC, 2005.


%% Image information
txt = sprintf('Image:\n');
wp = ipGet(ip,'data whitepoint');    % It is a column
if ~isempty(wp)
    wpxy = chromaticity(wp(:)');           % Needs a row
    newText = sprintf('  White (xyY):  \t%.2f, %.2f, %.1f \n',...
        wpxy(1),wpxy(2),wp(2)); 
else
    newText = sprintf(' No white point\n');
end
txt = addText(txt,newText);

%% Display information

txt = addText(txt,sprintf('Display:\n'));

% Row, col size
sz = ipGet(ip,'result size');
if ~isempty(sz)
    newText = sprintf(' [row,col]: (%.0f,%.0f)\n',sz(1),sz(2));
    txt = addText(txt,newText);
end

% Dots per inch
dpi = ipGet(ip,'display dPI');
if ~isempty(sz)
    newText = sprintf(' dpi: %.1f\n',dpi);
    txt = addText(txt,newText);
end

% Viewing distance
vd = ipGet(ip,'display viewing distance');
if ~isempty(sz)
    newText = sprintf(' distance: %.1f (m)\n',vd);
    txt = addText(txt,newText);
end

wp = ipGet(ip,'display whitepoint');  
wpxy = chromaticity(wp);
newText = sprintf('  White (xyY): (%.2f,%.2f,%.1f)\n',...
    wpxy(1),wpxy(2),wp(2)); 
txt = addText(txt,newText);

%% Processing parameter information
txt = addText(txt,sprintf('Processor:\n'));
D = ipGet(ip,'correction transform illuminant');
newText = sprintf('  Illuminant: [%.2f,%.2f,%.2f]\n',diag(D));  
txt = addText(txt,newText);

set(handles.txtDisplay,'String',txt);

return;
