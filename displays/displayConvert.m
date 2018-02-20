function d = displayConvert(ctDisp, varargin)
%% function d = displayConvert(ctDisplay)
%    Convert the ctToolbox display structure to the isetbio display
%    structure
%
%  Inputs:
%    ctDisplay  - ctToolbox display calibration file name or display
%                 structure
%    varargin   - could contain:
%                 - sample wavelength (varargin{1})
%                 - output file name. (varargin{2}) This contains only file
%                   name, not full the path. The file will be stored in
%                   isetbio/isettools/data/display
%                 - force overwrite (varargin{3})
%                   if filename already exist, whether or not to overwrite
%                   the file
%                 - display name
%                 
%  Outputs:
%    d          - ISETBio / ISET display structure
%
%  Example:
%    d = displayConvert('Dell Chevron Pixels Pixel Size 26');
%
% (HJ) May, 2014

%% Init
if ieNotDefined('ctDisp'), error('ctToolbox display structure required'); end
if ischar(ctDisp), ctDisp = load(ctDisp); ctDisp = ctDisp.vDisp; end
if length(varargin) > 2, ow = varargin{3}; else ow = false; end

%% Convert
% Create default display structure
d = displayCreate;

% Set display name
d = displaySet(d, 'name', ctDisp.m_strDisplayName);

% Set sampling wavelength
d = displaySet(d, 'wave', ...
        ctDisp.sPhysicalDisplay.m_objCDixelStructure.m_aWaveLengthSamples);
    
% Set spectral power distribution
d = displaySet(d, 'spd', ...
    ctDisp.sPhysicalDisplay.m_objCDixelStructure.m_aSpectrumOfPrimaries');

% Set gamma table
gTable = cell2mat(...
        ctDisp.sPhysicalDisplay.m_objCDixelStructure.m_cellGammaStructure);
gTable = cat(1, gTable.vGammaRampLUT)';
d = displaySet(d, 'gTable', gTable);

% Set psf structure
psfs = cell2mat(...
        ctDisp.sPhysicalDisplay.m_objCDixelStructure.m_cellPSFStructure);
psfImg = zeros([20 20 size(gTable, 2)]);
for ii = 1 : size(gTable, 2)
    psfImg(:,:,ii) = imresize(psfs(ii).sCustomData.aRawData, [20 20]);
    psfImg(:,:,ii) = psfImg(:,:,ii) / sum(sum(psfImg(:,:,ii)));
end

d = displaySet(d, 'psfs', psfImg);

% Set dpi
d = displaySet(d, 'dpi', 25.4 / ...
        ctDisp.sPhysicalDisplay.m_objCDixelStructure.m_fPixelSizeInMmX);

% Set viewing distance
d = displaySet(d, 'viewing distance', ...
        ctDisp.sViewingContext.m_fViewingDistance);

% Refresh rate
d = displaySet(d, 'refresh rate', ...
        ctDisp.sPhysicalDisplay.m_fVerticalRefreshRate);
    
%% Adjust sampling wavelength
if ~isempty(varargin) && ~isempty(varargin{1})
    newWave = varargin{1}(:);
    oldWave = displayGet(d, 'wave');
    oldSpd = displayGet(d, 'spd');
    newSpd = interp1(oldWave,oldSpd,newWave);
    d = displaySet(d,'wave',newWave);
    d = displaySet(d,'spd',newSpd);
end

%% Adjust name
if length(varargin) > 3 && ~isempty(varargin{4})
    d = displaySet(d, 'name', varargin{4});
end

%% Save
if length(varargin) > 1 && ~isempty(varargin{2})
    fname = varargin{2};
    [~, fname, ~] = fileparts(fname);
    fname = fullfile(isetRootPath, 'data', 'displays', fname);
    if ~exist(fname, 'file') || ow
        save(fname, 'd');
    else
        warning('File already exist. Try other name or overwrite flag');
    end
end

%% END