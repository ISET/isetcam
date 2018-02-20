function dList = displayList(varargin)
% List the display data stored in data/displays
%
%   dList = displayList('type','LCD/CRT/OLED','show',true/false)
%
% Directory listing of the displays in data/displays.  I always forget
% their names, so I use this to remind myself what is there.
%
% Inputs
% Name-value parameters
%   'type'  -  string to limit display types (LCD, CRT, OLED)
%   'show'  -  display the listing to the command prompt
% Return
%  dList =  Directory listing of the files
%
% Examples
%   displayList;   % Shows all
%   dList = displayList('type','OLED');
%   dList = displayList('type','LCD','show',false); dList(1)
%
% Copyright Imageval Consulting, 2016

p = inputParser;
p.addParameter('type','',@ischar);
p.addParameter('show',true,@islogical);
p.parse(varargin{:});

dtype  = p.Results.type;
show   = p.Results.show;

%%
if isempty(dtype)    % We will add
    dList = dir(fullfile(isetRootPath,'data','displays','*.mat'));
else
    dList = dir(fullfile(isetRootPath,'data','displays',[dtype,'*.mat']));
end

% Maybe there should be a flag
if show
    for ii=1:length(dList)
        disp(dList(ii).name)
    end
end

end