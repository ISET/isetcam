function oi = opticsPlotOffAxis(oi,thisW)
% Plot relative illumination (off-axis) fall off
%
% Synopsis
%   oi = opticsPlotOffAxis(oi,val)
%
% Input
%  oi:      Optical image
%  thisW:   Window
%
% Return
%  oi:      Optical image, not really modified but maybe a little for
%           storing the cos4th data
%
% Description
%   Plot the off-axis fall-off for the current optical image and optics
%   assumptions.
%
%   The data are stored in the oi{val} if that parameter is sent in.
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('thisW'), thisW = []; end

optics = oiGet(oi,'optics');
data = opticsGet(optics,'cos4th');

if isempty(data)
    % The fall-off data have not been calculated for the current
    % (shift-invariant) optical image.  We calculate the off-axis here and
    % we store it in optics/oi in case the calling return wants to keep
    % the result.
    method = opticsGet(optics,'cos4th function');
    if isempty(method), method = 'cos4th'; end
    switch method
        case 'cos4th'
            % Calculating the cos4th scaling factors We might check whether
            % the data exist already and only do this if the cos4th slot is
            % empty.
            optics = cos4th(oi);  % Returns optics with cos4th data attached
            oi   = oiSet(oi,'optics',optics);
            data = opticsGet(optics,'cos4th data');
        otherwise
            % This path is almost never used and needs a lot of testing.
            % And documentation.
            optics = feval(method, optics, oi);
            oi   = oiSet(oi,'optics',optics);
            data = opticsGet(optics,'cos4th data');
    end
end

switch class(thisW)
    case ''
        thisW = ieNewGraphWin;
    case 'matlab.ui.Figure'
    otherwise
        error('Unknown window types %s\n',class(thisW));
end

mesh(data);
xlabel('Row'),ylabel('Col'),zlabel('Relative intensity');
title('Relative illumination');
grid on;

set(thisW,'Userdata',data);

end
