function font = fontCreate(letter,family,sz,dpi,style)
% Create a font structure
%
% Inputs
%   letter: (Default 'g')
%   sz:     Font size (default = 14)
%   family: Font family (default 'Georgia')
%   dpi:    Dot per inch (default 96)
%   style:  Italics, NORMAL, BOLD.
%
% The bitmap of the font is set so the letter is black on a white
% background.  Use 1 - bitmap to flip it to white on a black background.
%
% (BW) Vistasoft group, 2014

% Examples:
%{
   font = fontCreate('A','Georgia',24,96);
   ieNewGraphWin; imagesc(font.bitmap);
%}
%{
   font = fontCreate('l','georgia',14,72);
%}

%%
if notDefined('letter'), letter = 'g'; end
if notDefined('sz'), sz = 14; end
if notDefined('family'), family = 'Georgia'; end
if notDefined('dpi'), dpi = 96; end
if notDefined('style'), style = 'NORMAL'; end

font.type       = 'font';
font.name       = lower(sprintf('%s-%s-%i-%i',letter,family,sz,dpi));
font.character  = letter;
font.size       = sz;
font.family     = family;
font.style      = style;
font.dpi        = dpi;

% Need to make a way to read the cached fonts rather than the method here.
% The dpi will be added and we will read the overscaled (x) fonts.  Then we
% will put them in the display structure, and maybe filter if we decide to.
font.bitmap     = fontBitmapGet(font);

end

%%
function bitmap = fontBitmapGet(font)
%% Read a bitmap from a stored file (data/fonts) or create one on the screne
%
%  bitmap = fontBitmapGet(font)
%
% This function helps get the font bitmap from the system. The basic idea
% of this function is to draw a letter on a canvas in the background and
% read back the frame
%
%  Inputs:
%   font - font data structure (fontCreate)
%
%  Outputs:
%    bitMap     - bitmap image
%
% Example:
%    font = fontCreate; bitmap = fontBitmapGet(font);
%
% (HJ) May, 2014

%% Init
if notDefined('font'), error('font required'); end

try
    % See if we have a font stored for this variable
    name = fontGet(font,'name');
    fName = sprintf('%s.mat',name);
    fName = fullfile(isetRootPath,'data','fonts',fName);
    load(fName);
    b = bmSrc.dataIndex;
    b = 1 - b;   %Make black on white
    padsize = 3*ceil(size(b,2)/3) - size(b,2);
    b = padarray(b,[0 padsize],1,'pre');

    % Reformat the bit maps, which are not always a multiple of 3 wide
    bitmap = ones(size(b,1),ceil(size(b,2)/3),3);
    for ii=1:3
        bitmap(:,:,ii) = b(:,ii:3:end);
    end

    return;

catch

    % No font file found.  Create an example on the screen
    character = fontGet(font,'character');
    fontSz = fontGet(font,'size');
    family = fontGet(font,'family');

    %% Set up canvas
    % Set up canvas
    hFig = figure( ...
        'Units', 'pixels', ...
        'Position', [50 50 150+fontSz 150+fontSz], ...
        'Color', [1 1 1], ...
        'Visible', 'off', ...
        'Renderer', 'opengl');  % use raster renderer for PNG output

    ax = axes('Parent', hFig, 'Position', [0 0 1 1], 'Units', 'normalized');
    axis(ax, 'off');

    % Draw character
    texthandle = text(ax, 0.5, 1, character, ...
        'Units', 'normalized', ...
        'FontName', family, ...
        'FontUnits', 'pixels', ...
        'FontSize', fontSz, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'Interpreter', 'none', ...
        'Color', [0 0 0]);

    drawnow;

    % Ensure dpi exists and is numeric
    if ~isfield(font,'dpi') || ~isnumeric(font.dpi) || isempty(font.dpi)
        dpiVal = 96;
    else
        dpiVal = font.dpi;
    end

    % Render to temporary PNG and read back
    tmpName = [tempname, '.png'];
    try
        if exist('exportgraphics','file') == 2
            exportgraphics(hFig, tmpName, 'BackgroundColor', 'white', 'Resolution', dpiVal);
        else
            print(hFig, tmpName, '-dpng', sprintf('-r%d', dpiVal));
        end
        bitMap = imread(tmpName);
        delete(tmpName);
    catch ME
        if exist('tmpName','var') && exist(tmpName,'file')
            delete(tmpName);
        end
        if exist('texthandle','var') && isvalid(texthandle), delete(texthandle); end
        if exist('hFig','var') && isvalid(hFig), close(hFig); end
        rethrow(ME);
    end

    % Clean up handles
    if exist('texthandle','var') && isvalid(texthandle), delete(texthandle); end
    if exist('hFig','var') && isvalid(hFig), close(hFig); end

    % Convert to grayscale mask and find non-white rows/cols
    gray = min(bitMap, [], 3);
    rows = find(gray < 255);
    cols = find(gray < 255);

    % If nothing drawn, return empty bitmap
    if isempty(rows) || isempty(cols)
        bitmap = zeros(0,0);
        return;
    end

    rowInd = rows(1) : rows(end);
    colInd = cols(1) : cols(end);
    bitMap = bitMap(rowInd, colInd, :);

    % Binary bitmap: 1 where dark (character), 0 for background
    bitmap = zeros(size(bitMap,1), size(bitMap,2));
    bitmap(min(bitMap, [], 3) < 128) = 1;

end

end
