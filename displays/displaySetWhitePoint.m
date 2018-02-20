function vci = displaySetWhitePoint(vci,format)
% Set the display white point chromaticity
%
%   vci = displaySetWhitePoint(vci,format)
%
%  The display spectral power distributions of the primaries so that the
%  entered chromaticity is the white point of the display.
%
% Example:
%  vci = displaySetWhitePoint(vci,'xyz') 
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO:
% These should be part of displaySet() and displayGet()

if ~exist('vci','var') | isempty(vci), [val,vci] = vcGetSelectedObject('VCIMAGE'); end
if ~exist('format','var') | isempty(format), format = 'xyz'; end

switch lower(format)
    case 'xyz'
        wp = chromaticity(ipGet(vci,'whitepoint'));
        wpchromaticity = ieReadMatrix(wp,'%.3f','Enter display whitepoint chromaticity (xy): ')
        if isempty(wpchromaticity), return; end

        Yw = ipGet(vci,'maxdisplayluminance');
        XYZw = xyy2xyz([wpchromaticity(1),wpchromaticity(2),Yw]);
        displayXYZ = ipGet(vci,'displayXYZ');
        
        %  XYZw = [1,1,1]*diag(sFactor)*displayXYZ = sFactor*displayXYZ
        %  
        sFactor = XYZw*inv(displayXYZ);
        spd = ipGet(vci,'spd');
        vci = vcimageClearData(vci);
        vci.display.spd = spd*diag(sFactor);
        % chromaticity(ipGet(vci,'whitepoint'))
    otherwise
        error('Unknown format for white point.');
end


return;


