function report = ieContentsUpdate(folder, varargin)
% Refresh a Contents.m file against the directory it describes
%
% Synopsis
%   report = ieContentsUpdate(folder, ...)
%
% Brief description
%   A Contents.m file answers "help <folder>". It goes stale silently,
%   because nothing checks it against the directory. This refreshes one.
%
%   Only .m entries can be generated: their description is the H1 line of
%   the file, which lives next to the code and is therefore maintained.
%   Entries naming a subdirectory or a data file have no H1 to read, so
%   their hand-written descriptions are editorial content and are preserved
%   exactly. Nothing is invented for an undocumented subdirectory or data
%   file; it is reported so a person can describe it.
%
%   Actions taken per entry:
%     .m file that exists      - description refreshed from its H1 line
%     other target that exists - kept verbatim
%     target that is missing   - removed, and named in the report
%     .m file not yet listed   - added, using its H1 line
%
%   The header block at the top of the file and any section headers are
%   preserved in their original order. A section whose entries have all
%   disappeared is removed.
%
% Inputs
%   folder - Directory holding the Contents.m file. Default: pwd
%
% Optional key/value pairs
%   dryrun  - Report what would change without writing. Default: false
%   verbose - Print the report. Default: true
%   subdirs - Also document .m files one level down, grouping them under a
%             '(subdir name)' section header. Use this where the scripts a
%             Contents.m describes have moved into subdirectories. A new
%             section header is written without a description, since there
%             is nothing to generate one from. Default: false
%
% Returns
%   report - Struct with fields file, refreshed, kept, added, removed, and
%            undocumented. Each is a cell array of entry names, except file.
%
% Examples:
%{
   % See what would change, without touching the file
   ieContentsUpdate(fullfile(isetbioRootPath,'utility'), 'dryrun', true);
%}
%{
   % Refresh it
   ieContentsUpdate(fullfile(isetbioRootPath,'utility'));
%}
%
% See also
%   ieContentsCheck

p = inputParser;
p.addRequired('folder', @(x)(ischar(x) || isstring(x)));
p.addParameter('dryrun', false, @islogical);
p.addParameter('verbose', true, @islogical);
p.addParameter('subdirs', false, @islogical);
p.parse(folder, varargin{:});

folder = char(p.Results.folder);
dryRun = p.Results.dryrun;
beVerbose = p.Results.verbose;
includeSubdirs = p.Results.subdirs;

contentsFile = fullfile(folder, 'Contents.m');
if ~isfile(contentsFile)
    error('ieContentsUpdate:NoContents', 'No Contents.m in %s.', folder);
end

report = struct('file', contentsFile, 'refreshed', {{}}, 'kept', {{}}, ...
    'added', {{}}, 'removed', {{}}, 'undocumented', {{}});

%% Parse the existing file into a header, and entries grouped by section.
theLines = readlines(contentsFile);
theLines = cellstr(theLines);

[headerLines, theEntries, theSections, entryIndent, nameWidth] = ...
    localParse(theLines);

%% Resolve every entry against the directory, and refresh what we can.
keptEntries = theEntries([]);
for ii = 1:numel(theEntries)
    thisEntry = theEntries(ii);
    [kind, h1Line] = localResolve(folder, thisEntry.section, thisEntry.name);

    switch kind
        case 'mfile'
            % Many files open with '%functionName', which repeats the name
            % and says nothing. A hand-written description beats that, so
            % only overwrite when the H1 line actually adds information.
            if localIsUsefulH1(h1Line, thisEntry.name)
                thisEntry.description = h1Line;
                report.refreshed{end+1} = thisEntry.name;
            else
                report.kept{end+1} = thisEntry.name;
            end
            keptEntries(end+1) = thisEntry; %#ok<AGROW>
        case 'other'
            report.kept{end+1} = thisEntry.name;
            keptEntries(end+1) = thisEntry; %#ok<AGROW>
        case 'missing'
            report.removed{end+1} = thisEntry.name;
    end
end

%% Add .m files that live here but are not listed.
% A 'Files' or 'Top Level Files' header is a section whose entries still
% describe this folder, so those names count as listed. Missing that is how
% a file ends up documented twice.
listedTopLevel = {};
if ~isempty(keptEntries)
    describesThisFolder = arrayfun(@(e) isempty(e.section), keptEntries);
    listedTopLevel = {keptEntries(describesThisFolder).name};
end

% Put new entries under that header too, rather than splitting them off.
newSectionIndex = 0;
plainSection = find([theSections.plain], 1);
if ~isempty(plainSection), newSectionIndex = plainSection; end

mFiles = dir(fullfile(folder, '*.m'));
for ii = 1:numel(mFiles)
    [~, thisName] = fileparts(mFiles(ii).name);
    if strcmp(thisName, 'Contents'), continue; end
    if ismember(thisName, listedTopLevel), continue; end

    newEntry = struct('name', thisName, ...
        'description', localH1(fullfile(folder, mFiles(ii).name)), ...
        'section', '', 'sectionIndex', newSectionIndex);
    keptEntries(end+1) = newEntry; %#ok<AGROW>
    report.added{end+1} = thisName;
end

%% Optionally document the .m files that live one level down.
if includeSubdirs
    [keptEntries, theSections, addedBelow] = ...
        localAddSubdirEntries(folder, keptEntries, theSections);
    report.added = [report.added, addedBelow];
end

%% Report subdirectories and data files that nothing documents.
report.undocumented = localUndocumented(folder, keptEntries);

%% Rebuild and write.
newLines = localRebuild(headerLines, keptEntries, theSections, ...
    entryIndent, nameWidth);

if ~dryRun
    fid = fopen(contentsFile, 'w');
    fprintf(fid, '%s\n', newLines{:});
    fclose(fid);
end

if beVerbose
    localPrintReport(report, dryRun);
end

end

%% ------------------------------------------------------------------------
function [headerLines, theEntries, theSections, entryIndent, nameWidth] = ...
    localParse(theLines)
% Split the file into its header, its section headers, and its entries.

entryPattern = '^%(\s+)(\S+)\s\s+-\s?(.*)$';
sectionPattern = '^%\s*([A-Z][A-Z0-9_ ]*[A-Z0-9])\s*\(subdir\s+(\S+)\)\s*(.*)$';
plainSectionPattern = '^%\s*(Files|Top Level Files)\s*$';
continuationPattern = '^%\s{8,}(\S.*)$';

theEntries = struct('name', {}, 'description', {}, 'section', {}, ...
    'sectionIndex', {});
theSections = struct('name', {}, 'folder', {}, 'description', {}, ...
    'raw', {}, 'plain', {});

headerLines = {};
entryIndent = '   ';
nameWidth = 0;

currentSection = 0;
inHeader = true;

for ii = 1:numel(theLines)
    thisLine = theLines{ii};

    sectionTokens = regexp(thisLine, sectionPattern, 'tokens', 'once');
    plainTokens = regexp(thisLine, plainSectionPattern, 'tokens', 'once');
    entryTokens = regexp(thisLine, entryPattern, 'tokens', 'once');

    if ~isempty(sectionTokens)
        inHeader = false;
        theSections(end+1) = struct('name', sectionTokens{1}, ...
            'folder', sectionTokens{2}, 'description', sectionTokens{3}, ...
            'raw', thisLine, 'plain', false); %#ok<AGROW>
        currentSection = numel(theSections);
        continue;
    end

    if ~isempty(plainTokens)
        inHeader = false;
        theSections(end+1) = struct('name', plainTokens{1}, 'folder', '', ...
            'description', '', 'raw', thisLine, 'plain', true); %#ok<AGROW>
        currentSection = numel(theSections);
        continue;
    end

    if ~isempty(entryTokens)
        inHeader = false;
        entryIndent = entryTokens{1};
        thisName = entryTokens{2};
        nameWidth = max(nameWidth, numel(thisName));

        sectionName = '';
        if currentSection > 0, sectionName = theSections(currentSection).folder; end

        theEntries(end+1) = struct('name', thisName, ...
            'description', strtrim(entryTokens{3}), ...
            'section', sectionName, ...
            'sectionIndex', currentSection); %#ok<AGROW>
        continue;
    end

    % A wrapped description belongs to the entry above it.
    continuationTokens = regexp(thisLine, continuationPattern, 'tokens', 'once');
    if ~inHeader && ~isempty(continuationTokens) && ~isempty(theEntries)
        theEntries(end).description = strtrim(sprintf('%s %s', ...
            theEntries(end).description, continuationTokens{1}));
        continue;
    end

    if inHeader, headerLines{end+1} = thisLine; end %#ok<AGROW>
end

% Trim trailing blank lines from the header block.
while ~isempty(headerLines) && localIsBlankComment(headerLines{end})
    headerLines(end) = [];
end

end

%% ------------------------------------------------------------------------
function [kind, h1Line] = localResolve(folder, sectionFolder, entryName)
% Decide what an entry names: an .m file here, something else, or nothing.

h1Line = '';

% An entry may carry its own relative path, as in 'functions/hill', and it
% may also sit under a '(subdir functions)' section. Those two conventions
% describe the same file, so try the candidates rather than concatenating
% both and looking in functions/functions.
[entryFolder, bareName] = fileparts(entryName);

candidateFolders = {folder};
if ~isempty(entryFolder)
    candidateFolders{end+1} = fullfile(folder, entryFolder);
end
if ~isempty(sectionFolder)
    candidateFolders{end+1} = fullfile(folder, sectionFolder);
    if ~isempty(entryFolder) && ~strcmp(entryFolder, sectionFolder)
        candidateFolders{end+1} = fullfile(folder, sectionFolder, entryFolder);
    end
end

for ii = 1:numel(candidateFolders)
    thisFolder = candidateFolders{ii};

    mFile = fullfile(thisFolder, [bareName '.m']);
    if isfile(mFile)
        kind = 'mfile';
        h1Line = localH1(mFile);
        return;
    end

    if isfolder(fullfile(thisFolder, bareName))
        kind = 'other';
        return;
    end

    % A data file, documented by name without its extension.
    matches = dir(fullfile(thisFolder, [bareName '.*']));
    matches = matches(~[matches.isdir]);
    if ~isempty(matches)
        kind = 'other';
        return;
    end
end

kind = 'missing';

end

%% ------------------------------------------------------------------------
function h1Line = localH1(mFile)
% Return the H1 line: the first comment line of a MATLAB file.

h1Line = '';
fid = fopen(mFile, 'r');
if fid < 0, return; end
cleanup = onCleanup(@() fclose(fid));

while true
    thisLine = fgetl(fid);
    if ~ischar(thisLine), return; end

    trimmed = strtrim(thisLine);
    if isempty(trimmed), continue; end

    % Skip a leading function or classdef line to reach its help text.
    % MATLAB spells the word boundary '\>', not '\b'.
    if ~isempty(regexp(trimmed, '^\s*(function|classdef)\>', 'once'))
        continue;
    end

    if startsWith(trimmed, '%')
        h1Line = strtrim(regexprep(trimmed, '^%+\s*', ''));

        % The older MATLAB style opens with the file name, as in
        % '% coneSizeReadData  Look up cone size data'. The name is already
        % the entry, so drop it and keep the description.
        [~, bareName] = fileparts(mFile);
        if startsWith(lower(h1Line), lower(bareName))
            remainder = strtrim(h1Line(numel(bareName)+1:end));

            % '%s_opticsPSF2Zcoeffs.m' leaves '.m' behind, which is not a
            % description. Treat that as having none.
            remainder = strtrim(regexprep(remainder, '^\.\w+', ''));
            h1Line = remainder;
        end
        return;
    end

    return;   % code before any comment, so there is no H1 line
end

end

%% ------------------------------------------------------------------------
function [theEntries, theSections, addedNames] = ...
    localAddSubdirEntries(folder, theEntries, theSections)
% Document the .m files one level down, under a section per subdirectory.

addedNames = {};

listing = dir(folder);
listing = listing([listing.isdir]);

for ii = 1:numel(listing)
    thisFolder = listing(ii).name;
    if startsWith(thisFolder, '.') || startsWith(thisFolder, '+') || ...
            startsWith(thisFolder, '@') || strcmp(thisFolder, 'private')
        continue;
    end

    mFiles = dir(fullfile(folder, thisFolder, '*.m'));
    mFiles = mFiles(~strcmp({mFiles.name}, 'Contents.m'));
    if isempty(mFiles), continue; end

    % Reuse this subdirectory's section if the file already has one.
    sectionIndex = find(strcmp({theSections.folder}, thisFolder), 1);
    if isempty(sectionIndex)
        theSections(end+1) = struct('name', upper(thisFolder), ...
            'folder', thisFolder, 'description', '', ...
            'raw', sprintf('%% %s (subdir %s)', upper(thisFolder), thisFolder), ...
            'plain', false); %#ok<AGROW>
        sectionIndex = numel(theSections);
    end

    listedHere = {};
    if ~isempty(theEntries)
        inSection = [theEntries.sectionIndex] == sectionIndex;
        listedHere = {theEntries(inSection).name};
    end

    for jj = 1:numel(mFiles)
        [~, thisName] = fileparts(mFiles(jj).name);
        qualifiedName = sprintf('%s/%s', thisFolder, thisName);
        if ismember(thisName, listedHere) || ismember(qualifiedName, listedHere)
            continue;
        end

        theEntries(end+1) = struct('name', qualifiedName, ...
            'description', localH1(fullfile(folder, thisFolder, mFiles(jj).name)), ...
            'section', thisFolder, ...
            'sectionIndex', sectionIndex); %#ok<AGROW>
        addedNames{end+1} = qualifiedName; %#ok<AGROW>
    end
end

end

%% ------------------------------------------------------------------------
function undocumented = localUndocumented(folder, theEntries)
% Subdirectories and data files that no entry mentions.

undocumented = {};
documented = {};
for ii = 1:numel(theEntries)
    [~, bareName] = fileparts(theEntries(ii).name);
    documented{end+1} = bareName; %#ok<AGROW>
end

listing = dir(folder);
for ii = 1:numel(listing)
    thisName = listing(ii).name;
    if startsWith(thisName, '.') || strcmp(thisName, 'Contents.m'), continue; end

    [~, bareName, theExtension] = fileparts(thisName);
    if strcmp(theExtension, '.m'), continue; end     % handled as an entry
    if ismember(bareName, documented), continue; end

    undocumented{end+1} = thisName; %#ok<AGROW>
end

end

%% ------------------------------------------------------------------------
function newLines = localRebuild(headerLines, theEntries, theSections, ...
    entryIndent, nameWidth)
% Reassemble the file: header, unsectioned entries, then each section.

if isempty(theEntries)
    nameWidth = 0;
else
    nameWidth = max(nameWidth, max(cellfun(@numel, {theEntries.name})));
end

% One very long name should not pad every other line off the screen.
maximumNameWidth = 40;
nameWidth = min(nameWidth, maximumNameWidth);

newLines = headerLines(:)';
newLines{end+1} = '%';

topLevel = theEntries([theEntries.sectionIndex] == 0);
newLines = [newLines, localFormatEntries(topLevel, entryIndent, nameWidth)];

for ii = 1:numel(theSections)
    sectionEntries = theEntries([theEntries.sectionIndex] == ii);
    if isempty(sectionEntries), continue; end   % section emptied out

    newLines{end+1} = '%'; %#ok<AGROW>
    newLines{end+1} = theSections(ii).raw; %#ok<AGROW>
    newLines = [newLines, localFormatEntries(sectionEntries, entryIndent, nameWidth)]; %#ok<AGROW>
end

newLines{end+1} = '%';

% A section that follows an empty group would otherwise be preceded by two
% blank comment lines. Collapse any run of them into one.
isBlank = cellfun(@localIsBlankComment, newLines);
newLines(isBlank & [false, isBlank(1:end-1)]) = [];

end

%% ------------------------------------------------------------------------
function formatted = localFormatEntries(theEntries, entryIndent, nameWidth)

formatted = cell(1, numel(theEntries));
for ii = 1:numel(theEntries)
    % Pad one wider than the longest name so even that entry keeps two
    % spaces before the dash. A single space would not match the entry
    % pattern on the next run, and the entry would be read as header text.
    formatted{ii} = sprintf('%%%s%-*s - %s', entryIndent, nameWidth + 1, ...
        theEntries(ii).name, theEntries(ii).description);
    formatted{ii} = deblank(formatted{ii});
end

end

%% ------------------------------------------------------------------------
function tf = localIsUsefulH1(h1Line, entryName)
% False when the H1 line is empty or merely repeats the file name.

tf = false;
if isempty(h1Line), return; end

[~, bareName] = fileparts(entryName);
normalize = @(s) lower(regexprep(s, '[^a-zA-Z0-9]', ''));

tf = ~strcmp(normalize(h1Line), normalize(bareName));

end

%% ------------------------------------------------------------------------
function tf = localIsBlankComment(thisLine)
tf = isempty(strtrim(regexprep(thisLine, '^%+', '')));
end

%% ------------------------------------------------------------------------
function localPrintReport(report, dryRun)

if dryRun, prefix = 'WOULD '; else, prefix = ''; end
[~, folderName] = fileparts(fileparts(report.file));

fprintf('\n%s\n', report.file);
fprintf('  %srefresh %d .m entries, keep %d, add %d, remove %d\n', ...
    prefix, numel(report.refreshed), numel(report.kept), ...
    numel(report.added), numel(report.removed));

if ~isempty(report.removed)
    fprintf('  removed (no such file or folder): %s\n', ...
        strjoin(report.removed, ', '));
end
if ~isempty(report.added)
    fprintf('  added: %s\n', strjoin(report.added, ', '));
end
if ~isempty(report.undocumented)
    fprintf('  undocumented, needs a human description: %s\n', ...
        strjoin(report.undocumented, ', '));
end

end
