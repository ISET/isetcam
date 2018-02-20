function sensorCfaSave(ISA,fullName)
%Save a color filter array structure to a mat file.
%
%     sensorCfaSave(ISA,[fname])
%
% The user is prompted to select a file name.  The color filter array
% information is saved to this file.  The cfa information includes the
% fields for ISA.color and ISA.cfa 
%
% To read a cfa use sensorReadFilter('cfa').
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('fullName'), fullName = vcSelectDataFile(['sensor',filesep,'cfa'],'w'); end
if isempty(fullName), return; end

% These are the data fields that contain cfa information
color    = sensorGet(ISA,'color');
cfa      = sensorGet(ISA,'cfa');
spectrum = sensorGet(ISA,'spectrum');

% Make sure that the first letter of the filter names is lower case
filterNames = color.filterNames;
for ii=1:length(filterNames)
    filterNames{ii}(1) = lower(filterNames{ii}(1)); 
end
color.filterNames = filterNames;


% Save them all
save(fullName,'cfa','color','spectrum');

return;