%% data_humanStandards
% Build the human color-standard .mat files from the CVRL tables
%
% Description
%   Reads the tables in data/human/cvrl, which are stored exactly
%   as downloaded, and writes two .mat files for each standard: one for
%   input specified in energy units and one for input specified in quanta
%   (photons).  The _quanta file is always computed here from the _energy
%   file, so the two cannot drift apart.
%
%   File names follow
%
%       <kind>_<source><year>_<field>deg_<basis>.mat
%
%   See README.md in this directory for what each file is.
%
%   Run this script only when adding a standard or refreshing a table.
%   Everything it writes is checked by test_humanStandards.
%
% See also
%   ieReadSpectra, ieReadColorFilter, Quanta2Energy, test_humanStandards

%% Locate the tables and their provenance
humanDir     = fullfile(isetRootPath,'data','human');
cvrlDir      = fullfile(humanDir,'cvrl');
manifest     = readtable(fullfile(cvrlDir,'MANIFEST.tsv'),'FileType','text', ...
    'Delimiter','\t','TextType','char','DatetimeType','text');

%% The standards
% The first letter of a filter name is the ISETCam color hint.
xyz = {'rX','gY','bZ'};
rgb = {'rR','gG','bB'};
lms = {'rLong','gMiddle','bShort'};
lum = {'gLuminance'};

% folder, stem, CVRL table, field size (deg), filter names, description
standards = { ...
    'cmf','cmf_CIE1964_10deg','ciexyz64_1.csv',10,xyz, ...
    'CIE 1964 10-deg XYZ color matching functions'; ...
    'cmf','cmf_SB1955_2deg','sbrgb2.csv',2,rgb, ...
    'Stiles & Burch (1955) 2-deg RGB color matching functions'; ...
    'cmf','cmf_SB1959_10deg','sbrgb10w.csv',10,rgb, ...
    'Stiles & Burch (1959) 10-deg RGB color matching functions, wavelength table with long wavelengths corrected for rod intrusion by Stockman & Sharpe (2000)'; ...
    'cmf','cmf_CIE2012_2deg','lin2012xyz2e_1_7sf.csv',2,xyz, ...
    'CIE 2012 2-deg XYZ color matching functions, a linear transform of the CIE 2006 cone fundamentals'; ...
    'cmf','cmf_CIE2012_10deg','lin2012xyz10e_1_7sf.csv',10,xyz, ...
    'CIE 2012 10-deg XYZ color matching functions, a linear transform of the CIE 2006 cone fundamentals'; ...
    'cones','cones_CIE2006_2deg','linss2_10e_1_8dp.csv',2,lms, ...
    'CIE 2006 2-deg LMS cone fundamentals, the same functions as Stockman & Sharpe (2000)'; ...
    'cones','cones_CIE2006_10deg','linss10e_1_8dp.csv',10,lms, ...
    'CIE 2006 10-deg LMS cone fundamentals, the same functions as Stockman & Sharpe (2000)'; ...
    'luminosity','luminosity_CIE2008_2deg','linCIE2008v2e_1_8dp.csv',2,lum, ...
    'CIE 2008 2-deg photopic luminous efficiency, consistent with the CIE 2006 cone fundamentals'; ...
    'luminosity','luminosity_CIE2008_10deg','linCIE2008v10e_1_8dp.csv',10,lum, ...
    'CIE 2008 10-deg photopic luminous efficiency, consistent with the CIE 2006 cone fundamentals'};

%% Write the energy and quanta files for each standard
for ii = 1:size(standards,1)
    [folder,stem,tableName,fieldDeg,names,description] = standards{ii,:};
    outDir = fullfile(humanDir,folder);
    if ~exist(outDir,'dir'), mkdir(outDir); end

    cvrlTable = readmatrix(fullfile(cvrlDir,tableName),'FileType','text', ...
        'Delimiter',',','NumHeaderLines',0);
    wave   = cvrlTable(:,1);
    energy = cvrlTable(:,2:end);

    % CVRL leaves the S-cone function blank above 615 nm.  We store zeros,
    % the value ieReadSpectra returns outside a file's wavelength range.
    blankNote = '';
    if any(isnan(energy(:)))
        energy(isnan(energy)) = 0;
        blankNote = ' CVRL does not tabulate the S-cone function above 615 nm; those values are stored as 0.';
    end

    row = strcmp(manifest.file,tableName);
    assert(nnz(row) == 1,'%s must appear once in MANIFEST.tsv',tableName);
    source = struct('site','Color & Vision Research Laboratory (CVRL), http://www.cvrl.org', ...
        'table',tableName,'url',manifest.url{row}, ...
        'sha256',manifest.sha256{row},'retrieved',manifest.retrieved{row});

    % Multiplying by the energy per photon gives the function to apply to
    % input specified in photons.
    joulesPerPhoton = Quanta2Energy(wave,ones(numel(wave),1));
    quanta = joulesPerPhoton(:) .* energy;

    % Cone fundamentals are shapes with a peak of 1, so the quantal form is
    % renormalized.  CMFs and luminosity keep the absolute scale, which
    % makes their result the same for energy and photon input.
    if strcmp(folder,'cones')
        energyNorm = 'as published by CVRL: peak of 1 for each cone class on its 0.1-nm table';
        quantaNorm = 'energy data times hc/lambda, then peak of 1 for each cone class';
        quanta     = quanta ./ max(quanta);
    else
        energyNorm = 'as published by CVRL';
        quantaNorm = 'energy data times hc/lambda (joules per photon); absolute scale';
    end

    localSave(fullfile(outDir,[stem,'_energy.mat']),wave,energy, ...
        sprintf('%s. Energy basis. CVRL table %s.%s',description,tableName,blankNote), ...
        names,'energy',energyNorm,fieldDeg,source);
    localSave(fullfile(outDir,[stem,'_quanta.mat']),wave,quanta, ...
        sprintf('%s. Quantal basis, computed from the energy table %s.%s',description,tableName,blankNote), ...
        names,'quanta',quantaNorm,fieldDeg,source);
    fprintf('%s: %d samples, %g to %g nm\n',stem,numel(wave),wave(1),wave(end));
end

%% Helper
function localSave(fName,wavelength,data,comment,filterNames,units,normalization,fieldSizeDeg,source)
% Same fields as ieSaveColorFilter, plus the metadata that identifies the
% standard.  ieSaveColorFilter drops a 'units' field.
dFormat = 'double';
save(fName,'wavelength','data','comment','filterNames','units', ...
    'normalization','fieldSizeDeg','source','dFormat');
end
