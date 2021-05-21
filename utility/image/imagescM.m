function barHndl = imagescM(img,mp,barDir,noScale)
% Display a monochrome image
%
%   barHndl = imagescM(img,[mp = gray(256)],[barDir = 'hoiriz'],[noScale = false])
%
%  Optionally, the image can contain a color bar to measure the values in
%  the image.
%
%  If noScale = 1, then image(img) is used.  If noScale = 0, then
%  imagesc(img) is used.
%  The color bar handle is returned in case the indices need to be
%  converted to other calibrated values.
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('mp'), mp = gray(256); end
if ieNotDefined('barDir'), barDir = 'none'; end
if ieNotDefined('noScale'), noScale = 0; end
barHndl = [];

if isempty(img), return; end

% Should this be imshow?
if noScale, image(img);
else imagesc(img); end
colormap(mp);

if ~strcmp(barDir,'none')
    barHndl = colorbar(barDir);
    % Position = [0.07 0.17 0.6 0.03];
    % set(barHndl,'Position',Position)
end

axis image; axis off

return;