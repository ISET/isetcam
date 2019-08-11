% LFDispMousePan - visualize a 4D light field using the mouse to pan through two dimensions
% 
% Usage: 
%     FigureHandle = LFDispMousePan( LF )
%     FigureHandle = LFDispMousePan( LF, ScaleFactor )
% 
% A figure is set up for high-performance display, with the tag 'LFDisplay'. Subsequent calls to
% this function and LFDispVidCirc will reuse the same figure, rather than creating a new window on
% each call.  The window should be closed when changing ScaleFactor.
% 
% Inputs:
% 
%     LF : a colour or single-channel light field, and can a floating point or integer format. For
%          display, it is converted to 8 bits per channel. If LF contains more than three colour
%          channels, as is the case when a weight channel is present, only the first three are used.
% 
% Optional Inputs: 
% 
%     ScaleFactor : Adjusts the size of the display -- 1 means no change, 2 means twice as big, etc.
%                   Integer values are recommended to avoid scaling artifacts. Note that the scale
%                   factor is only applied the first time a figure is created. To change the scale
%                   factor, close the figure before calling LFDispMousePan.
% 
% Outputs:
% 
%     FigureHandle
%
%
% See also: LFDisp, LFDispVidCirc

% Part of LF Toolbox v0.4 released 12-Feb-2015
% Copyright (c) 2013-2015 Donald G. Dansereau

function FigureHandle = LFDispMousePan( LF, varargin )

%---Defaults---
MouseRateDivider = 30;

%---Check for weight channel---
HasWeight = (size(LF,5) == 4);

%---Discard weight channel---
if( HasWeight )
    LF = LF(:,:,:,:,1:3);
end

%---Rescale for 8-bit display---
if( isfloat(LF) )
    LF = uint8(LF ./ max(LF(:)) .* 255);
else
    LF = uint8(LF.*(255 / double(intmax(class(LF)))));
end

%---Setup the display---
[ImageHandle,FigureHandle] = LFDispSetup( squeeze(LF(max(1,floor(end/2)),max(1,floor(end/2)),:,:,:)), varargin{:} );

BDH = @(varargin) ButtonDownCallback(FigureHandle, varargin);
BUH = @(varargin) ButtonUpCallback(FigureHandle, varargin);
set(FigureHandle, 'WindowButtonDownFcn', BDH );
set(FigureHandle, 'WindowButtonUpFcn', BUH );


[TSize,SSize, ~,~] = size(LF(:,:,:,:,1));
CurX = max(1,floor((SSize-1)/2+1));
CurY = max(1,floor((TSize-1)/2+1));
DragStart = 0;

%---Update frame before first mouse drag---
LFRender = squeeze(LF(round(CurY), round(CurX), :,:,:));
set(ImageHandle,'cdata', LFRender);

fprintf('Click and drag to shift perspective\n');

function ButtonDownCallback(FigureHandle,varargin) 
set(FigureHandle, 'WindowButtonMotionFcn', @ButtonMotionCallback);
DragStart = get(gca,'CurrentPoint')';
DragStart = DragStart(1:2,1)';
end

function ButtonUpCallback(FigureHandle, varargin) 
set(FigureHandle, 'WindowButtonMotionFcn', '');
end

function ButtonMotionCallback(varargin) 
    CurPoint = get(gca,'CurrentPoint');
    CurPoint = CurPoint(1,1:2);
    RelPoint = CurPoint - DragStart;
    CurX = max(1,min(SSize, CurX - RelPoint(1)/MouseRateDivider));
    CurY = max(1,min(TSize, CurY - RelPoint(2)/MouseRateDivider));
    DragStart = CurPoint;
   
    LFRender = squeeze(LF(round(CurY), round(CurX), :,:,:));
    set(ImageHandle,'cdata', LFRender);
end

end