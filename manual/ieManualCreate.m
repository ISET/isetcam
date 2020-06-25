function ieManualCreate(varargin)
% Use m2html to create a manual of all ISET functions
%
% Brief synopsis
%   ieManualCreate(varargin)
%
% Description
%  This script finds ISETCam and runs m2html. A new manual of HTML files
%  will be created in the ISETCam  directory local/manuals.
%
% Inputs:
%   N/A
%
% Optional key/value (default)
%  style      - Output style ('default')
%  manualName - Output directory name ('iManual')
%  sourceFiles - Input directory ('isetcam')
%
% Outputs
%  A directory with the manual pages is created.  Click on index.html to
%  see a browser window that explores the manual pages.
%
% Notes:
%  * You must have m2html on your path.  Normally I do this by maintaining
%  m2html in the 'admin' branch of ISETCam
%  * I edited m2html to ignore a number of different directories (like
%  external).
%
% Once the manual is created, we put it somewhere public where we can
% access it from the ISETCam the wiki page. We can't put it in the wiki
% page because of the way GitHub handles HTML files.
%
% I create a tar file this way:
%
%    tar cvf iManual.tar iManual
%
%  * It is best to tag the commit before you run this.  To tag a commit use
%       git tag VXXXX -m "Comment"
%       git push origin VXXXX
%
%  * In the future you can see all tags using
%      git tag
%      git describe --tags
%
%   * We are serving the manual pages from black at Stanford
%
%           stanford in brian/public_html/manuals with a link
%
%   from /u/websk/docs/manuals/ISET, for example
%   ln -s /home/brian/public_html/manuals/ISET-Manual-733 /u/websk/docs/manuals/ISET
%
% See also
%   ieManualViewer

% Examples:
%{
  % The default style is frame, with source included. The link files is
  % index.html
  ieManualCreate;
%}
%{
  ieManualCreate('press',true);
%}
%{
  sourceFiles = {'camera'};
  ieManualCreate('style','brain', ...
                 'manualName',fullfile(isetRootPath,'local','testBrainCamera'),...
                  'source files',sourceFiles)
%}
%{
  ieManualCreate('style','frame','press',false)
%}
%{
  ieManualCreate('style','frame','manualName','thisManual')
%}
%{
  sourceFiles = {'scripts'};
  ieManualCreate('style','frame',...
                 'manualName',fullfile(isetRootPath,'local','testScripts'),...
                 'source files',sourceFiles, ...
                 'source', 'on');
%}
%{
  sourceFiles = {'tutorials'};
  ieManualCreate('style','frame',...
                 'manualName',fullfile(isetRootPath,'local','testTutorials'),...
                 'source files',sourceFiles, ...
                 'source','on');
%}
%{
  sourceFiles = {'sensor'};
  ieManualCreate('source files',sourceFiles);
%}

%% Read varargin

varargin = ieParamFormat(varargin);
p = inputParser;

% Default directories (recursive)
sourceFilesDefault = {'camera','color','displays', ...
    'human','imgproc','main',...
    'metrics','opticalimage','scene', ...
    'sensor','scripts','tutorials','utility'};

% Default ignore directories 
ignored = {'gui','manual','CIE','macbeth','dll70','xml','ptb','external','video','.git'};

p.addParameter('style','frame',@ischar);
p.addParameter('manualname',fullfile(isetRootPath,'local','manuals'),@ischar);
p.addParameter('sourcefiles',sourceFilesDefault,@iscell);
p.addParameter('source','on',@ischar);
p.addParameter('press',false, @islogical);

p.parse(varargin{:});

style       = p.Results.style;
sourceFiles = p.Results.sourcefiles;
manualName  = p.Results.manualname;
press       = p.Results.press;
source      = p.Results.source;

%% Change to the directory just above isetcam
curDir = pwd;
% chdir(fullfile(isetRootPath,'..'));
chdir(fullfile(isetRootPath));

% This should be in the iset branch called admin
if isempty(which('m2html'))
    error('Could not find m2html. In branch admin.');
end

%%
fprintf('Writing out to %s with style %s\n',manualName,style);
if press
    fprintf('Press key to begin: ');
    pause;
end

%% Delete any old manual pages
str = [manualName,filesep,'*.*'];
delete(str)

%% Run m2html
switch lower(style)
    case {'frame','default'}
        % Creates an index.html file.
        m2html('mfiles',sourceFiles,...
            'htmldir',manualName,...
            'recursive','on',...
            'ignoredDir',ignored, ...
            'source',source,...
            'template','frame',...
            'index','menu')
        
    case 'brain'
        m2html('mfiles',sourceFiles,...
            'htmldir',manualName,...
            'recursive','on',...
            'ignoredDir',ignored, ...
            'source',source,...
            'template','brain',...
            'index','menu')
        
    case 'blue'
        m2html('mfiles',sourceFiles,'htmldir',manualName,...
            'recursive','on',...
            'ignoredDir',ignored, ...
            'source',source,...
            'template','blue',...
            'index','menu')
        
    otherwise
        error('Unknown style.')
end

% Go back where you were
chdir(curDir);

end
