function ieMontages(varargin)
%Create labeled 3x3 montages from PNG files in the current folder.
%
% Syntax
%   ieMontages()
%   ieMontages(Name,Value,...)
%
% Description
%   ieMontages collects all PNG files in the current working folder,
%   arranges them in pages of 3-by-3 tiles (9 images per page), overlays a
%   label on each tile (by default the filename without extension), and
%   writes each page to disk as PNG.
%
% Required files
%   PNG files in the current folder. If there are fewer than 9 images on a
%   page the remaining tiles are left blank.
%
% Name-Value Options
%   'MaxPages'   - positive scalar limiting number of montage pages to save.
%                  Default: inf (save all pages).
%   'Labels'     - cell array of strings used as labels for each image. If
%                  provided, must have at least as many entries as images.
%                  Default: filenames (without extension).
%   'FilePrefix' - character vector or string used as the prefix for saved
%                  montage files. Saved files are FilePrefix_01.png, etc.
%                  Alias: 'OutPrefix'. Default: 'montage'.
%   'FontSize'   - font size for tile labels. Default: 12.
%   'adjust'     - Use imadjust to stretch the rgb values (logical) default: true
%
% Examples
%   ieMontages();                                      % default behavior
%   ieMontages('MaxPages',8,'FilePrefix','sceneMontage'); 
%   ieMontages('Labels',myLabelCell,'FontSize',14);
%
% Notes
%   - The function uses a tiledlayout(3,3) figure and captures the figure
%     contents to produce each PNG. The figure is created invisible to the
%     screen.
%   - If running old MATLAB releases that do not support an alpha value in
%     text BackgroundColor, comment out the set(hText,'BackgroundColor',...) line.

%% Parse inputs
varargin = ieParamFormat(varargin);

p = inputParser;
p.FunctionName = 'ieMontages';
addParameter(p,'maxpages',inf,@(x) isnumeric(x) && isscalar(x) && x>0);
addParameter(p,'labels',{},@(x) iscell(x) || isempty(x));

% Accept char or string for file prefix
validPrefix = @(x) (ischar(x) || isstring(x));
addParameter(p,'fileprefix','montage',validPrefix);

addParameter(p,'fontsize',12,@(x)isnumeric(x)&&isscalar(x)&&x>0);

addParameter(p,'adjust',false,@islogical);

parse(p,varargin{:});

maxPages = p.Results.maxpages;
labelsIn = p.Results.labels;
fontSize = p.Results.fontsize;
prefix   = char(p.Results.fileprefix);

%% Find png files
files = dir('*.png');
if isempty(files)
    error('No PNG files found in current folder.');
end
numFiles = numel(files);
fileNames = {files.name};

%% Create labels: use input labels if provided, otherwise filenames without ext
if ~isempty(labelsIn)
    if numel(labelsIn) < numFiles
        error('Provided Labels has fewer entries than number of images.');
    end
    labels = labelsIn(:);
else
    [~,nm,~] = cellfun(@fileparts,fileNames,'UniformOutput',false);
    labels = nm(:);
end

% Compute number of pages (3x3 per page)
perPage = 9;
nPages = ceil(numFiles / perPage);
nPages = min(nPages, maxPages);

%% Create montages
for pg = 1:nPages
    startIdx = (pg-1)*perPage + 1;
    endIdx = min(pg*perPage, numFiles);
    idx = startIdx:endIdx;
    % Setup figure
    hFig = figure('Visible','off','Color','w','Units','pixels','Position',[100 100 900 900]);
    % Use tight layout margins
    t = tiledlayout(3,3,'TileSpacing','compact','Padding','compact');
    for k = 1:perPage
        ax = nexttile;
        if k <= numel(idx)
            im = imread(fileNames{idx(k)});
            
            % Stretch the data
            % if p.Results.adjust
            %     im = imadjust(im,[prctile(im(:),1),prctile(im(:),99)]);
            % end

            imshow(im,'Border','tight');
            hold on;
            % Add label in top-left with semi-transparent background
            txt = labels{idx(k)};
            hText = text(5, 10, txt, 'Color','w','FontSize',fontSize, ...
                'FontWeight','bold','Interpreter','none','VerticalAlignment','top');
            % Transparent background for readability (MATLAB R2023a+ supports alpha)
            try
                set(hText,'BackgroundColor',[0 0 0 0.5]);
            catch
                % Older MATLAB: no alpha support; use solid background
                set(hText,'BackgroundColor',[0 0 0]);
            end
            hold off;
        else
            % blank tile
            axis off;
        end
        % Remove ticks and frame
        ax.XTick = [];
        ax.YTick = [];
    end
    title(t, sprintf('Page %d (images %d–%d)', pg, startIdx, endIdx), 'FontSize', 14);
    drawnow;
    % Save montage using provided prefix
    outName = sprintf('%s_%02d.png', prefix, pg);
    % Render figure to image and write
    frame = getframe(hFig);
    imwrite(frame.cdata, outName);
    close(hFig);
end

end

%{
function ieMontages(varargin)
%ieMAKEMONTAGES Create 3x3 montages from PNG files and label each tile.
%
%  ieMontages()             - use filenames as labels, save all pages.
%  ieMontages('MaxPages',8) - limit number of montages saved.
%  ieMontages('Labels',C)   - C is a cell array of labels (numel >= #images).

%% Parse inputs
p = inputParser;
addParameter(p,'MaxPages',inf,@(x) isnumeric(x) && isscalar(x) && x>0);
addParameter(p,'Labels',{},@(x) iscell(x) || isempty(x));
addParameter(p,'OutPrefix','montage',@ischar);
addParameter(p,'FontSize',12,@(x)isnumeric(x)&&isscalar(x)&&x>0);

parse(p,varargin{:});
maxPages = p.Results.MaxPages;
labelsIn = p.Results.Labels;
outPrefix = p.Results.OutPrefix;
fontSize = p.Results.FontSize;

%% Find png files
files = dir('*.png');
if isempty(files)
    error('No PNG files found in current folder.');
end
numFiles = numel(files);
fileNames = {files.name};

%% Create labels: use input labels if provided, otherwise filenames without ext
if ~isempty(labelsIn)
    if numel(labelsIn) < numFiles
        error('Provided Labels has fewer entries than number of images.');
    end
    labels = labelsIn(:);
else
    [~,nm,~] = cellfun(@fileparts,fileNames,'UniformOutput',false);
    labels = nm(:);
end

% Compute number of pages (3x3 per page)
perPage = 9;
nPages = ceil(numFiles / perPage);
nPages = min(nPages, maxPages);

%% Create montages
for pg = 1:nPages
    startIdx = (pg-1)*perPage + 1;
    endIdx = min(pg*perPage, numFiles);
    idx = startIdx:endIdx;
    % Setup figure
    hFig = figure('Visible','off','Color','w','Units','pixels','Position',[100 100 900 900]);
    % Use tight layout margins
    t = tiledlayout(3,3,'TileSpacing','compact','Padding','compact');
    for k = 1:perPage
        ax = nexttile;
        if k <= numel(idx)
            im = imread(fileNames{idx(k)});
            imshow(im,'Border','tight');
            hold on;
            % Add label in top-left with semi-transparent background
            txt = labels{idx(k)};
            % Use text with white background patch for readability
            hText = text(5, 10, txt, 'Color','w','FontSize',fontSize, ...
                'FontWeight','bold','Interpreter','none','VerticalAlignment','top');
            set(hText,'BackgroundColor',[0 0 0 0.5]); % MATLAB supports 4th alpha in R2023a+; if older, comment out
            hold off;
        else
            % blank tile
            axis off;
        end
        % Remove ticks and frame
        ax.XTick = [];
        ax.YTick = [];
    end
    title(t, sprintf('Page %d (images %d–%d)', pg, startIdx, endIdx), 'FontSize', 14);
    drawnow;
    % Save montage
    outName = sprintf('%s_%02d.png', outPrefix, pg);
    % Render figure to image and write (avoid capturing UI elements)
    frame = getframe(hFig);
    imwrite(frame.cdata, outName);
    close(hFig);
end

end
%}
