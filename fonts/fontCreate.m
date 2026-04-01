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
   axis image;
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

% The font creation routine needs units to be pixels
prevUnits = get(groot,'DefaultFigureUnits');
c = onCleanup(@() set(groot,'DefaultFigureUnits',prevUnits));

% Set default units to pixels for this scope
set(groot,'DefaultFigureUnits','pixels');

if notDefined('font'), error('font required'); end

% See if we have a font stored for this variable
name = fontGet(font,'name');
fName = sprintf('%s.mat',name);
fName = fullfile(isetRootPath,'data','fonts',fName);
if exist(fName,'file')
    load(fName,'bmSrc');
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
else

    % No font file found.  Create an example on the screen
    character = fontGet(font,'character');
    fontSz = fontGet(font,'size');
    family = fontGet(font,'family');

    %% Set up canvas
    hFig = figure('Units','pixels',...
        'Position',[50 50 150+fontSz 150+fontSz],...
        'Color',[1 1 1],'Visible','off');
    % hAx = axes('Position',[0 0 1 1],'Units','Normalized');
    axis off

    text(0.5, 0.5, character, ...
        'Units','normalized', ...
        'FontName', family, ...
        'FontUnits','pixels', ...
        'FontSize', fontSz, ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', ...
        'Interpreter','none','Color',[0 0 0]);
    drawnow


    %{
    % Take a snapshot
    try
        bitMap = hardcopy(hFig, '-dzbuffer', '-r0');
    catch
        bitMap = getframe(hFig);
        bitMap = bitMap.cdata;
    end
    %}

    % Take a snapshot
    try
        dpiVal = font.dpi;
        dpiVal = max(20, min(600, round(dpiVal)));  % clamp to [20,600]
    catch
        dpiVal = 96;
    end


    % Fallback #1: try getframe after forcing a visible render pass
    drawnow;

    % Ensure figure is visible for rendering
    wasVisible = strcmp(get(hFig,'Visible'),'on');
    if ~wasVisible, set(hFig,'Visible','on'); end
    drawnow; pause(0.05);    % let the UI finish rendering

    tmpPng = [tempname, '.png'];
    try
        % Preferred: exportgraphics when available
        exportgraphics(gca, tmpPng, 'Resolution', dpiVal);
    catch
        % Fallback: print then read (older releases or exportgraphics fails)
        print(hFig, tmpPng, '-dpng', sprintf('-r%d', dpiVal));
    end

    bitMap = imread(tmpPng);
    if exist(tmpPng,'file'), delete(tmpPng); end
    if ~wasVisible && ishandle(hFig), set(hFig,'Visible','off'); end

    % Crop to the non-white glyph region. If no glyph is detected,
    % preserve behavior by returning a minimal white bitmap.
    bwBitMap = min(bitMap, [], 3);
    rows = find(min(bwBitMap, [], 2) < 255);
    cols = find(min(bwBitMap, [], 1) < 255);
    if isempty(rows) || isempty(cols)
        bitmap = ones(1, 1, 3);
        close(hFig);
        return;
    end
    bitMap = bitMap(rows(1):rows(end), cols(1):cols(end), :);

    % Invert and store in binary format
    bitmap = zeros(size(bitMap));
    bitmap(bitMap > 127) = 1;

    close(hFig);

end

end

