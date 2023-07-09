function [data, vObj] = ieMovie(data, varargin)
% Show a movie of an (x, y, t) or (x, y, c, t) matrix
%
% BW:  May not be up-to-date
%
% Syntax:
%   [data, vObj] = ieMovie(data, [varargin])
%
% Description:
%   Show a movie of a matrix of the format (x, y, t) or (x, y, c, t)
%   The letters representing row, column, time, and color. Of those, color
%   is an optional input.
%
%   If 'vname' is set, then an MPEG-4 (mp4) file is written to the vname
%   file.
%
% Inputs:
%    data      - The movie matrix, in the format (x, y, t) or (x, y, c, t)
%
% Outputs:
%    data      - The movie matrix, in the format (x, y, t) or (x, y, c, t)
%    vObj      - Matlab video object
%
% Optional key/val pairs:
%    step      - How many times frames to step over. Default 1.
%    show      - Display the movie. Default true.
%    vname     - Video file name. Default ''.
%    gamma     - Gamma exponent. Default d .^ gamma
%    ax        - Display axis. Default NONE.
%    FrameRate - Video frame rate. Default 20 - For video object.
%

% History:
%    xx/xx/16   bw  ISETBIO Team 2016
%    11/22/17  jnm  Formatting
%    01/06/18  dhb  Suppress warning for big videos.
%    01/18/18  jnm  Formatting update to match Wiki.

% Examples:
%{
    ieMovie(rand(50, 50, 20), 'show', false);
    ieMovie(rand(50, 50, 20), 'show', true, 'gamma', 1/1.5);
%}
%{
    vname = fullfile([tempname,'.mp4'])
    ieMovie(rand(50, 50, 20), 'show', true, 'vname', vname);
    ieMovie(rand(50, 50, 20), 'show', true, 'vname', vname, ...
        'FrameRate', 5);
    delete(vname);
%}
%{
    [mov, vObj] = ieMovie(randn(50, 50, 3, 20));
%}

%% Parse inputs
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('data', @isnumeric);

% Name-Value
p.addParameter('vname', '', @ischar);
p.addParameter('FrameRate', 20, @isnumeric);
p.addParameter('step', 1, @isnumeric);
p.addParameter('show', true, @islogical);
p.addParameter('gamma', 1, @isnumeric);
p.addParameter('ax', gca, @isgraphics);

p.parse(data, varargin{:});
data = p.Results.data;
step = p.Results.step;
vname = p.Results.vname;
show = p.Results.show;
gam = p.Results.gamma;
FrameRate = p.Results.FrameRate;

% User set a video name. So, figure they want it saved.
if ~isempty(vname), save = true; else, save = false; end

%% Create the movie and video object

% Video object & select the axes
vObj = [];
axes(p.Results.ax);

% Could be monochrome or rgb
% Time step is always the last dimension
tDim = ndims(data);
nFrames = size(data, tDim);

% If it is already within 0,1 range leave the data alone.
% Otherwise, scale to 0,1 and apply gamma
mind = min(data(:));
maxd = max(data(:));
if mind < 0 || maxd > 1
    data = ieScale(data, 0, 1);
    mind = 0; maxd = 1;
end

% Apply gamma correct
if gam ~= 1, data = data .^ gam; end

% Create the video object if we plan to save
if save
    % Suppress warning
    wState = warning('off','MATLAB:audiovideo:VideoWriter:mp4FramePadded');
    
    vObj = VideoWriter(vname,'MPEG-4');
    vObj.FrameRate = FrameRate;
    open(vObj);
end

% Step through each frame, saving in the video object (or not) and showing
% on the screen (or not)
if isequal(tDim, 4)
    % RGB data
    for ii = 1:step:size(data, tDim)
        imagesc(data(:, :, :, ii));
        axis image;
        set(gca, 'xticklabel', '', 'yticklabel', '');
        caxis([mind maxd]);
        drawnow;
        if ii == 1 && ~show, set(gcf, 'Visible', 'off'); end
        if save
            F = getframe;
            writeVideo(vObj, F);
        end
        pause(1 / FrameRate);
    end
elseif isequal(tDim, 3)
    % Monochrome data
    colormap(gray(256));
    for ii = 1:nFrames
        imagesc(data(:, :, ii));
        axis image;
        set(gca, 'xticklabel', '', 'yticklabel', '');
        caxis([mind maxd]);
        drawnow;
        if ii == 1 && ~show, set(gcf, 'Visible', 'off'); end
        if save, F = getframe; writeVideo(vObj, F); end
        pause(1 / FrameRate);
    end
end

% Write the video object if save is true
if save
    writeVideo(vObj, F);
    close(vObj);
    
    % Restore warning state
    warning(wState);
end

end
