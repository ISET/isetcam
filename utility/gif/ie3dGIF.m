function gif_filename = ie3dGIF(hdl,varargin)
% Create a gif by oscillating a 3D plot around the azimuth 
%
% Synopsis
%   gif_filename = ie3dGIF(hdl,varargin)
%
% Inputs
%   hdl - Handle to the Matlab figure with the 3D plot
% 
% Key/val options
%   delay time
%   azimuth steps
%   image size
%   filename
%   elevation
%
% Output
%   gif_filename
%
% See also
%

% Example:
%{
hdl = figure;
scatter3(wgts(1,1:sNum), wgts(2,1:sNum), wgts(3,1:sNum), 50, 'b', 'filled'); hold on;
scatter3(wgts(1,sNum+1:end), wgts(2,sNum+1:end), wgts(3,sNum+1:end), 50, 'r', 'filled'); hold on;
legend({'Stanford','Granada'});
grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
fname = fullfile(isetRootPath,'local','test.gif');
gif_filename = ie3dGIF(hdl,'file name',fname,'azimuth steps',[0:10:90],'elevation',25);
%}

%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('hdl',@(x)(isa(x,'matlab.ui.Figure')));
p.addParameter('delaytime',0.35,@isnumeric);
p.addParameter('azimuthsteps',[0:5:90, 85:-5:0],@isvector);
p.addParameter('elevation',[],@isnumeric);
p.addParameter('imagesize',[],@isvector);
p.addParameter('filename','rotation.gif',@ischar);

p.parse(hdl,varargin{:});

delay_time   = p.Results.delaytime;
azSteps      = p.Results.azimuthsteps;
el           = p.Results.elevation;
imSize       = p.Results.imagesize;
gif_filename = p.Results.filename;

%%
% Select the figure
figure(hdl);
if isempty(p.Results.imagesize)
    % Store the original Units setting
    originalUnits = get(hdl, 'Units');

    % Temporarily set to 'pixels' to get the correct size
    set(hdl, 'Units', 'pixels');

    pos = get(hdl,'Position');
    row = pos(4); col = pos(3);
    imSize = [2*round(row/2),2*round(col/2)];

    % Restore original Units setting
    set(hdl, 'Units', originalUnits);
end

view(3); % Set initial view

% The elevation is 30 by default.  But maybe we should get the initial
% elevation the user set the figure?
for az = 1:numel(azSteps)

    % Use the current elevation in the window.
    if isempty(el),[~,el] = view; end
    view(azSteps(az), el);
    drawnow;

    % Save frame using exportgraphics (high quality)
    frame_filename = sprintf('frame_%03d.png', azSteps(az));
    exportgraphics(gca, frame_filename, 'Resolution', 150);

    % Read saved image back
    img = imread(frame_filename);

    % Ensure even dimensions (H.264 requires width & height to be even)
    img = imresize(img,imSize);
    [A, map] = rgb2ind(img, 256);
    if az == 1
        imwrite(A, map, gif_filename, 'gif', 'LoopCount', Inf, 'DelayTime', delay_time);
    else
        imwrite(A, map, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', delay_time);
    end

    delete(frame_filename); % Clean up temp images

end


end

