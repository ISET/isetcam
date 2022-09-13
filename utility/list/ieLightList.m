function [lgtNames, lgtData, nSamples] = ieLightList(varargin)

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('lightdir', fullfile(isetRootPath, 'data', 'lights'), @ischar);
p.addParameter('wave', 400:10:700, @isnumeric);
p.parse(varargin{:});
wave = p.Results.wave;
lightDir = p.Results.lightdir;
%%
%{
lgtFilePath{1} = fullfile(isetRootPath, 'data', 'lights');
lgtFilePath{2} = fullfile(isetRootPath, 'data', 'lights', 'gretag');

lgtFileInfo{1} = dir(fullfile(lgtFilePath{1}, '*.mat'));
lgtFileInfo{2} = dir(fullfile(lgtFilePath{2}, '*.mat'));
%}
lgtFileInfo = dir(fullfile(lightDir, '**/*.mat'));
lgtNames = {};
lgtData = {};
nSamples = [];

cntLgt = 0;

for ii=1:numel(lgtFileInfo)
    switch lgtFileInfo(ii).name
        case {'cct.mat'}
            continue;
        otherwise
            spd = ieReadSpectra(lgtFileInfo(ii).name, wave);
            spd(spd == 0) = 1e-8;
            cntLgt = cntLgt + 1;
            lgtNames{cntLgt} = lgtFileInfo(ii).name;
            lgtData{cntLgt} = spd;
            nSamples(cntLgt) = size(spd, 2);
    end
end

%%
%{
wave = 400:10:700;
name1 = 'Fluorescent.mat';
name2 = 'Fluorescent7.mat';

fluo1 = ieReadSpectra(name1, wave);
fluo2 = ieReadSpectra(name2, wave);
ieNewGraphWin;
plot(wave, fluo1); hold on;
plot(wave, fluo2);

lgt = 'ledSixSpectra.mat';
spd1 = ieReadSpectra(lgt, wave);
ieNewGraphWin;
plot(wave, spd1);
%}
end