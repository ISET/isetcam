function imageType = ieImageType(fullName)
%Determine the type of image in a file
%
%   imageType = ieImageType(fullName)
%
% Description
% - Check the file extensions for an RGB type (e.g. jpeg,jpg,tif,gif,bmp).
% - If not, read the directory name. If it contains one of the image type
%   strings (see below), return that string. 
% - Finally, ask the user to identify the type of data. 
%
% Examples:
%{
   fname = fullfile(isetRootPath,'data','images','Monochrome','Fruit-hdrs.mat');
   ieImageType
   fname = fullfile(isetRootPath,'data','images','Multispectral','Fruit-hdrs.mat');
   ieImageType(fname)
   fname = fullfile(isetRootPath,'data','images','Fruit-hdrs.png');
   ieImageType(fname)
%}
%
% Copyright ImagEval Consultants, LLC, 2003.

[imagePath,~,ext] = fileparts(fullName);

% Try to determine the type based on the extension
switch(lower(ext))
    case {'.jpg','.jpeg','.tif','.tiff','.bmp','.gif','.png'}
        
        % Two special tests for monochrome targets
        test1 = fullfile('data','images','targets');
        if ieContains(lower(fullName),test1) %#ok<*STRIFCND>
            % Could be an EIA target.
            imageType = 'monochrome';
        elseif ieContains(lower(fullName),'monochrome')
            imageType = 'monochrome';
        else
            % Most likely it is rgb
            imageType = 'rgb';
        end
        return;
    otherwise
        % Just pass through
end

% Check the path string for a clue
imageType = '';
imagePath = lower(imagePath);
if ieContains(imagePath,'monochrome'), imageType = 'monochrome';
elseif ieContains(imagePath,'multispectral'), imageType = 'multispectral';
elseif ieContains(imagePath,'rgb'), imageType = 'rgb';
end
if ~isempty(imageType), return; end

% If nothing in the path matches one of the known types, ask the user.
% This could be ieSelectString The Matlab fonts are awful in the
% listdlg box.  Maybe some day they will be nicer.
imTypes = {'monochrome','rgb','multispectral'};
[v, ok] = listdlg(...
    'PromptString','Select file type',...
    'SelectionMode','single', ...
    'ListString',imTypes);

if ok, imageType = imTypes{v};
else,  disp('User canceled'); imageType = ''; return; 
end

end
