% LFDispVidCirc - visualize a 4D light field animating a circular path through two dimensions
%
% Usage:
%
%     FigureHandle = LFDispVidCirc( LF )
%     FigureHandle = LFDispVidCirc( LF, PathRadius_percent, FrameDelay )
%     FigureHandle = LFDispVidCirc( LF, PathRadius_percent, FrameDelay, ScaleFactor )
%     FigureHandle = LFDispVidCirc( LF, [], [], ScaleFactor )
%
%
% A figure is set up for high-performance display, with the tag 'LFDisplay'. Subsequent calls to
% this function and LFDispVidCirc will reuse the same figure, rather than creating a new window on
% each call. All parameters except LF are optional -- pass an empty array "[]" to omit an optional
% parameter.
%
%
% Inputs:

function FigureHandle = LFDispVidCirc( LF, PathRadius_percent, FrameDelay, varargin )

%---Defaults---
PathRadius_percent = LFDefaultVal( 'PathRadius_percent', 60 );
FrameDelay = LFDefaultVal( 'FrameDelay', 1/60 );


%---Check for mono and clip off the weight channel if present---
Mono = (ndims(LF) == 4);
if( ~Mono )
    LF = LF(:,:,:,:,1:3);
end

%---Rescale for 8-bit display---
if( isfloat(LF) )
    LF = uint8(LF ./ max(LF(:)) .* 255);
else
    LF = uint8(LF.*(255 / double(intmax(class(LF)))));
end

% Create a representative frame for setup (handle mono or colour LF)
if ndims(LF) == 5
    [TSize, SSize, ~, ~, ~] = size(LF);
    sampleFrame = squeeze(LF(max(1, floor(TSize/2)), max(1, floor(SSize/2)), :, :, :));
else
    sampleFrame = squeeze(LF(max(1, floor(end/2)), max(1, floor(end/2)), :,:));
end

%---Setup the display---
[ImageHandle,FigureHandle] = LFDispSetup( sampleFrame, varargin{:} );

%---Setup the motion path---
if ndims(LF) == 5
    % colour: LF is T x S x X x Y x C
    [TSize,SSize, ~,~, ~] = size(LF);
    getFrame = @(ti,si) squeeze(LF(ti, si, :,: ,1:min(3,size(LF,5))));
else
    % mono: LF is T x S x X x Y
    [TSize,SSize, ~,~] = size(LF);
    getFrame = @(ti,si) squeeze(LF(ti, si, :,:));
end

TCent = (TSize-1)/2 + 1;
SCent = (SSize-1)/2 + 1;

t = 0;
RotRate = 0.05;
RotRad = TCent * PathRadius_percent / 100;

fprintf('Click on video window and press Escape to close.\n');
show = true;
while show
    % compute circular path indices
    TVal = TCent + RotRad * cos( 2*pi*RotRate * t );
    SVal = SCent + RotRad * sin( 2*pi*RotRate * t );
    SIdx = min(max(1, round(SVal)), SSize);
    TIdx = min(max(1, round(TVal)), TSize);

    % get current frame (handles 4-D or 5-D LF)
    CurFrame = getFrame(TIdx, SIdx);

    % only update if figure and image are valid
    if ~isempty(ImageHandle) && ishandle(ImageHandle) && ishandle(FigureHandle)
        try
            set(ImageHandle,'CData', CurFrame );
        catch ME
            warning('LFDispVidCirc:GraphicsUpdateFailed','Updating image CData failed: %s', ME.message);
            show = false;
            break;
        end
    else
        show = false;
        break;
    end

    drawnow limitrate;
    pause(FrameDelay);
    t = t + 1;

    if ishandle(FigureHandle)
        key = get(FigureHandle, 'CurrentKey');
        if ischar(key) && strcmpi(key, 'escape')
            show = false;
        end
    else
        show = false;
    end
end

if ishandle(FigureHandle)
    close(FigureHandle);
end
end
