function [ bytes ] = ieMemorySize( variable )
% Quick look at the size of struct variables
%
% https://www.mathworks.com/matlabcentral/answers/14837-how-to-get-size-of-an-object
%
% See also
%   whos

props = properties(variable);

if size(props, 1) < 1, bytes = whos(varname(variable)); bytes = bytes.bytes;
else %code of Dmitry
    bytes = 0;
    for ii=1:length(props)
        currentProperty = getfield(variable, char(props(ii)));
        s = whos(varname(currentProperty));
        bytes = bytes + s.bytes;
    end
end

fprintf('\n*** Size:  %.2f KB\n',bytes/1024);

end

% Helper
function [ name ] = varname( ~ )
name = inputname(1);
end
