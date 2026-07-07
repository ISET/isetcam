function htmlFile = iePublish(fname,varargin)
% Publish a tutorial m-file as a self-contained HTML file.
%
% Syntax:
%   htmlFile = iePublish(fname)
%   htmlFile = iePublish(fname,'param',value,...)
%
% Description:
%   Publishes a tutorial/script m-file to HTML so the output file sits
%   next to the source m-file.
%
%   When imageFormat is 'inline' (the default), figure snapshots are
%   base64-encoded and embedded directly in the HTML so the result is a
%   single self-contained file with no external PNG dependencies.
%   Small MP4 movies can also be embedded by writing the movie next to the
%   source file and adding a prose comment line:
%
%       % iePublishVideo: myMovie.mp4
%
% Inputs:
%   fname
%       Character vector or string identifying the m-file. Can be a full
%       path, relative path, or file on the MATLAB path. The .m extension
%       is optional.
%
% Optional parameter/value pairs:
%   'evalCode'         - Evaluate code while publishing (default true)
%   'showCode'         - Show source code in HTML (default true)
%   'maxHeight'        - Max image height in pixels (default 512)
%   'maxWidth'         - Max image width in pixels (default 512)
%   'imageFormat'      - 'inline' embeds images as base64 (default);
%                        any format accepted by imwrite uses external files
%   'createThumbnail'  - Create thumbnail image (default false)
%   'catchError'       - Catch and render errors in HTML (default true)
%   'stylesheet'       - Optional stylesheet file (default '')
%
% Output:
%   htmlFile
%       Full path to the published HTML file.
%
% Example:
%{
% Publish a tutorial in-place with embedded images
% htmlFile = iePublish('tutorials/scene/t_sceneIntroduction.m');
% web(htmlFile,'-browser');
%}
%
% See also:
%   publish
%
% Copyright ImagEval Consultants, LLC, 2026.

if ieNotDefined('fname')
    error('File name required.');
end

if isstring(fname), fname = char(fname); end

% Resolve source file.
[srcDir,~,srcExt] = fileparts(fname);
if isempty(srcExt)
    fname = [fname,'.m'];
    srcExt = '.m';
end

if ~strcmpi(srcExt,'.m')
    error('Input must reference an m-file.');
end

if isempty(srcDir)
    resolved = which(fname);
    if isempty(resolved), resolved = fullfile(pwd,fname); end
else
    resolved = fname;
end

if exist(resolved,'file') ~= 2
    error('Could not find file: %s',fname);
end

[sourceDir,sourceBase,sourceExt] = fileparts(resolved);
if ~strcmpi(sourceExt,'.m')
    error('Input must reference an m-file.');
end
sourceFile = [sourceBase,sourceExt];

p = inputParser;
p.addParameter('evalCode',true,@islogical);
p.addParameter('showCode',true,@islogical);
p.addParameter('maxHeight',512,@(x) isempty(x) || (isscalar(x) && isnumeric(x) && x > 0));
p.addParameter('maxWidth',512,@(x) isempty(x) || (isscalar(x) && isnumeric(x) && x > 0));
p.addParameter('imageFormat','inline',@(x) ischar(x) || (isstring(x) && isscalar(x)));
p.addParameter('createThumbnail',false,@islogical);
p.addParameter('catchError',true,@islogical);
p.addParameter('stylesheet','',@(x) ischar(x) || (isstring(x) && isscalar(x)));
p.parse(varargin{:});
opts = p.Results;

if isstring(opts.imageFormat), opts.imageFormat = char(opts.imageFormat); end
if isstring(opts.stylesheet),  opts.stylesheet  = char(opts.stylesheet);  end

% 'inline' is handled by post-processing; publish itself needs a real format.
inlineImages = strcmpi(opts.imageFormat,'inline');
publishImageFormat = 'png';
if ~inlineImages
    publishImageFormat = opts.imageFormat;
end

publishOpts = struct( ...
    'format','html', ...
    'outputDir',sourceDir, ...
    'evalCode',opts.evalCode, ...
    'showCode',opts.showCode, ...
    'maxHeight',opts.maxHeight, ...
    'maxWidth',opts.maxWidth, ...
    'imageFormat',publishImageFormat, ...
    'createThumbnail',opts.createThumbnail, ...
    'catchError',opts.catchError);

if ~isempty(opts.stylesheet)
    publishOpts.stylesheet = opts.stylesheet;
end

origDir = pwd;
cleanupObj = onCleanup(@() cd(origDir));
cd(sourceDir);
htmlFile = publish(sourceFile,publishOpts);

if inlineImages
    htmlFile = ieEmbedHTMLImages(htmlFile);
end

end

% -------------------------------------------------------------------------
function htmlFile = ieEmbedHTMLImages(htmlFile)
% Read published HTML, embed PNG images and marked MP4 videos as base64 data
% URIs, inject CSS overrides for readable font sizes, write back, delete
% loose generated media files.

htmlText = fileread(htmlFile);

% --- Embed PNG images ---------------------------------------------------
% Match src="something.png" — the closing quote must follow .png directly,
% so already-embedded data URIs (data:image/png;base64,...) are skipped.
imgPattern = 'src="([^"]+\.png)"';
[tokens, matches] = regexp(htmlText, imgPattern, 'tokens', 'match');

htmlDir  = fileparts(htmlFile);
toDelete = {};

for ii = 1:numel(tokens)
    imgName = tokens{ii}{1};
    imgPath = fullfile(htmlDir, imgName);
    if exist(imgPath,'file') ~= 2, continue; end

    fid = fopen(imgPath,'rb');
    imgBytes = fread(fid, Inf, 'uint8=>uint8');
    fclose(fid);

    b64 = matlab.net.base64encode(imgBytes);
    if isstring(b64), b64 = char(b64); end

    htmlText = strrep(htmlText, matches{ii}, ...
        ['src="data:image/png;base64,' b64 '"']);
    toDelete{end+1} = imgPath; %#ok<AGROW>
end

% --- Embed marked MP4 videos --------------------------------------------
[htmlText, videoFiles] = ieEmbedHTMLVideos(htmlText, htmlDir);
toDelete = [toDelete videoFiles]; %#ok<AGROW>

% --- Inject CSS overrides -----------------------------------------------
cssOverride = [
    'html body { font-size:14px; }'                                         newline ...
    'h1 { font-size:1.6em; }'                                               newline ...
    'h2 { font-size:1.3em; margin-top:28px; }'                              newline ...
    '.content { max-width:900px; margin:0 auto; padding:30px; line-height:148%; }' newline ...
    'pre, code { font-size:13px; line-height:1.35; }'                        newline ...
    'pre.codeinput {'                                                        newline ...
    '  font-size:13px; border-radius:4px;'                                  newline ...
    '  box-shadow:0 1px 3px rgba(0,0,0,.08); }'                             newline ...
    'pre.codeoutput {'                                                       newline ...
    '  font-size:13px; border-left:3px solid #6aaadd;'                      newline ...
    '  background:#f0f6fb; padding-left:14px; }'                            newline ...
    'img, video { display:block; margin:20px auto; }'                       newline ...
    'video { width:512px; max-width:100%; height:auto; }'                   newline ...
    'span.keyword { color:#0070c1 }'                                        newline ...
    'span.comment { color:#2e7d32 }'                                        newline ...
    'span.string  { color:#7b3f9e }'                                        newline ...
    'pre.language-matlab {'                                                  newline ...
    '  font-size:13px; background:#f7f7f7; padding:10px;'                   newline ...
    '  border:1px solid #d3d3d3; border-left:3px solid #5aaa7a;'            newline ...
    '  border-radius:4px; box-shadow:0 1px 3px rgba(0,0,0,.08); }'          newline ...
    'code, tt { font-family:Menlo,Monaco,Consolas,"Courier New",monospace;' newline ...
    '  background:#efefef; padding:2px 5px; border-radius:3px;'             newline ...
    '  font-size:0.88em; color:#333; }'                                     newline ...
    'pre code, pre tt { background:none; padding:0; border-radius:0; font-size:inherit; }' newline ...
    ];

htmlText = strrep(htmlText, '</style>', [cssOverride '</style>']);

% --- Wrap inline code references ----------------------------------------
% Patterns like "help funcName" and "doc funcName" in prose text are
% wrapped in <code> tags so they render with code styling.  We skip
% content inside <pre> blocks to avoid double-processing code listings.
htmlText = ieWrapInlineCode(htmlText);

% --- Write back and clean up --------------------------------------------
fid = fopen(htmlFile,'w');
fwrite(fid, htmlText, 'char');
fclose(fid);

for ii = 1:numel(toDelete)
    delete(toDelete{ii});
end

end

% -------------------------------------------------------------------------
function [htmlText, embeddedFiles] = ieEmbedHTMLVideos(htmlText, htmlDir)
% Replace prose marker paragraphs with inline MP4 video elements.
%
% Marker syntax in the source m-file:
%   % iePublishVideo: relativeMovieFile.mp4

embeddedFiles = {};

% Split on <pre> blocks so code listings remain unchanged.
[prose, preBlocks] = regexp(htmlText, '(?s)<pre[^>]*>.*?</pre>', 'split', 'match');
markerPattern = '<p>\s*iePublishVideo:\s*([^<]+?\.mp4)\s*</p>';

for ii = 1:numel(prose)
    [tokens, matches] = regexp(prose{ii}, markerPattern, 'tokens', 'match');
    for jj = 1:numel(tokens)
        movieName = strtrim(tokens{jj}{1});
        moviePath = movieName;
        if ~isfile(moviePath)
            moviePath = fullfile(htmlDir, movieName);
        end

        if ~isfile(moviePath)
            warning('iePublish:MissingVideo', ...
                'Could not find video file for publishing: %s', movieName);
            continue;
        end

        fid = fopen(moviePath,'rb');
        movieBytes = fread(fid, Inf, 'uint8=>uint8');
        fclose(fid);

        b64 = matlab.net.base64encode(movieBytes);
        if isstring(b64), b64 = char(b64); end

        videoHTML = [ ...
            '<video controls preload="metadata" width="512">' ...
            '<source src="data:video/mp4;base64,' b64 '" type="video/mp4">' ...
            'Your browser does not support the video tag.' ...
            '</video>'];

        prose{ii} = strrep(prose{ii}, matches{jj}, videoHTML);
        embeddedFiles{end+1} = moviePath; %#ok<AGROW>
    end
end

% Reassemble prose and pre blocks in original order.
htmlText = prose{1};
for ii = 1:numel(preBlocks)
    htmlText = [htmlText preBlocks{ii} prose{ii+1}]; %#ok<AGROW>
end

embeddedFiles = unique(embeddedFiles);
end

% -------------------------------------------------------------------------
function htmlText = ieWrapInlineCode(htmlText)
% Wrap "help funcName" and "doc funcName" patterns in <code> tags,
% leaving content inside <pre>...</pre> blocks untouched.

% Split on <pre> blocks so we only touch prose text.
[prose, preBlocks] = regexp(htmlText, '(?s)<pre[^>]*>.*?</pre>', 'split', 'match');

pattern = '\b(help|doc)\s+(\w+)\b';
for ii = 1:numel(prose)
    prose{ii} = regexprep(prose{ii}, pattern, '<code>$1 $2</code>');
end

% Reassemble prose and pre blocks in original order.
htmlText = prose{1};
for ii = 1:numel(preBlocks)
    htmlText = [htmlText preBlocks{ii} prose{ii+1}]; %#ok<AGROW>
end

end
