function wvf = wvfClearData(wvf)
% Clear data from wvf structure
%
%   wvf = wvfClearData(wvf)
%
% Clear the data from wvf struct, keep the necessary data only
%
% Zhenyi, 2024


wvf.psf = [];

wvf.wavefrontaberrations = [];

wvf.pupilfunc = [];

wvf.areapix = [];

wvf.areapixapod = [];

end