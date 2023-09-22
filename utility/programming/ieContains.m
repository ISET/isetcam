function tf = ieContains(str,pattern)
% Returns 1 (true) if str contains pattern, and returns 0 (false) otherwise.
%
% Synopsis:
%    tf = ieContains(str,pattern)
%
% Description:
%    Work around for the Matlab contains function. Written so that it
%    will work with Matlab versions prior to those with the Matlab function
%    contains().
%
% Inputs
%   str -  A cell array of strings (or a string)
%   pattern -  A string
%
% Returns
%   tf    A logical array for each entry in the cell array, according
%         to whether it contains the pattern
%
% DHB/ZL ISETBIO Team
%
% See also:
%   contains, strfind
%

% Examples
%{
   ieContains('help','he')
   ieContains('help','m')
   ieContains({'help','he','lp'},'he')
%}

if(iscell(str))
    tf = zeros(1,length(str));
    
    % If cell loop through all entries.
    for ii = 1:length(str)
        currStr = str{ii};
        if ~ischar(currStr) && ~isstring(currStr)
            tf(ii) = 0;
        else
            if (~isempty(strfind(currStr,pattern))) %#ok<*STREMP>
                tf(ii) = 1;
            else
                tf(ii) = 0;
            end
        end
    end
else
    if ~ischar(str) && ~isstring(str)
        tf = 0;
    else
        if (~isempty(strfind(str,pattern)))
            tf = 1;
        else
            tf = 0;
        end
    end
    
end

tf = logical(tf);

end

