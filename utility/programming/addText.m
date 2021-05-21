function txt = addText(txt,str)
%Add text to an existing text string
%
%   txt = addText(txt,str)
%
% Purpose:
%   Utility for combining strings before sending to an mrMessage
%
% Example:
%  txt = 'Hello World! ';
%  txt = addText(txt,'What a beautiful day!');
%  mrMessage(txt);
%
% Copyright ImagEval Consultants, LLC, 2003.

txt = [txt,sprintf(str)];

return;
