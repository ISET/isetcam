function val = ieRdata(func,rd,varargin)
% ISET remote data functions
%
%   val = ieRdata(cmd,[rd],varargin)
%
% INPUTS
%  func - 'create', 'web site','file get','read image', 'dir'
%  rd   - rdata object (optional)
% 
% OUTPUT
%  val
%
% BW ISETBIO Team, Copyright 2015

% Examples:
%{
  rd = ieRdata('create');
  ieRdata('web site');
  ieRdata('dir',rd,'Stryer')
  ieRdata('file get',[],'cText4.mat');
  val = ieRdata('load data',rd,'cText4.mat','scene'); ieAddObject(val.scene); sceneWindow;
  img = ieRdata('read image',rd,'birdIce'); imshow(img);
%}


%% Programming todo
%  rd = RdtClient('isetbio');


%%
if notDefined('func'), func = 'ls'; end
if notDefined('rd')
    % Open up the default and show the user the web-page.
    rd = rdata('base','http://scarlet.stanford.edu/validation/SCIEN');
end

%%
f = ieParamFormat(func);
switch f
    case {'create'}
        % rd = ieRdata('create')
        val = rdata('base','http://scarlet.stanford.edu/validation/SCIEN');

    case {'website'}
        rd.webSite;
        
    case {'ls','dir'}
        % List the files in the remote data site that are in a directory
        % matching a specific string 
        % dirList = ieRdata('ls',rd, DirectoryString);
        if isempty(varargin), error('Pattern required'); end
        val = rd.dirList(varargin{1});
               
    case {'filesprint'}
        % List the directories and files
        rd.fileList;
        
    case 'fileget'
        % outName = ieRdata('get',rd,fname);
        % ieRdata('file get',[],'cText4.mat');
        %
        % One possibility.  Though maybe it should go in tempname/rdata
        if isempty(varargin), error('File string required'); end
        
        fname = varargin{1};
        destDir = fullfile(isetRootPath,'local');
        if ~exist(destDir,'dir')
            disp('Making local directory')
            mkdir(destDir); 
        end
        
        dest = fullfile(destDir,fname);
        val = rd.fileGet(fname,dest);
        
    case 'readimage'
        % rdata('read image', rd, fname);
        if isempty(varargin), error('remote image file name required'); end
        val = rd.imageRead(varargin{1});

    case 'loaddata'
        % ieRdata('load data',rd,fname,variableName)
        %
        % Loads mat-file data, including a specific variable from a
        % matfile.
        %
        % val = ieRdata('load data',rd,'EurasianFemale_shadow.mat');
        % val = ieRdata('load data',rd,'cText4.mat','scene');
        % ieAddObject(val.scene); sceneWindow;
        if isempty(varargin), error('remote data file name required'); end
        dest = ieRdata('file get',rd,varargin{1});
        if length(varargin) == 2, val = load(dest,varargin{2});
        else val = load(dest);
        end

    otherwise
        error('Unknown ieRdata function %s\n',func);
end

end
