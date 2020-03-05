function [functionNames, functionStatus ] = ExecuteExamplesInDirectory(parentDir,varargin)
% Recursively descend directory tree and execute examples in all functions
%
% Syntax:
%    [functionNames, functionStatus ] = ExecuteExamplesInDirectory(parentDir)
%
% Description:
%    Run ExecuteExamplesInFunction on all of the .m files in a directory,
%    as well as recurses down all the subdirectories and do the same.
%
%    Prints out a report of successful and failed example running.
%
%    Checks for itself and does not run its own examples, to prevent
%    infinite recursion.
%
%    Also does not descend into directories whose name contains the string
%    "underDevelopment"
%
% Inputs:
%    parentDir -      String.  The directory to start in.
%
% Outputs:
%    functionNames -  Cell array with names of functions examined using
%                     ExecuteExamplesInFunction.
%    functionStatus - Status returned by ExecuteExamplesInFunction for each
%                     function examined.
%
% Optional key/value pairs
%    'verbose' -            Boolean. Be verbose? Default false
%    'printnoexamples' -    Boolean. List functions that have no examples.
%                           Default false.
% .  'printreport'     -    Boolean. Print a report at the end? Default
%                           true.  Set to false when recursing so we just
%                           get a report at the end of the top level.
%    'closefigs'      -     Close figures after running each example.  Default
%                           true.
%
% Examples are provided in the code
%
% See also:
%    ExecuteExamplesInFunction, ExecuteTextInScript
%

% History
%   01/16/18  dhb   Wrote it.
%   01/23/18  dhb   Pass verbose into subfunction.

% Examples:
%{
    theDir = fileparts(which('ExecuteExamplesInDirectory'));
    ExecuteExamplesInDirectory(fullfile(theDir,'TestSubdir'),'verbose',true,'printnoexamples',true);
%}
%{
    % If you use isetbio and also have it on your path, you can try this.
    if (exist('isetbioRootPath','file'))
        ExecuteExamplesInDirectory(fullfile(isetbioRootPath,...
          'isettools','wavefront'),'verbose',true);

        % Although there is an example in synchronizeISETBIOWithRepository,
        % it contains an "% ETTBSkip" comment and thus is skipped.
        ExecuteExamplesInDirectory(fullfile(isetbioRootPath,...
          'external'),'verbose',true);
    end
%}

% Input parser
p = inputParser;
p.addParameter('verbose',false,@islogical);
p.addParameter('printnoexamples',false,@islogical);
p.addParameter('printreport',true,@islogical);
p.addParameter('closefigs',true,@islogical);
p.parse(varargin{:});

% Get current directory and change to parentDir
curDir = pwd;
cd(parentDir);

% Get everyting in the directory
theContents = dir(fullfile('*'));

% Here we go
nRunFunctions = 0;
functionNames = {};
functionStatus = [];
for ii = 1:length(theContents)
    %theContents(ii)
    
    % Desend into directory?
    if (theContents(ii).isdir & ...
            ~strcmp(theContents(ii).name,'.') ...
            & ~strcmp(theContents(ii).name,'..') ...
            & isempty(strfind(theContents(ii).name,'underDevelopment')))
        if (p.Results.verbose)
            fprintf('Descending into %s\n',theContents(ii).name)
        end
        
        % Recurse!
        [tempFunctionNames,tempFunctionStatus] = ...
            ExecuteExamplesInDirectory(fullfile(parentDir,theContents(ii).name),...
            'printreport',false, ...
            'verbose',p.Results.verbose, ...
            'closefigs',p.Results.closefigs);
        tempNRunFunctions = length(tempFunctionNames);
        functionNames = {functionNames{:} tempFunctionNames{:}};
        functionStatus = [functionStatus(:) ; tempFunctionStatus(:)];
        nRunFunctions = nRunFunctions + tempNRunFunctions;
        
        % Run on a .m file? But don't run on self.
    elseif (length(theContents(ii).name) > 2)
        if (strcmp(theContents(ii).name(end-1:end),'.m') & ...
                ~strcmp(theContents(ii).name,[mfilename '.m']))
            
            % Check examples and report status
            status = ExecuteExamplesInFunction(theContents(ii).name, ...
                'verbose',p.Results.verbose, ...
                'closefigs',p.Results.closefigs);
            nRunFunctions = nRunFunctions+1;
            functionNames{nRunFunctions} = theContents(ii).name(1:end-2);
            functionStatus(nRunFunctions) = status;
        else
            if (p.Results.verbose)
                fprintf('%s: Ignoring\n',theContents(ii).name);
            end
        end
    else
        if (p.Results.verbose)
            fprintf('%s: Ignoring\n',theContents(ii).name);
        end
    end
end

%% Report at the end
if (p.Results.printreport)
    fprintf('\n*** Example Test Report ***\n\n');
    for ii = 1:length(functionNames)
        % Get function name and its status
        name = functionNames{ii};
        status = functionStatus(ii);
        
        % Report as appropriate
        if (status == -1)
            fprintf(2,'%s: At least one example FAILED!\n',name);
        elseif (status == 0)
            if (p.Results.printnoexamples)
                fprintf('%s: No examples found\n',name);
            end
        elseif (status > 0)
            fprintf('%s: Ran %d examples OK!\n',name,status);
        else
            error('Unexpected value for returned status');
        end
    end
end

% Return to calling dir
cd(curDir);

end
