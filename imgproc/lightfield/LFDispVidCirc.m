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
% 
%     LF : a colour or single-channel light field, and can a floating point or integer format. For
%          display, it is converted to 8 bits per channel. If LF contains more than three colour
%          channels, as is the case when a weight channel is present, only the first three are used.
% 
% Optional Inputs: 
% 
%     PathRadius_percent : radius of the circular path taken by the viewpoint. Values that are too
%                          high can result in collision with the edges of the lenslet image, while
%                          values that are too small result in a less impressive visualization. The
%                          default value is 60%.
% 
%             FrameDelay : sets the delay between frames, in seconds. The default value is 1/60th of
%                          a second.
% 
%            ScaleFactor : Adjusts the size of the display -- 1 means no change, 2 means twice as
%                          big, etc. Integer values are recommended to avoid scaling artifacts. Note
%                          that the scale factor is only applied the first time a figure is created.
%                          To change the scale factor, close the figure before calling
%                          LFDispMousePan.
% 
% Outputs:
% 
%     FigureHandle
%
%
% See also:  LFDisp, LFDispMousePan

% Part of LF Toolbox v0.4 released 12-Feb-2015
% Copyright (c) 2013-2015 Donald G. Dansereau

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

%---Setup the display---
[ImageHandle,FigureHandle] = LFDispSetup( squeeze(LF(floor(end/2),floor(end/2),:,:,:)), varargin{:} );

%---Setup the motion path---
[TSize,SSize, ~,~] = size(LF(:,:,:,:,1));
TCent = (TSize-1)/2 + 1;
SCent = (SSize-1)/2 + 1;

t = 0;
RotRate = 0.05;
RotRad = TCent*PathRadius_percent/100;

fprintf('Click on video window and press Escape to close.\n');
show = true;
while(show)
    TVal = TCent + RotRad * cos( 2*pi*RotRate * t );
    SVal = SCent + RotRad * sin( 2*pi*RotRate * t );
    
    SIdx = round(SVal);
    TIdx = round(TVal);
    
    CurFrame =  squeeze(LF( TIdx, SIdx, :,:,: ));
    set(ImageHandle,'cdata', CurFrame );
    
    pause(FrameDelay)
    t = t + 1;
    show = showTest(FigureHandle);
end

close(FigureHandle);

%% See if the escape key has been pressed
function val = showTest(figh)
val = true;
k = get(figh, 'CurrentKey');
switch k
    case 'escape'
        % When the user presses escape, we return an exit flag
        val = false;
    otherwise
        return;
end
% get(figh, 'CurrentCharacter')
% get(figh, 'CurrentModifier')
end

end


