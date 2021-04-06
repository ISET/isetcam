function imgT = imageTranslate(img,shift, fillValues)
% Translate image data
%
%   imgT = imageTranslate(scene,shift);
%
% img:  RGB format data (can be multispectral)
% shift: (x,y) displacement in pixels
%
% Translate image data by shift(x,y) steps. The trailing region is filled
% with zeros. The translation is always arranged to be at the discrete step
% size of the image to avoid blurring by interpolation.
%
% Programming TODO:
%  Allow interpolation, and use maketform structure.
%
% Example:
%   scene = sceneCreate;
%   dxy = [1,0];                          % This is in degrees
%   scene = sceneTranslate(scene,dxy);    % Converts from deg to pixel
%   ieAddObject(scene); sceneWindow;
%
% Copyright Imageval, LLC, 2014

%% Use this form because we may loop on this routine a lot
if ~exist('img','var')   || isempty(img), error('Image required'); end
if ~exist('shift','var') || isempty(shift), error('(x,y) Displacement required'); end
if ~exist('fillValues', 'var')
    fillValues = 0; % default
end
% Legacy as we now support sub-pixel shifts
% if round(shift) ~= shift
%     shift = round(shift);
%     warning('Rounding the shift to integer size');
% end

rcw = size(img);   % Row, column, wavelength

%% There should be different cases.  

% This is the only one we handle just now, which produces an
% upward/leftward displacement (both positive). We will need to handle
% negative shift, too.

% now legacy code...
%if shift(2) >= 0, cc = (shift(2)+1):rcw(2); end
%if shift(1) >= 0, rr = (shift(1)+1):rcw(1); end

% Note that we assume + is up/left, but by default Matlab assumes
% down/right
if length(rcw) == 2
   imgT = imtranslate(img, [-1 * shift(1), -1 * shift(2)], 'FillValues', fillValues);
else
   imgT = imtranslate(img, [-1 * shift(1), -1 * shift(2), 0], 'FillValues', fillValues);
end

% old code
% imgT = zeros(size(img));
% if length(rcw)     == 2
%     imgT(1:length(rr),1:length(cc)) = img(rr,cc);
% elseif length(rcw) == 3
%     for ww=1:rcw(3)
%         imgT(1:length(rr),1:length(cc),ww) = img(rr,cc,ww);
%     end
% end


end

