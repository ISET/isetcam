function figNum = plotSetUpWindow(figNum)
%Initialize position, size and colormap for ISET plot window
%
%  plotSetUpWindow(figNum)
%
% This routine could, ultimately, take into account the user's display says
% or other window positions.  
%
% Examples:
%  plotSetUpWindow;
%  plotSetUpWindow(1);
%
% Copyright ImagEval Consultants, LLC, 2003.

%TODO:
%   The management of the graphics windows is very poor right
%   now and needs to be corrected.  We should allow multiple graph windows
%   and help keep track of them.
%   

if ieNotDefined('figNum')
    figNum = vcSelectFigure('GRAPHWIN'); 
    set(figNum,'Units','Normalized','Position',[0.5769, 0.0308,0.4200, 0.4200]);
    set(figNum,'Name','ISET GraphWin','NumberTitle','off');
else
    figure(figNum); 
end

colormap('default')
clf

return;