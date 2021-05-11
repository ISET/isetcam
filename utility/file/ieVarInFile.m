function bool = ieVarInFile(fullname, varName)
% Check whether a variable is in a particular Matlab file
%
%   bool = ieVarInFile(fullnameOrVariables,varName)
%
% fullname:  Typically, this is the file name.  But if you already have the
%   variables loaded via variables = whos('-file',fullname);, we we notice
%   that fullname is a struct and we treat it as an array of variables.
% varName:   The variable name string.
%
% Example:
%   fullname = fullfile(isetRootPath,'data','human','XYZ.mat');
%   ieVarInFile(fullname,'data')
%
%   ieVarInFile(fullname,'xyz')
%
%   fullname = fullfile(isetRootPath,'data','images','hyperspectral','surgicalSWIR.mat');
%   varName = 'hc';
%   ieVarInFile(fullname,varName)
%
%  Alternate calling convention
%
%   variables = whos('-file',fullname);
%   ieVarInFile(variables,varName)
%
% See also:  vcReadImage
%
% Copyright ImagEval Consultants, LLC, 2012.

% Assume not present
bool = 0;

% Decide if fullname is a file or a list of variables
if ischar(fullname) && ~isstruct(fullname), variables = whos('-file', fullname);
elseif isstruct(fullname), variables = fullname;
end

% Check, one-by-one, returning true if found
for ii = 1:length(variables)
    if strcmp(variables(ii).name, varName)
        bool = 1;
        break;
    end
end

return