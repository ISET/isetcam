function val = fontGet(font,param,varargin)
%Get font parameters and derived properties 
%
%     val = fontGet(font,parm,varargin)
%
% List of parameters
%
%  'type'   - always font
%  'name'   - 'g-georgia-14'96'
%  'character' - 'g'
%  'size'   - 14 (point)
%  'family' - Georgia, Arial, Times
%  'style'  - e.g., NORMAL or ITALIC
%  'dpi'    - e.g. 96 dots per inch
%  'bitmap' -  Binary RGB image of the font MxNx3
%  'i bitmap' - Inverted bitmap (1-font.bitmap)
%  'padded bitmap' - padded to a size with a pad value 
%          fontGet(font,'padded bitmap', padsize=[7 7],padval=0)
%
%
% Example
%   font = fontCreate;
%   vcNewGraphWin; image(fontGet(font,'padded bitmap',[3 3],1)); 
%   axis image
%
%  White on black version.  Padd with 1 then invert.
%   image(fontGet(font, 'i padded bitmap',[3,3],1));
%
% (HJ/BW)  PDCSoft Team, 2014.

if notDefined('param'), error('Parameter must be defined.'); end

% Default is empty when the parameter is not yet defined.
val = [];

param = ieParamFormat(param);

switch param
    
    % Book keeping
    case 'type'
        val = font.type;
    case 'name'
        val = font.name;

    case 'character'
        val = font.character;
    case 'size'
        val = font.size;
    case 'family'
        val = font.family;
    case 'style'
        val = font.style;
    case 'dpi'
        val = font.dpi;
    case 'bitmap'
        val = font.bitmap;

    % Derived
    case 'ibitmap'
        val = 1 - font.bitmap;
    case 'paddedbitmap'
        % fontGet(font,'padded bitmap',padval);
        % vcNewGraphWin; imagesc(fontGet(font,'padded bitmap'));axis equal
        if ~isempty(varargin), padsize = varargin{1}; end
        if length(varargin) > 1, padval = varargin{2}; end
        
        if notDefined('padsize'), padsize = [7 7]; end
        if notDefined('padval'),  padval = 1; end
        
        % RGB bitmap
        bitmap = fontGet(font,'bitmap');
        
        % Pad and return
        newSize = size(bitmap); 
        newSize(1:2) = newSize(1:2) + 2*padsize;
        val = zeros(newSize);        
        for ii=1:size(bitmap,3);
            val(:,:,ii) = padarray(bitmap(:,:,ii),padsize,padval);
        end
    case 'ipaddedbitmap'
        val = fontGet(font,'padded bitmap');
        val = 1 - val;
    otherwise
        disp(['Unknown parameter: ',param]);
        
 end

end