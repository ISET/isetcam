function differences = ieStructCompare2(structA, structB, prefix)
% STRUCTCOMPARE Recursively compares two MATLAB variables (structures or objects)
% and returns a cell array detailing all field paths where the values differ.
%
% Inputs:
%   structA: The first variable (struct or object) for comparison.
%   structB: The second variable (struct or object) for comparison.
%   prefix:  (Optional, internal use) A string used for tracking the field
%            path (e.g., 'parent.child.field').
%
% Output:
%   differences: A cell array of strings, where each string describes a
%                field path and the reason for the difference (e.g.,
%                'Path: thisR.settings.gamma | Difference: Values are not equal').
%
% Example Usage:
%   % Assuming thisR and thisRV are your two objects (@recipe)
%   diffs = structCompare(thisR, thisRV);
%   disp(diffs)
%
% See also: isequal, fieldnames, isobject, struct

if nargin < 3
    prefix = inputname(1); % Use the variable name of the first variable as the starting prefix
end

differences = {};
currentDifferences = {};

% --- OBJECT CONVERSION: If inputs are objects, convert them to structures. ---
% This allows comparison of object properties using structure field access.
if isobject(structA)
    structA = struct(structA);
end
if isobject(structB)
    structB = struct(structB);
end

% --- 1. Check if both inputs are now structures (or were simple values) ---
if ~isstruct(structA) || ~isstruct(structB)
    if isequal(structA, structB)
        return; % Values are equal (e.g., identical arrays, strings, or numbers)
    else
        % If inputs are not structs and not equal (e.g., different arrays/numbers)
        currentDifferences{end+1} = sprintf('Path: %s | Difference: Values are not equal', prefix);
        differences = [differences, currentDifferences];
        return;
    end
end

% --- 2. Check for differences in field names or field counts ---
fieldsA = fieldnames(structA);
fieldsB = fieldnames(structB);

if ~isequal(sort(fieldsA), sort(fieldsB))
    missingInB = setdiff(fieldsA, fieldsB);
    missingInA = setdiff(fieldsB, fieldsA);

    if ~isempty(missingInB)
        currentDifferences{end+1} = sprintf('Path: %s | Difference: Field(s) missing in second struct: %s', prefix, strjoin(missingInB, ', '));
    end
    if ~isempty(missingInA)
        currentDifferences{end+1} = sprintf('Path: %s | Difference: Field(s) missing in first struct: %s', prefix, strjoin(missingInA, ', '));
    end
    % Continue checking common fields, but warn about field name differences
end

% --- 3. Iterate and compare common fields ---
commonFields = intersect(fieldsA, fieldsB);
for i = 1:length(commonFields)
    field = commonFields{i};
    newPrefix = [prefix, '.', field];
    
    valA = structA.(field);
    valB = structB.(field);
    
    if isstruct(valA) && isstruct(valB)
        % Recursive call for nested structures
        subDifferences = ieStructCompare2(valA, valB, newPrefix);
        currentDifferences = [currentDifferences, subDifferences];
    elseif iscell(valA) && iscell(valB)
        % Handle cell arrays by comparing each element
        if numel(valA) ~= numel(valB)
             currentDifferences{end+1} = sprintf('Path: %s | Difference: Cell array size mismatch (%d vs %d)', newPrefix, numel(valA), numel(valB));
        else
            for j = 1:numel(valA)
                % Recurse for nested cell elements if they are structs or objects
                if (isstruct(valA{j}) || isobject(valA{j})) && (isstruct(valB{j}) || isobject(valB{j}))
                    subDifferences = structCompare(valA{j}, valB{j}, [newPrefix, '{', num2str(j), '}']);
                    currentDifferences = [currentDifferences, subDifferences];
                elseif ~isequal(valA{j}, valB{j})
                    currentDifferences{end+1} = sprintf('Path: %s{%d} | Difference: Cell element values are not equal', newPrefix, j);
                end
            end
        end
    elseif ~isequal(valA, valB)
        % Check for the common case: arrays, numerics, strings are not equal
        currentDifferences{end+1} = sprintf('Path: %s | Difference: Values are not equal', newPrefix);
        
        % Add value summary if they are scalar/string for better debugging
        if (isnumeric(valA) && isscalar(valA)) || ischar(valA) || isstring(valA)
            try
                summaryA = convertToString(valA);
                summaryB = convertToString(valB);
                currentDifferences{end} = sprintf('%s (Value A: %s, Value B: %s)', currentDifferences{end}, summaryA, summaryB);
            catch
                % If conversion fails, keep the original message
            end
        end
    end
end

% Aggregate all differences
differences = [differences, currentDifferences];

end

% Helper function to convert scalar/string values to a readable string
function s = convertToString(v)
    if ischar(v)
        s = ['''' strtrim(v) ''''];
    elseif isstring(v)
        s = ['"' strtrim(v) '"'];
    elseif isnumeric(v) && isscalar(v)
        s = num2str(v);
    else
        s = 'Complex Data';
    end
end