function sformatted = ieParamFormat(s)
% Converts s to a standard ISET parameter format  (lower case, no spaces)
%
% Syntax
%    sformatted = ieParamFormat(s)
%
% Description:
%    The string is sent to lower case and spaces are removed.
%
%    If the input argument is a cell array, then ieParamFormat is
%    called on the odd entries of the array.  This allows conversion
%    of a varargin that contains only key/value pairs to a form where
%    only the keys are translated to standard ISET parameter format.
%
% Example:
%     ieParamFormat('Exposure Time')
%

% History:
%   Copyright ImagEval Consultants, LLC, 2010
%
%   12/05/17  dhb  Handle cell arrays.
%

% Examples:
%{
    ieParamFormat('Exposure Time')
    keyValuePairs{1} = 'Exposure Time';
    keyValuePairs{2} = 1;
    keyValuePairs{3} = 'iWasCamelCase';
    keyValuePairs{4} = 'Do Not Convert Me';
    keyValuePairs = ieParamFormat(keyValuePairs)
%}

% Numbers just get returned.  Added July 30, 2022 by BW for a case in
% iset3d.  Perhaps this should be added to ISETBio also.
if isnumeric(s)
    sformatted = s;
    return;
end

% If it definitely isn't a string, return it.
if (~ischar(s) && ~iscell(s) & ~isstring(s))
    % error('s has to be a character array or cell array');
    sformatted = s;
    return;
end

% Lower case
if (ischar(s) | isstring(s))
    % To lower and remove spaces
    sformatted = lower(s);
    sformatted = strrep(sformatted,' ','');
else
    if (iscell(s))
        sformatted = s;
        for ii = 1:2:length(s)
            sformatted{ii} = ieParamFormat(s{ii});
        end
    end
end


