function txt = mlDescription(ml)
%Text for the upper right of the microLensWindow
%
%  txt = mlDescription(ml)
%
% See also:  microLensWindow
%
% Copyright ImagEval Consultants, LLC, 2006.

% Initialize
txt = [];

% Row and col position relative to (0,0) at center (CRA = 0)
cra = mlensGet(ml,'chief ray angle radians');
sfl = mlensGet(ml,'source focal length','mm');

%% Pixel size and ml diameter

pixSize = sensorGet(vcGetObject('sensor'),'pixel width','um');
newtxt = sprintf('  Pixel width (um) %.2f\n',pixSize);
txt = addText(txt,newtxt);

diameter = mlensGet(ml,'diameter','um');
if diameter > pixSize, sizeException = '(uLens too big)'; else sizeException = ' '; end
newtxt = sprintf('  ML diameter (um) %.2f %s\n\n',diameter,sizeException);
txt = addText(txt,newtxt);

% This is where we are in terms of distance given the CRA
%
% The tangent of the chief ray angle is opposite over adjacent
%  (X/sfl) = tan(cra)
%
% The number of pixels away is opposite divided by pixel size
X = sfl*tan(cra);     % Distance from center in mm
newtxt = sprintf('  Distance from center (mm) %.2f\n',X);
txt = addText(txt,newtxt);

% The pixel position along the horizontal and diagonal paths are
hPix = X/pixSize;
dPix = X/(pixSize*sqrt(2));
newtxt = sprintf('  horiz pix (%i), diag pix (%i)\n',round(hPix),round(dPix));
txt = addText(txt,newtxt);

% The Etendue of the pixel
etendue = mlensGet(ml,'etendue');
if ~isempty(etendue)
    newtxt = sprintf('  Etendue: %.3f\n',etendue);
    txt = addText(txt,newtxt);
end

% The optimal offset (um) for the current chief ray angle
% Positive offset should be towards the center, always.  Trying to check to
% make this so.
optimalOffset = mlensGet(ml,'optimal offset');       %
newtxt = sprintf('  Optimal offset = %.2f (um)\n',optimalOffset);
txt = addText(txt,newtxt);

end