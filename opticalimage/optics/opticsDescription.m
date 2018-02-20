function txt = opticsDescription(optics)
% Text description of the optics properties. 
%
%  txt = opticsDescription(optics)
%
% Examples:
%  descriptionText = opticsDescription(optics)
%  descriptionText = opticsDescription([])
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('optics'), [val, optics] = vcGetSelectedObject('OPTICS'); end
if ~checkfields(optics,'name'), optics.name = 'No name'; end

txt = sprintf('Optics: %s\n',opticsGet(optics,'name'));
txt = [txt, sprintf(' NA       : \t%0.2e  \n', opticsGet(optics,'na'))];
txt = [txt, sprintf(' Aper Area: \t%0.2e m^2\n', opticsGet(optics,'aperture'))];
txt = [txt, sprintf(' Aper Diam: \t%0.2e m\n', opticsGet(optics,'diameter'))];

return;
