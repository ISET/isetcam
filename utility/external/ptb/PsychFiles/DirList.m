function str = DirList(dirnm,qdispfiles,lim,pref,folderFilter,fileFilter, qRelPath)
% str = DirList(dirnm,qdispfiles,lim,pref, folderFilter, fileFilter, qRelPath)
% recursively lists directories en returns the whole shit
% as a string
% all inputs except the first are optional
% QDISPFILES is a boolean indicating whether files should also be listed
% (true, default)
% LIM is the maximum number of levels that will be listed (default unlimited (inf))
% PREF is a prefix for each node in the directorylist
% FOLDERFILTER is to filter out unwanted folders (regexp). If a match
% occurs, the directory _IS NOT_ output and not recursed into
% FILEFILTER is to filter out unwanted files (regexp). If a match
% occurs, the files _ARE_ output. Use e.g. '\.m$' to only display files with
% .m extensions, '\.mat$|\.m$' to include all files with .mat or .m files.
% default: '.', shows all files.
% QRELPATH if true, a listing of existing paths relative to DIRNM. Default
% false

% DN 2007
% DN and Sam Yeung 2008-07-28 Optionally displays files
% DN 2009-02-14  Made more intuitive
% DN 2011-09-19  Added filters for folders and files


% input checking
if nargin<7 || isempty(qRelPath)
    qRelPath = false;
end
if nargin<6 || isempty(fileFilter)
    fileFilter = '.';
end
if nargin<5 || isempty(folderFilter)
    folderFilter = '';
end
if nargin<4 || isempty(pref)
    pref = '';
end
if nargin<3 || isempty(lim)
    lim = inf;
end
if nargin<2 || isempty(qdispfiles)
    qdispfiles = true;
end

% init
str     = [];
fnms    = dir(dirnm);

% do the work
for p=1:length(fnms)
    if strcmp(fnms(p).name,'..') || strcmp(fnms(p).name,'.') % always returned by Matlab, never wanted
        continue;
    end
    
    if qdispfiles && ~isdir([dirnm filesep fnms(p).name])
        % check if not filtered out
        if isempty(regexp(fnms(p).name,fileFilter, 'once'))
            continue;
        end
        if qRelPath
            str = [str pref fnms(p).name char(10)];
        else
            str = [str pref char(215) ' ' fnms(p).name char(10)];
        end
    end
    if isdir([dirnm filesep fnms(p).name])
        % check if not filtered out
        if ~isempty(regexp(fnms(p).name,folderFilter, 'once'))
            continue;
        end
        % append and recurse
        if qRelPath
            if lim>0
                str = [str DirList([dirnm filesep fnms(p).name], qdispfiles, lim-1, [pref fnms(p).name '/'],folderFilter,fileFilter,qRelPath)];
            end
        else
            str = [str fnms(p).name char(10)];
            if lim>0
                str = [str DirList([dirnm filesep fnms(p).name], qdispfiles, lim-1, [pref '  '],folderFilter,fileFilter,qRelPath)];
            end
        end
    end
end
