function ieManualCreate(varargin)
% Use m2html to create a manual of all ISET functions
%
% Brief synopsis
%  This script finds ISETCAM and runs m2html. A new manual of HTML files
%  will be created in the directory html-manual.
%
% Inputs:
%   N/A
%
% Optional key/value (default)
%  style      - Output style ('default')
%  manualName - Output directory name ('iManual')
%  sourceName - Input directory ('isetcam')
%
% Outputs
%    A directory with the manual pages is created.  Click on index.html to
%    see a browser window that explores the manual pages.
%
% Notes:
%  You must have m2html on your path.
%  I edited m2html to ignore a number of different directories (like
%  external).
%
% Once the manual is created, we will put it somewhere for the wiki page.
%
%    tar cvf iManual.tar iManual 
%
% to create a tar file.  We use tar because permissions are preserved.
% Then I move to google drive where Joyce uploads using cpanel to Imageval
% site.  She extracts and replaces the iset-manual directory with this one.
%
%  * It is best to tag the commit before you run this.  To tag a commit use
%       git tag VXXXX -m "Comment"
%       git push origin VXXXX
%
%  * In the future you can see all tags using
%      git tag
%      git describe --tags
%
% One copy of the ISET manual is kept at
%   * imageval in the directory /home/imageval/www/public/ISET-Manual-XXX.
%
%   There is a link from ISET-Functions to this directory.  For example, 
%   ln -s ISET-Manual-733 ISET-Functions
%
%   * stanford in brian/public_html/manuals with a link
%   from /u/websk/docs/manuals/ISET, for example
%   ln -s /home/brian/public_html/manuals/ISET-Manual-733 /u/websk/docs/manuals/ISET
%
% Examples:
%  ieManualCreate;
%
%  ieManualCreate('style','Brain')
%  ieManualCreate('style','frame','manualName','thisManual')
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Read varargin

varargin = ieParamFormat(varargin);
p = inputParser;


% For testing
% sourceDefault = {'isetcam/camera','isetcam/utility'};
%
% sourceDefault = {'isetcam'} should get everything.

% The defaults
%{
sourceDefault = {'isetcam/camera','isetcam/color','isetcam/displays', ...
    'isetcam/gui','isetcam/human','isetcam/imgproc','isetcam/main',...
    'isetcam/metrics','isetcam/opticalimage','isetcam/scene', ...
    'isetcam/scripts','isetcam/tutorials','isetcam/utility'};
%}
sourceDefault = {'camera','color','displays', ...
    'gui','human','imgproc','main',...
    'metrics','opticalimage','scene', ...
    'scripts','tutorials','utility'};
% No manual pages for these directories.
ignored = {'manual','CIE','macbeth','dll70','xml','ptb','external','video','.git'};

p.addParameter('style','blue',@ischar);
p.addParameter('manualname','html-manual',@ischar);
p.addParameter('sourcename',sourceDefault,@ischar);
p.parse(varargin{:});

style      = p.Results.style;
sourceName = p.Results.sourcename;
manualName = p.Results.manualname;

%% Change to the directory just above isetcam 
curDir = pwd;
% chdir(fullfile(isetRootPath,'..'));
chdir(fullfile(isetRootPath));

% This should be in the iset branch called admin
if isempty(which('m2html'))
    error('Could not find m2html. In branch admin.');
end

%% Delete any old manual pages
str = [manualName,filesep,'*.*'];
delete(str)

%% Run m2html
switch lower(style)
    case 'default'
        % Same as 'noframe' for now.
        m2html('mfiles',sourceName,'htmldir',manualName,'recursive','on',...
            'ignoredDir',ignored, ...
            'source','off')
        
    case 'brain'
        m2html('mfiles',sourceName,'htmldir',manualName,'recursive','on',...
            'ignoredDir',ignored, ...
            'source','off','template','brain','index','menu')
    case 'frame'
        m2html('mfiles',sourceName,'htmldir',manualName,'recursive','on',...
            'ignoredDir',ignored, ...
            'source','off','template','frame','index','menu')
    case 'blue'
        m2html('mfiles',sourceName,'htmldir',manualName,'recursive','on',...
            'ignoredDir',ignored, ...
            'source','off','template','blue','index','menu')
    otherwise
        error('Unknown style.')
end

% Go back where you were
chdir(curDir);

end
