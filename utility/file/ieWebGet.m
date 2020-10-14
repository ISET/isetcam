%% Download a file from the Stanford web site
%

function ieWebGet(varargin)

%{
filetype - hyperspectral, multispectral, hdr, pbrt, ....
readonly - (possible for images)
{dir,ls} - use webread rather than websave to list the directory
%}
%{
   saveFile       = ieWebGet('remote file','chessSet.zip','type','V3');
   saveFile       = ieWebGet('remote file','barbecue.jpg','type','hdr');
   dataFromFile   = ieWebGet('thisMatFile','type','hyperspectral','readonly',true);
   listOfTheFiles = ieWebGet('type','V3','dir',true)
   % Bring up the browser   
   url            = ieWebGet('type','hyperspectral','browse',true); 
%}
%{
  listOfTheFiles = ieWebGet('','type','V3','dir',true)
  % determine which ii value
  dataFromFile   = ieWebGet(listOfTheFiles{ii},'type','V3','readonly',true);
%}

switch filetype
    baseURL = 'http://web.stanford.edu/people/david81'
    baseURL = 'http://web.stanford.edu/people/wandell/data'
end

websave(localFileName,[baseURL,remoteFileName])

% chdir(fullfile(isetbioRootPath,'local'));
websave('chessSet.zip','http://web.stanford.edu/people/wandell/data/chessSet.zip');

end