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
% Example
%   font = fontCreate;
%   font = fontCreate('A','Georgia',24,96); 
%   vcNewGraphWin; imagesc(font.bitmap);
%
%   font = fontCreate('l','georgia',14,72);
%
% (BW) Vistasoft group, 2014

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
    hFig = figure('Position', [50 50 150+fontSz 150+fontSz],...
        'Units', 'pixels', ...
        'Color', [1 1 1], ...
        'Visible', 'off');
    axes('Position',[0 0 1 1],'Units','Normalized');
    axis off;
    
    %% Draw character and capture the frame
    % Place each character in the middle of the figure
    texthandle = text(0.5,1,character, ...
        'Units', 'Normalized', ...
        'FontName', family, ...
        'FontUnits', 'pixels', ...
        'FontSize', fontSz, ...
        'HorizontalAlignment', 'Center', ...
        'VerticalAlignment', 'Top', ...
        'Interpreter', 'None', ...
        'Color',[0 0 0]);
    drawnow;
    
    % Take a snapshot
    try
        bitMap = hardcopy(hFig, '-dzbuffer', '-r0');
    catch
        bitMap = getframe(hFig);
        bitMap = bitMap.cdata;
    end
    
    delete(texthandle);
    
    % Crop height as appropriate
    bwBitMap = min(bitMap, [], 3);
    bitMap = bitMap(find(min(bwBitMap, [], 2) < 255, 1, 'first') : ...
        find(min(bwBitMap, [], 2) < 255, 1, 'last'), :, :);
    
    % Crop width to remove all white space
    bitMap = bitMap(:, find(min(bwBitMap, [], 1) < 255, 1, 'first') : ...
        find(min(bwBitMap, [], 1) < 255, 1, 'last'), :);
    
    % Invert and store in binary format
    bitmap = zeros(size(bitMap));
    bitmap(bitMap > 127) = 1;
    
    close(hFig);
    
end

end
