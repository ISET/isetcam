function [pc,mn] = iePrcomp(data,flag,n)
% Calculate principal components of the columns of a data matrix
%
%  [pc,mn] = iePrcomp(data,flag)
%
% data:  Vectors in columns of the data matrix
% flag:  'basic'         Just calculate the components 
%        'remove mean'   Remove mean and then calculate components
% n:     Number of components to return
%
% pc:    Components are in the columns
% mn:    Mean, if removed
%
% The principal components are calculated by the svd and returning the
% columns of the left singular matrix.
%
% Example:
%   fName = fullfile(isetRootPath,'data','surfaces','Food_Vhrel.mat');
%   fName = fullfile(isetRootPath,'data','surfaces','charts','MunsellSamples_Vhrel.mat');
%   data = ieReadSpectra(fName);
%   [pc1,mn] = iePrcomp(data,'remove mean',4);
%   vcNewGraphWin; plot(pc1); hold on; plot(mn)
%
%   [pc2] = iePrcomp(data,'basic',3);
%   vcNewGraphWin; plot(pc2); 
%
% Copyright Imageval, LLC, 2013

if ieNotDefined('flag'), flag = 'basic'; end
if ieNotDefined('n'), n = []; end

mn = [];

flag = ieParamFormat(flag);
switch flag
    case 'basic'
        data = data*data';
        [pc,~,~] = svd(data);
    case 'removemean'
        mn = mean(data,2);
        data = data - repmat(mn(:),1,size(data,2));
        data = data*data';
        [pc,~,~] = svd(data);
    otherwise
        error('Unknown flag %s\n',flag);
end

% User asked for n components only
if ~isempty(n), pc = pc(:,1:n); end

return

% % The files containing the reflectances are in ISET format, readable by 
% % s = ieReadSpectra(sFiles{1});
% sFiles = cell(4,1);
% sFiles{1} = fullfile(isetRootPath,'data','surfaces','charts','MunsellSamples_Vhrel.mat');
% sFiles{2} = fullfile(isetRootPath,'data','surfaces','Food_Vhrel.mat');
% sFiles{3} = fullfile(isetRootPath,'data','surfaces','DupontPaintChip_Vhrel.mat');
% sFiles{4} = fullfile(isetRootPath,'data','surfaces','skin','HyspexSkinReflectance.mat');
%  
% % % The number of samples from each of the data sets, respectively
% sSamples = [12,12,12,12];    % 
% %  
% % % How many row/col spatial samples in each patch (they are square)
% pSize = 24;    % Patch size
% wave =[];      % Whatever is in the file
% grayFlag = 0;  % No gray strip
% sampling = 'no replacement';
% scene = sceneReflectanceChart(sFiles,sSamples,pSize,wave,grayFlag,sampling);
%  
% % % Show it on the screen
% % vcAddAndSelectObject(scene); sceneWindow;
% reflectance = sceneGet(scene,'reflectance');
