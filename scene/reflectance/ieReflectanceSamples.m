function [reflectances, sSamples, wave] = ieReflectanceSamples(sFiles,sSamples,wave,sampling)
% Return a sample of surface reflectance functions
%
% Synopsis
%  [reflectances, sSamples, wave] = ieReflectanceSamples(sFiles,sSamples,[wave],[sampling])
%
% Brief 
%  The surface reflectances are drawn from the cell array of names in
%  sFiles{} and returned in the columns of the matrix reflectances.
%
% INPUTS
%
%  sFiles:   Cell array of file names with reflectance spectra.  If none are
%           supplied then the defaults are 24 samples from each of 4
%           sources (96 reflectances in total)
%
%     'MunsellSamples_Vhrel.mat'
%     'Food_Vhrel.mat'
%     'DupontPaintChip_Vhrel.mat'
%     'HyspexSkinReflectance.mat'
%
%  sSamples: Either
%      - A vector indicating how many surfaces to sample from each file
%      - A cell array, each cell specifies the exact samples from each file
%
%  wave:     wavelength Samples (400:10:700)
%  sampling: The samples are drawn probabilistically.  
%            'r' sample sSamples(i) from the file with replacement (default).
%            'all' Use all the data (no sampling), sSamples is ignored
%            Anything else means sample sSamples(i) without replacement. 
%
% RETURNS:
%  reflectances:  Columns of reflectance functions
%
% See also: 
%  macbethChartCreate, sceneReflectanceChart

% Example:
%{
  r = ieReflectanceSamples;
%}
%{
  [r, sSamples] = ieReflectanceSamples([],[],400:5:700,'no replacement');
  r2 = ieReflectanceSamples([],sSamples,400:5:700,'no replacement');
  ieNewGraphWin; plot(r(:),r2(:),'.')
%}
%{
  sFiles = cell(1,2);
  sFiles{1} = fullfile(isetRootPath,'data','surfaces','reflectances','MunsellSamples_Vhrel.mat');
  sFiles{2} = fullfile(isetRootPath,'data','surfaces','reflectances','DupontPaintChip_Vhrel.mat');
  sSamples = [12,12]*5;
  wave = 400:10:700;
  [reflectances, sSamples] = ieReflectanceSamples(sFiles,sSamples,wave);
  iePlot(wave,reflectances); grid on
%}

%%
if ieNotDefined('sFiles')
    % Make up a default list
    sFiles = cell(1,4);
    sFiles{1} = which('MunsellSamples_Vhrel.mat');
    sFiles{2} = which('Food_Vhrel.mat');
    sFiles{3} = which('DupontPaintChip_Vhrel.mat');
    sFiles{4} = which('HyspexSkinReflectance.mat');
    if ~exist('sSamples','var') || isempty(sSamples)
        sSamples = [24 24 24 24];
    end
end
nFiles = length(sFiles);

if ieNotDefined('sSamples'), sSamples = zeros(1,nFiles);
elseif length(sSamples) ~= nFiles
    error('Mis-match between number of files and sample numbers');
end
if ieNotDefined('wave'), wave = 400:10:700; end
if ieNotDefined('sampling'), sampling = 'r'; end % With replacement

% sSamples might be a vector, indicating the number of samples, or a cell
% array specifying which samples.
if iscell(sSamples)
    nSamples = 0;
    for ii=1:nFiles
        nSamples = length(sSamples{ii}) + nSamples;
    end
else
    nSamples = sum(sSamples);
end

% Read the surface reflectance data. At the moment, we allow duplicates,
% though we should probably change this.
last = 0;
sampleList = cell(1,nFiles);
reflectances = zeros(length(wave),nSamples);

for ii=1:nFiles
    
    allSurfaces = ieReadSpectra(sFiles{ii},wave);
    nRef = size(allSurfaces,2);
    
    % Generate the random list of surfaces.  They are sampled with
    % replacement.
    if ~iscell(sSamples)
        if strncmp(sampling,'r',1)  
            % Sample with replacement
            % randi doesn't exist in 2008 Matlab.
            if exist('randi','builtin')
                sampleList{ii} = randi(nRef,[1 sSamples(ii)]);
            else
                sampleList{ii} = ceil(rand([1 sSamples(ii)])*nRef);
            end
        elseif strcmpi(sampling,'all')
            % Use them all
            sampleList{ii} = 1:nRef;
        else  
            % Without replacement
            if sSamples(ii) > nRef, error('Not enough samples in %s\n',sFiles{ii});
            else
                list = randperm(nRef);
                sampleList{ii} = list(1:sSamples(ii));
            end
        end
        % fprintf('Choosing %d of %d samples\n',sSamples(ii),nRef);
        % fprintf('Unique samples:   %d\n',length(unique(sampleList{ii})));
    else
        % User sent in the specific list of samples for each file
        sampleList{ii} = sSamples{ii};
    end
    
    this = last + 1;
    last = this + (length(sampleList{ii}) - 1);
    reflectances(:,this:last) = allSurfaces(:,sampleList{ii});
end

if max(reflectances(:)) > 1, error('Bad reflectance data'); end

% With this variable and the the filenames, you can run the same function
% and get the same reflectances.
sSamples = sampleList;

return

