function [lgtNames, lgtData, nSamples] = ieLightList(varargin)

%%
p = inputParser;
p.addParameter('wave', 400:10:700, @isnumeric);
p.parse(varargin{:});
wave = p.Results.wave;

%%
lgtFilePath{1} = fullfile(isetRootPath, 'data', 'lights');
lgtFilePath{2} = fullfile(isetRootPath, 'data', 'lights', 'gretag');

lgtFileInfo{1} = dir(fullfile(lgtFilePath{1}, '*.mat'));
lgtFileInfo{2} = dir(fullfile(lgtFilePath{2}, '*.mat'));

lgtNames = {};
lgtData = {};
nSamples = [];

cntLgt = 0;

for nn=1:numel(lgtFileInfo)
    curLgtFileInfo = lgtFileInfo{nn};
    for ii=1:numel(curLgtFileInfo)
        switch curLgtFileInfo(ii).name
            case {'cct.mat'}
                continue;
            otherwise
                spd = ieReadSpectra(curLgtFileInfo(ii).name, wave);
                spd(spd == 0) = 1e-8;
                cntLgt = cntLgt + 1;
                lgtNames{cntLgt} = curLgtFileInfo(ii).name;
                lgtData{cntLgt} = spd;
                nSamples(cntLgt) = size(spd, 2);
        end
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