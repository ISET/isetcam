function thisDir = iePublish(tList,section,varargin)
% Publish the files in the tutorial list (tList)
%
% Synopsis
%    thisDir = iePublish(tList,section,varargin)
%
% Inputs:
%  tList - Cell array of ISETCam scripts or tutorials
%  section - scene,oi,sensor,ip,color,metrics,display
%
% Optional key/value pairs
%  pdf     - publish pdf (default: true)
%  html    - publish html (default: true)
%  style sheet - Style sheet file (default: mxdom2simplehtml.xsl)
%
% Returns
%  thisDir - The directory where the PDF and HTML files were stored
%
% See also
%   ieTutorialCreate
%

%%  Initialize the style sheet file name

styleSheet = fullfile(isetRootPath,'manual','mxdom2simplehtml.xsl');
if ~exist(styleSheet,'file')
    error('Style sheet file missing');
end

%% Parse
varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('tList',@iscell);
vFunc = @(x)(ismember(x,{'scene','oi','sensor','ip','color','metrics','display'}));
p.addRequired('section',vFunc);

p.addParameter('pdf',true,@islogical);
p.addParameter('html',true,@islogical);
p.addParameter('stylesheet',styleSheet,@ischar);

p.parse(tList,section,varargin{:});

pdf        = p.Results.pdf;
html       = p.Results.html;
styleSheet = p.Results.stylesheet;

%% Change into the directory for this section
if ~exist(section,'dir')
    mkdir(section); 
    fprintf('Created directory %s in %s\n',section,pwd); 
end
chdir(section);

%%  First check you can find all the files
for ii=1:length(tList)
    if isempty(which(tList{ii}))
        error('can not find %s\n',tList{ii});
    end
end

%% Now do the work
for tt=1:length(tList)
    fprintf('Processing %s\n',tList{tt});
    
    localFile = fullfile(pwd,tList{tt});
    if exist(localFile,'file')
        delete(localFile);
    end
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt});
    else
        copyfile(tFile,localFile);
    end
    try
        if html, publish(localFile, 'stylesheet', styleSheet,'maxWidth',512); end
    catch
        fprintf('Failed to publish html %s\n',tList{tt});
    end
    try
        if pdf, publish(localFile,'pdf'); end
    catch
        fprintf('Failed to publish pdf %s\n',tList{tt});
    end
    delete(localFile);
end

%% Move the files out of html into the directory above

movefile('html/*','.');
rmdir('html');

thisDir = pwd;

end
