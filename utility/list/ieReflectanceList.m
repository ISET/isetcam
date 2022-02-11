function [reflFileNames, reflData, nSamples] = ieReflectanceList(varargin)
%%
% There are three places to load in the reflectances:
%   isetcam/data/surfaces/reflectances
%   isetcam/data/surfaces/skin
%   isetcam/data/surfaces/esser

%{
% Example:
[rNames, nSamples] = ieReflectanceList;
%}

p = inputParser;
p.addParameter('wave', 400:10:700, @isnumeric);
p.parse(varargin{:});
wave = p.Results.wave;
%%
reflFilePath{1} = fullfile(isetRootPath, 'data', 'surfaces', 'reflectances');
reflFilePath{2} = fullfile(isetRootPath, 'data', 'surfaces', 'reflectances','skin');
reflFilePath{3} = fullfile(isetRootPath, 'data', 'surfaces', 'reflectances', 'esser');

% These are measurements in folder
reflFileInfo{1} = dir(fullfile(reflFilePath{1}, '*.mat'));
reflFileInfo{2} = dir(fullfile(reflFilePath{2}, '*.mat'));
reflFileInfo{3} = dir(fullfile(reflFilePath{3}, 'esserChart.mat'));

% reflFileName = cell(1, numel(reflFileInfo));
reflFileNames = {};
reflData = {};
% sSamples = zeros(1, numel(reflFileName));
nSamples = [];
cntRefl = 0;
for nn=1:numel(reflFileInfo)
    curReflFileInfo = reflFileInfo{nn};
    for ii=1:numel(curReflFileInfo)
        tmpName = curReflFileInfo(ii).name;
        curData = ieReadSpectra(tmpName, wave, 1);
        if max(curData(:)) <= 1
            cntRefl = cntRefl + 1;
            reflFileNames{cntRefl} = tmpName;
            nSamples(cntRefl) = size(curData, 2);
            % fprintf('Max reflectance for %s: is : %f\n', tmpName, max(curData(:)));
        end
    end
end
end