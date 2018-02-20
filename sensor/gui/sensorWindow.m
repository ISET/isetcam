function h = sensorWindow(varargin)
% Show the sensor window allowing to set some of the display fields
%
%   h = sensorWindow(varargin)
%
% Example:
%   sensorWindow('scale',0);
%   sensorWindow('scale',1);
%   sensorWindow('visible','off');
%
%   figure(h.sensorImageWindow)
%
% (c) Copyright Imageval LLC, 2012


% Show the window and get the handle
sensorImageWindow;
h = ieSessionGet('sensor window handle');

if isempty(varargin), return; end

% Start the window and then parse the arguments
sensorImageWindow;

for ii = 1:2:length(varargin)
    p = ieParamFormat(varargin{ii});
    val = varargin{ii+1};
    switch p
        case 'scale'
            set(h.btnDisplayScale,'Value',val);
        case 'gamma'
            set(h.editGam,'String',num2str(val));
        case 'visible'
            % sensorWindow('visible','on');
            % sensorWindow('visible','off');
            set(h.sensorImageWindow,'visible',val)
        otherwise
            error('Unknown parameter %s\n',p);
    end
end

sensorImageWindow;  % Refreshes the window.

end



