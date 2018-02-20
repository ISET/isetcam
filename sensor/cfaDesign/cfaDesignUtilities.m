%% Convert to XYZ and then sRGB
%
% This will be an example for designing CFAs.
% It is not yet implemented.
% It will demonstrate how to use cfaDesign functions using a script.

% 
% [data,wave] = ieReadSpectra('D65',wavelength,0);
% [XYZ,wave]= ieReadSpectra('XYZ',wavelength,0);
% spectrumXYZ=tran*XYZ;
% spectrumXYZ=spectrumXYZ/max(spectrumXYZ(:,2));
% size(tran)
% figure, plot(XYZ)
% 
% cc=makecform('xyz2srgb');
% visibleColor=applycform(,cc)
% % Some problem here with IR. all IR is showing up as red;
% % Check spectrum2sRGB conversion
% % For the moment make all IR gray
% if mu>=750
%     visibleColor=[0.3,0.3,0.3];
% end