function files = lensList(varargin)
% List and summarize the lenses in isetcam/data/lens with a json extension
%
% Syntax:
%   files = lensList(...)
%
% Description:
%   Requires iset3d. Print a list of the lens .json files in the default
%   directory.  You can create a lens from one of the files with the lens
%   constructor. These json files are the ones we use as lens information
%   for PBRT-V4-spectral.
%
%   The files should have a metadata slot that includes their focal
%   length and fnumber.
%
% Inputs:
%   N/A
%
% Optional key/value pairs:
%   'star'   - dir search restriction (default '*.json')
%   'quiet'  - do not print to the command line
%
% Outputs:
%   file - Cell array of file descriptors with a .json extention
%          The name is file(ii).name
%
% Wandell, ISETBIO Team, 2018
%
% See also

% Examples:
%{
if exist('piDirGet','file')
   lensNames = lensList;  
end
%}
%{
if exist('piDirGet','file')
  lensNames = lensList('quiet',true);
  disp(lensNames);
end
%}
%{
if exist('piDirGet','file')
  lensList('star','dgauss*.json')
  lensList('star','*wide*.json')
end
%}

%% Parse input
p = inputParser;

% If you want the list returned without a print
p.addParameter('quiet',false,@islogical);
p.addParameter('star','*.json',@ischar);
p.parse(varargin{:});

star  = p.Results.star;
quiet = p.Results.quiet;

%% List the json files

files = dir(fullfile(piDirGet('lens'),star));
if quiet, return; end

% Not quiet, so print out the list
for ii=1:length(files)
    fprintf('%d - %s\n',ii,files(ii).name);
end

end