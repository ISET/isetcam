function font = fontSet(font, param, val, varargin)
%Get font parameters and derived properties
%
%     font = fontGet(font,parm,val,varargin)
%
% Whenever the font parameter is set, the font bit map is recreated with a
% fontCreate call at the end of this function.
%
% Parameters
%      'type' - always font
%      'name' - typically a description of the character
%      'character' - the character
%      'size'      - point size
%      'family'    - type font family
%      'style'     - italics, bold, normal
%      'dpi'       - dots per inch
%      'bitmap'    - bit map
%
% Example:
%   font = fontCreate('v');
%   font = fontSet(font,'character','g');
%   imagesc(font.bitmap);
%
% (HJ/BW)  PDCSoft Team, 2014.

if notDefined('param'), error('Parameter must be defined.'); end
if ~exist('val','var'), error('Parameter must be defined.'); end

param = ieParamFormat(param);

switch param
    
    % Book keeping
    case 'type'
        % Always 'font'
    case 'name'
        font.name = val;
        
    case 'character'
        font.character = val;
    case 'size'
        font.size = val;
    case 'family'
        font.family = val;
    case 'style'
        font.style = val;
    case 'dpi'
        font.dpi = val;
    case 'bitmap'
        font.bitmap = val;
        
    otherwise
        disp(['Unknown parameter: ',param]);
        
end

% Rebuild the bitmap
font = fontCreate(font.character,font.family,font.size,font.dpi);

end
