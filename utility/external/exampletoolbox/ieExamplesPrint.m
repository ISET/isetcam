function status = PrintExamples(theFunction,varargin)
% Open file, read it, parse and print the examples
%
% Syntax:
%     status = PrintExamples(theFunction, varargin)
%
% Description:
%    A comment line followed by a
%
%      % Examples:
%       %{
%         ... 
%       %}
%       %{
%         ...
%       %}
%
%    Indicates that the text in block quotes are examples. The
%    examples block is terminated by a blank line.
%
% Inputs:
%    theFunction - String.  Name of a function on the user's path. 
%      which(theFunction) should return the full path to the function. 
%
% Outputs:
%    status - What happened?
%              -1: Found examples but at least one crashed, or other
%                  error such as unmatched block comment open and
%                  close.
%               0: No examples found
%               N: With N > 0.  Number of examples printed.
%
% Optional key/value pairs:
%    'verbose' -      Boolean. Be verbose? Default false
%
% Examples are provided in the code.
%
% See also:
%    
%

% History
%   01/16/18 bw  First implementation

% Examples:
%{
    % Should execute both examples successfully
    PrintExamples('ExecuteTextInScript');
%}

%% Parse input
p = inputParser;
p.addRequired('theFunction',@(x)(exist(x,'file')))
p.addParameter('verbose',false,@islogical);
p.parse(theFunction,varargin{:});

%% Open file
fullFileName = which(theFunction);
theFileH = fopen(fullFileName,'r');
theText = {char(fread(theFileH,'uint8=>char')')};
fclose(theFileH);

% Say hello
if (p.Results.verbose)
    fprintf('Looking for and running examples in %s\n',theFunction);
end

if (strcmp(theFunction,[mfilename '.m']))
    if (p.Results.verbose)
        fprintf('Not running on self to prevent recursion');
    end
    status = 0;
    return;
end

%% Look for a comment line with the text " Examples:"
ind = strfind(theText{1},'% Examples:');
if (isempty(ind))
    if (p.Results.verbose)
        fprintf('\tNo comment line starting with "%% Examples:" in file\n');
    end
    status = 0;
    return;
end

% Look for examples 
candidateText = theText{1}(ind(1)+9:end);
startIndices = strfind(candidateText,'%{');
endIndices = strfind(candidateText,'%}');
if (isempty(startIndices))
    if (p.Results.verbose)
        fprintf('\tNo block comment starts in file\n');
    end
    status = 0;
    return;
end
if (length(startIndices) ~= length(endIndices))
    if (p.Results.verbose)
        fprintf('\tNumber of block comment ends does not match number of starts.\n');
    end
    status = -1;
    return;
end

%% Start the printing
cnt = 0;
fprintf('\n\n');

for bb = 1:length(startIndices)
    cnt = cnt+1;
    fprintf('Example %d \n----------\n',cnt);
    % Find the end of line for the %{ part.  Sometimes people put in
    % extra spaces, so we need to actually find the EOL.
    % Putting this '%}' prevents and ETTB error because number of open and
    % close block comment symbols must match up in the file.
    idx = find(int8(candidateText(startIndices(bb):(startIndices(bb)+8))) == 10);
    
    % Pull out the example text
    exampleText = candidateText((startIndices(bb) + idx):endIndices(bb)-1);
    
    % Print it
    disp(exampleText);
    
    % If this is not the last block comment, check whether the next one is
    % contiguous. If not, we're done with examples and break out and go
    % home.
    if (bb < length(startIndices))
        if (endIndices(bb)+3 <= length(candidateText))
            if (candidateText(endIndices(bb)+3) ~= '%')
                break;
            end
        end
    end
end

status = cnt;

end

