function tests = test_humanStandards()
% Check the human color standards against the CVRL tables they came from
%
% See also
%   data_humanStandards, ieReadSpectra
tests = functiontests(localfunctions);
end

function testEveryTableIsInManifestWithMatchingChecksum(testCase)
%% The stored CVRL tables are the ones that were downloaded

testCase.assumeTrue(usejava('jvm'),'SHA-256 uses Java.');
[cvrlDir,manifest] = localCVRL();
stored = dir(fullfile(cvrlDir,'*.csv'));
assert(isequal(sort({stored.name})',sort(manifest.file)));

for ii = 1:height(manifest)
    assert(strcmp(localSHA256(fullfile(cvrlDir,manifest.file{ii})),manifest.sha256{ii}), ...
        'Checksum mismatch for %s',manifest.file{ii});
end

end

function testEnergyFilesHoldTheirCVRLTableUnchanged(~)
%% Each energy file is its table, with blank cells stored as zero

files = localStandardFiles('energy');
assert(numel(files) == 9);

for ii = 1:numel(files)
    s = load(files{ii});
    t = localTable(s.source.table);
    expected = t(:,2:end);
    expected(isnan(expected)) = 0;
    assert(isequal(s.wavelength(:),t(:,1)),'Wavelengths differ in %s',files{ii});
    assert(isequal(s.data,expected),'Values differ in %s',files{ii});
end

end

function testQuantaFilesAreComputedFromEnergyFiles(~)
%% Quanta data are energy data times the energy per photon

tolerance = 1e-12;
files = localStandardFiles('energy');

for ii = 1:numel(files)
    e = load(files{ii});
    q = load(strrep(files{ii},'_energy.mat','_quanta.mat'));
    joulesPerPhoton = Quanta2Energy(e.wavelength,ones(numel(e.wavelength),1));
    expected = joulesPerPhoton(:) .* e.data;
    if contains(files{ii},'cones_'), expected = expected ./ max(expected); end
    assert(isequal(q.wavelength,e.wavelength));
    assert(max(abs(q.data(:) - expected(:))) <= tolerance*max(abs(expected(:))), ...
        'Quanta data are stale in %s',files{ii});
end

end

function testQuantaFilesAgreeWithCVRLQuantalTables(~)
%% Our energy-to-quanta conversion reproduces CVRL's published quantal tables

% CVRL's log tables have 8 decimal places.
tolerance = 1e-6;
pairs = { ...
    'cones_CIE2006_2deg_quanta',       'ss2_10q_1_8dp.csv'; ...
    'cones_CIE2006_10deg_quanta',      'ss10q_1_8dp.csv'; ...
    'luminosity_CIE2008_2deg_quanta',  'logCIE2008v2q_1_8dp.csv'; ...
    'luminosity_CIE2008_10deg_quanta', 'logCIE2008v10q_1_8dp.csv'};

for ii = 1:size(pairs,1)
    q = load(pairs{ii,1});
    t = localTable(pairs{ii,2});
    reference = 10 .^ t(:,2:end);
    isTabulated = ~isnan(reference);
    ours = q.data ./ max(q.data);
    reference = reference ./ max(reference);
    assert(isequal(q.wavelength(:),t(:,1)));
    relativeError = abs(ours(isTabulated) - reference(isTabulated)) ./ reference(isTabulated);
    assert(max(relativeError) < tolerance,'%s differs from %s',pairs{ii,1},pairs{ii,2});
end

end

function testFieldSizeLabelsPairCmfWithMatchingCones(~)
%% CIE 2012 XYZ are linear in the cones of the same field size, not the other

fits = @(cones,cmf) max(abs(cones*(cones\cmf) - cmf),[],'all');
xyz2   = load('cmf_CIE2012_2deg_energy');
xyz10  = load('cmf_CIE2012_10deg_energy');
lms2   = load('cones_CIE2006_2deg_energy');
lms10  = load('cones_CIE2006_10deg_energy');

isTabulated = lms2.wavelength(:) <= 615;
residual = @(cones,cmf) fits(cones.data(isTabulated,:),cmf.data(isTabulated,:));

correctTolerance = 1e-4;
wrongAtLeast     = 1e-2;
assert(residual(lms2,xyz2)   < correctTolerance);
assert(residual(lms10,xyz10) < correctTolerance);
assert(residual(lms10,xyz2)  > wrongAtLeast);
assert(residual(lms2,xyz10)  > wrongAtLeast);

end

function testMetadataAgreesWithFileName(~)
%% The name, the units field and the field size all say the same thing

files = [localStandardFiles('energy');localStandardFiles('quanta')];
assert(numel(files) == 18);

for ii = 1:numel(files)
    [~,stem] = fileparts(files{ii});
    tokens = regexp(stem,'^(cmf|cones|luminosity)_[A-Za-z]+\d{4}_(\d+)deg_(energy|quanta)$','tokens','once');
    assert(~isempty(tokens),'Name does not follow the convention: %s',stem);

    s = load(files{ii});
    assert(s.fieldSizeDeg == str2double(tokens{2}),'Field size disagrees in %s',stem);
    assert(strcmp(s.units,tokens{3}),'Units disagree in %s',stem);
    assert(~any(isnan(s.data(:))),'NaN in %s',stem);
    assert(size(s.data,1) == numel(s.wavelength));
    assert(size(s.data,2) == numel(s.filterNames));
end

end

function testConeEnergyFilesPeakAtOne(~)
%% The cone fundamentals have the peak the metadata states

% CVRL sets the peak to 1 on its 0.1-nm table.  That peak usually falls
% between the 1-nm samples, so the largest sample is slightly below 1.
tolerance = 1e-4;
for stem = {'cones_CIE2006_2deg_energy','cones_CIE2006_10deg_energy'}
    s = load(stem{1});
    assert(max(abs(max(s.data) - 1)) < tolerance,'Peak differs from 1 in %s',stem{1});
end

end

function testFilesLoadByName(~)
%% The usual readers find the files by name alone

wave = 400:10:700;
assert(isequal(size(ieReadSpectra('cmf_CIE1964_10deg_quanta',wave)),[numel(wave) 3]));
[cones,names] = ieReadColorFilter(wave,'cones_CIE2006_2deg_quanta');
assert(isequal(size(cones),[numel(wave) 3]));
assert(strcmp(names{1},'rLong'));

end

function testFileNamesAreUniqueAcrossFolders(~)
%% MATLAB finds these files by name, so no two can share one

found = dir(fullfile(isetRootPath,'data','human','**','*.mat'));
names = {found.name};
assert(numel(unique(names)) == numel(names));

end

function testExistingCIEFilesAreTheStandardsDocumented(~)
%% The older files agree with the CVRL tables named in README.md

% Y at 547 nm is 0.9874812 in the older files; the published value is
% 0.9874182.  Drop the exception when those files are rebuilt.
knownError = 547;
tolerance  = 1e-9;
existing = { ...
    'XYZ',                'ciexyz31_1.csv', knownError; ...
    'vlambda',            'vl1924e_1.csv',  knownError; ...
    'luminosityJudd',     'vlje.csv',       []; ...
    'scotopicLuminosity', 'scvle.csv',      []; ...
    'macularPigment',     'macss_1.csv',    []; ...
    'lensDensity',        'lensss_1.csv',   []; ...
    'coneAbsorbance',     'ssabance_1.csv', []};

for ii = 1:size(existing,1)
    s = load([existing{ii,1},'.mat']);
    t = localTable(existing{ii,2});
    [wave,ia,ib] = intersect(s.wavelength(:),t(:,1));
    keep = ~ismember(wave,existing{ii,3});
    difference = abs(s.data(ia(keep),:) - t(ib(keep),2:end));
    assert(numel(wave) > 30,'Too little overlap for %s',existing{ii,1});
    assert(max(difference,[],'all') < tolerance,'%s differs from %s',existing{ii,1},existing{ii,2});
end

end

function testExistingStockmanFilesAreSMJ1993(~)
%% The older stockman files are the 1993 tables, not the CIE 2006 ones

tolerance = 1e-12;
existing = {'stockman','smj2_10.csv'; 'stockman-StilesBurch','smj2.csv'};

for ii = 1:size(existing,1)
    s = load([existing{ii,1},'.mat']);
    t = localTable(existing{ii,2});
    [~,ia,ib] = intersect(s.wavelength(:),t(:,1));
    ours = s.data(ia,:) ./ max(s.data(ia,:));
    reference = 10 .^ t(ib,2:end);
    reference = reference ./ max(reference);
    assert(max(abs(ours - reference),[],'all') < tolerance,'%s differs from %s',existing{ii,1},existing{ii,2});
end

end

function testSmithPokornyFileUsesJudd1951(~)
%% The older Smith-Pokorny file is built on Judd (1951), not Judd-Vos

tolerance = 1e-4;
s = load('SmithPokornyCones.mat');
t = localTable('ciexyzj.csv');
[~,ia,ib] = intersect(s.wavelength(:),t(:,1));
X = t(ib,2);  Y = t(ib,3);  Z = t(ib,4);
expected = [0.15514*X + 0.54312*Y - 0.03286*Z, -0.15514*X + 0.45684*Y + 0.03286*Z, 0.00801*Z];
ours = s.data(ia,:) ./ max(s.data(ia,:));
assert(max(abs(ours - expected ./ max(expected)),[],'all') < tolerance);

end

%% Helpers
function [cvrlDir,manifest] = localCVRL()
cvrlDir  = fullfile(isetRootPath,'data','human','cvrl');
manifest = readtable(fullfile(cvrlDir,'MANIFEST.tsv'),'FileType','text', ...
    'Delimiter','\t','TextType','char','DatetimeType','text');
end

function t = localTable(tableName)
t = readmatrix(fullfile(localCVRL(),tableName),'FileType','text', ...
    'Delimiter',',','NumHeaderLines',0);
end

function files = localStandardFiles(basis)
found = dir(fullfile(isetRootPath,'data','human','*',['*_',basis,'.mat']));
files = fullfile({found.folder}',{found.name}');
end

function hash = localSHA256(fileName)
fid = fopen(fileName,'r');
bytes = fread(fid,inf,'*uint8');
fclose(fid);
digest = java.security.MessageDigest.getInstance('SHA-256');
hash = lower(reshape(dec2hex(typecast(digest.digest(bytes),'uint8'),2)',1,[]));
end
