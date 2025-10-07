function answer = ieQuestdlg(question, titleStr, options)
% Alternative to Matlab questdlg
%
% This one allows full control of the window, but matches the basic
% functionality.
%
% There were problems with questdlg that made me get this.  But they were
% not solved because it runs deeper with some stupid Matlab bug.  I left
% this here anyway, for future experiments.
%
% See also
%   questdlg

% Example:
%{
 % ETTBSkip 
 % Don't want to autotest an example that doesn't return without human input
  question = 'Am I awake?';
  titleStr = 'Little window';
  answer = ieQuestdlg(question,titleStr);
%}

% Default options if not provided
if nargin < 3
    options = {'Yes', 'No'};
end
if nargin < 2
    titleStr = 'Choose an option';
end

% Create dialog
d = dialog('Position',[300 300 250 150],'Name',titleStr);

% Text
uicontrol('Parent',d,...
    'Style','text',...
    'Position',[20 80 210 40],...
    'String',question,...
    'HorizontalAlignment','left');

% Buttons
for i = 1:length(options)
    uicontrol('Parent',d,...
        'Position',[30 + (i-1)*100, 30, 80, 25],...
        'String',options{i},...
        'Callback',@(src,~) setappdata(d,'answer',src.String));
end

% Wait for user
uiwait(d);
answer = getappdata(d,'answer');
delete(d);
end
