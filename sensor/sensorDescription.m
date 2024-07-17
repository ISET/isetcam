function [tbl, stringTable] = sensorDescription(sensor,varargin)
% Print out table of sensor and pixel parameters
%
% Synopsis
%   tbl = sensorDescription(sensor)
%
% Input
%   sensor
%  
% Optional key/val
%   show - Prints to command line by default (logical)
%   close window  - Closes the display window by default (logical)
%
% Output
%   tbl - A simple Matlab table
%
% See also:
%   iePTable()
%

% Example:
%{
sensor = sensorCreate;
[tbl, strTbl] = sensorDescription(sensor,'show',false,'close window',true);
disp(tbl);
disp(strTbl);
%}

%% Inputs
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('sensor',@isstruct);
p.addParameter('show',true,@islogical);
p.addParameter('closewindow',true,@islogical);

p.parse(sensor,varargin{:});

%%
% Use the iePTable to retrieve key parameters
[uit, hdl] = iePTable(sensor,'format','window');

% Convert the uitable to a simple table
tbl = uitableToSimpleTable(uit);

% Convert the cells to strings
stringTable = cellfun(@(x) string(x), table2cell(tbl));

if p.Results.show, disp(stringTable); end
if p.Results.closewindow, delete(hdl); end

end

%% ----------------------------------------------
function simpleTable = uitableToSimpleTable(uit)
% Convert the uitable to a simple Matlab table

tableData = get(uit, 'Data');
columnNames = get(uit, 'ColumnName');
rowNames = get(uit, 'RowName');

% Create a new table
simpleTable = cell2table(tableData, 'VariableNames', columnNames);
if ~isempty(rowNames)
    simpleTable.Properties.RowNames = rowNames;
end

end



