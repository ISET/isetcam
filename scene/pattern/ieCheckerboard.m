function im = ieCheckerboard(checkPeriod, nCheckPairs)
% Create a checkerboard image
%
% Syntax:
%	im = checkerboard(checkPeriod, nCheckPairs)
%
% Description:
%    A black and white checkerboard image, suitable for using as part of a
%    test scene (say for optical geometric distortion) is returned. The
%    checkPeriod is specified in terms of pixels. The number of pairs of
%    black and white checks (both vertically and horizontally) is then also
%    created.
%
% Inputs:
%    checkPeriod - (Optional) The size of the squares in pixels. Default 16
%    nCheckPairs - (Optional) The number of sqares of each color in a row
%                  or column. Default 8.
%
% Outputs:
%    im          - The created image
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    02/02/18  jnm  Formatting & rename function to match filename.

% Examples:
%{
    im = checkerboard(16, 8); 
    imshow(im);
    colormap(gray);
    imwrite(im, fullfile(tempdir,'checkerboard.jpg'), 'jpeg');
%}


if notDefined('checkPeriod'), checkPeriod = 16; end
if notDefined('nCheckPairs'), nCheckPairs =  8; end

basicPattern = kron([0, 1; 1 , 0], ones(checkPeriod));
im = repmat(basicPattern, nCheckPairs, nCheckPairs);

end