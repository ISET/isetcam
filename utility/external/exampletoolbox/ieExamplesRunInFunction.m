function status = ExecuteExamplesInFunction(theFunction,varargin)
% Open file, read it, parse execute any examples
%
% Syntax:
%     status = ExecuteExamplesInFunction(theFunction)
%
% Description:
%    Examples are enclosed in block quotes, following a comment line that
%    starts exactly with "% Examples:". By enforcing the exact form, we
%    maxmimize the odds that we find only real examples.
%
%    Once there is a line that starts exactly with "% Examples:", any
%    subsequent text in block quotes is treated as example code, until an
%    ending block quote "%}" is followed by a blank line.  This means that
%    the examples should follow contiguously after the examples line, and
%    prevents us from running actual block comments as examples.
%
%    There is a check that prevents this function from running its own
%    examples, to prevent an infinite recurse. Thus, if run on itself, this
%    function reports a status of 0, even though there are examples in the
%    source that may be run manually.
%
%    Some examples are not good for autoexecute (for example, some require
%    user input and that could be annoying).  If text of the form
%    "% ETTPSkip" appears in an example, it is not run.
%
% Inputs:
%    theFunction - String.  Name of the function file (with the .m at the
%                  end).
%
% Outputs:
%    status -      What happened?
%                    -1: Found examples but at least one crashed, or other
%                        error such as unmatched block comment open and
%                        close.
%                     0: No examples found
%                     N: With N > 0.  Number of examples run successfully,
%                        with none failing.
%
% Optional key/value pairs:
%    'verbose' -      Boolean. Be verbose? Default false
%    'findfunction'   Boolean. Rather than take the full path to the
%                     desired function, look for it on the path.  Default
%                     false.
%    'printexampletext' Boolean. Print out string to be evaluated for each
%                     example.  Can be useful for debugging which example
%                     is failing and why.  Default false.
%    'closefigs'      Close figures after running each example.  Default
%                     true.
%
% Examples are provided in the code.
%
% See also:
%    ExecuteTextInScript, RunExamples
%

% History
%   01/16/18 dhb Wasting time on a train.
%   01/20/18 dhb Add ability to look for funcitons
%                on the path, via key/value pair.
%   02/29/20 dhb Add closefigs paramter.

% Examples:
%{
    % Should execute both examples successfully
    ExecuteExamplesInFunction('ExecuteTextInScript.m')
%}
%{
    % Should report that there are no examples in itself, to avoid
    % recursion
    ExecuteExamplesInFunction('ExecuteExamplesInFunction.m')
%}
%{
    % Try running examples in a function that is found on the path.
    curDir = pwd;
    cd(userpath);
    ExecuteExamplesInFunction('TestFunctionWithExamples.m','findfunction',true);
    cd(curDir);
%}

%% Parse input
p = inputParser;
p.addParameter('verbose',false,@islogical);
p.addParameter('findfunction',false,@islogical);
p.addParameter('printexampletext',false,@islogical);
p.addParameter('closefigs',true,@islogical);
p.parse(varargin{:});

%% Try to find function on path, if that is specified.
if (p.Results.findfunction)
    theFunction = which(theFunction);
    if (isempty(theFunction))
        error('Could not find desired function on path.')
    end
end

% Open file
theFileH = fopen(theFunction,'r');
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

% Look for a comment line with the text " Examples:"
ind = strfind(theText{1},'% Examples:');
if (isempty(ind))
    if (p.Results.verbose)
        fprintf('\tNo comment line starting with "%% Examples:" in file\n');
    end
    status = 0;
    return;
end

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

nExamplesOK = 0;
status = 0;
for bb = 1:length(startIndices)
    % Get this example and run.  If it throws an error, return with
    % status -1. Otherwise, increment number of successful examples
    % counter, and status.
    exampleText = candidateText(startIndices(bb)+3:endIndices(bb)-1);
    
    % Check for skip text in example.  Don't execute if it is there
    skipTest = strfind(exampleText,'% ETTBSkip');
    if (~isempty(skipTest)) %#ok<*STREMP>
        if (p.Results.verbose)
            fprintf('\tExample %d contains ''%% ETTBSkip'' - skipping.\n',bb);
        end
    
    % Have a live example.  Run it.
    else 
        % Dump example text if asked
        if (p.Results.printexampletext)
            fprintf('Example text:\n');
            exampleText %#ok<NOPRT>
        end
        
        % Do the eval inside a function so workspace is clean and nothing here
        % gets clobbered.
        tempStatus = EvalClean(exampleText,p.Results.closefigs);
        if (tempStatus == 0)
            if (p.Results.verbose)
                fprintf('\tExample %d success\n',bb);
            end
            nExamplesOK = nExamplesOK+1;
            status = nExamplesOK;
        else
            status = -1;
            if (p.Results.verbose)
                fprintf('\tExample %d failed\n',bb);
            end
            return;
        end
    end
    
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

end

% This short function forces examples to run in a clean workspace,
% and protects the calling workspace.  Also closes any figures that
% are open if CLOSEFIGS is true, unless the called example clobbers
% the workspace in which case they are also left open.
function status = EvalClean(str,CLOSEFIGS)

try
    eval(str)
    status = 0;
catch
    status = -1;
end

if (exist('CLOSEFIGS','var') & CLOSEFIGS)
    close all;
end

end




