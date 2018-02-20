function procTrueSize(vciHandles)
% Show the processed image in a window at its true size
%
%    procTrueSize(vciHandles)
%
% Example:
%    vciH = ieSessionGet('vcimageHandles');
%    procTrueSize(vciH);
%
% Copyright ImagEval Consultants, LLC, 2005.

% Shouldn't this be an ipGet() and how is vciHandles.editGamma related to
% the current ip?
gam = str2double(get(vciHandles.editGamma,'String'));
trueSizeFlag = 1;

% Save the current figure;
ip = vcGetObject('ip');
figNumTRUESIZE = vcNewGraphWin;
imageShowImage(ip,gam,trueSizeFlag,figNumTRUESIZE);
set(figNumTRUESIZE,'menubar','none','name','ISET');

return;
