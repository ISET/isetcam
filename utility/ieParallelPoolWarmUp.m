function poolObj = ieParallelPoolWarmUp(varargin)
% IEPARALLELPOOLWARMUP Start a parallel pool before expensive workflows.
%
% Syntax:
%   poolObj = ieParallelPoolWarmUp;
%   poolObj = ieParallelPoolWarmUp('workers', 4);
%   poolObj = ieParallelPoolWarmUp('config', 'conservative');
%
% Description:
%   Starting the MATLAB parallel pool can take noticeable time. Calling this
%   helper from startup.m makes that cost explicit and keeps the first
%   parfor-heavy tutorial or example from appearing to stall.
%
% Optional key/value pairs:
%   workers        - Desired number of workers. Default uses the profile.
%   config         - AppleSiliconParPoolManager config, such as
%                    'default' or 'conservative'. Ignored if workers is set.
%                    If AppleSiliconParPoolManager is unavailable, falls
%                    back to MATLAB's default parpool.
%   runSilent      - Suppress progress messages. Default false.
%   throwOnFailure - Throw errors instead of warning and returning [].
%                    Default false, which is safer for startup.m.
%
% See also: parpool, gcp

p = inputParser;
p.addParameter('workers', [], @(x)(isempty(x) || (isscalar(x) && isnumeric(x) && x >= 1)));
p.addParameter('config', [], @(x)(isempty(x) || ischar(x) || isstring(x)));
p.addParameter('runSilent', false, @islogical);
p.addParameter('throwOnFailure', false, @islogical);
p.parse(varargin{:});

workers = p.Results.workers;
config = p.Results.config;
runSilent = p.Results.runSilent;
throwOnFailure = p.Results.throwOnFailure;

poolObj = gcp('nocreate');
if (~isempty(poolObj))
    if (~runSilent)
        fprintf('Parallel pool already running with %d workers.\n', poolObj.NumWorkers);
    end
    return;
end

try
    if (~isempty(workers))
        if (~runSilent)
            fprintf('Starting parallel pool with %d workers.\n', workers);
        end
        poolObj = parpool(workers);
    elseif (~isempty(config))
        if (exist('AppleSiliconParPoolManager', 'class') == 8)
            AppleSiliconParPoolManager(char(config), 'runSilent', runSilent);
            poolObj = gcp('nocreate');
        end
        if (isempty(poolObj))
            if (~runSilent)
                fprintf('Starting parallel pool using the default profile.\n');
            end
            poolObj = parpool;
        end
    else
        if (~runSilent)
            fprintf('Starting parallel pool using the default profile.\n');
        end
        poolObj = parpool;
    end
catch err
    if (throwOnFailure)
        rethrow(err);
    end
    warning('ieParallelPoolWarmUp:CouldNotStart', ...
        'Could not start a parallel pool: %s', err.message);
    poolObj = [];
end
end
