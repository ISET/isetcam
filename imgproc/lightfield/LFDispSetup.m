% LFDispSetup - helper function used to set up a light field display
% 
% Usage: 
% 
%     [ImageHandle, FigureHandle] = LFDispSetup( InitialFrame )
%     [ImageHandle, FigureHandle] = LFDispSetup( InitialFrame, ScaleFactor )
% 
% 
% This sets up a figure for LFDispMousePan and LFDispVidCirc. The figure is configured for
% high-performance display, and subsequent calls will reuse the same figure, rather than creating a
% new window on each call. The function should handle both mono and colour images.
% 
% 
% Inputs:
% 
%     InitialFrame : a 2D image with which to start the display
% 
% Optional Inputs: 
% 
%     ScaleFactor : Adjusts the size of the display -- 1 means no change, 2 means twice as big, etc.
%                   Integer values are recommended to avoid scaling artifacts. Note that the scale
%                   factor is only applied the first time a figure is created -- i.e. the figure
%                   must be closed to make a change to scale.
% 
% Outputs:
% 
%     FigureHandle, ImageHandle : handles of the created objects
%
%
% See also:  LFDispVidCirc, LFDispMousePan

% Part of LF Toolbox v0.4 released 12-Feb-2015
% Copyright (c) 2013-2015 Donald G. Dansereau

function [ImageHandle, FigureHandle] = LFDispSetup( InitialFrame, ScaleFactor )

FigureHandle = findobj('tag','LFDisplay');
if( isempty(FigureHandle) )

    % Get screen size
    set( 0, 'units','pixels' );
    ScreenSize = get( 0, 'screensize' );
    ScreenSize = ScreenSize(3:4);
    
    % Get LF display size
    FrameSize = [size(InitialFrame,2),size(InitialFrame,1)];
    
    % Create the figure
    FigureHandle = figure(...
        'doublebuffer','on',...
        'backingstore','off',...
        ...%'menubar','none',...
        ...%'toolbar','none',...
        'tag','LFDisplay');
    
    % Set the window's position and size
    WindowPos = get( FigureHandle, 'Position' );
    WindowPos(3:4) = FrameSize;
    WindowPos(1:2) = floor( (ScreenSize - FrameSize)./2 );
    set( FigureHandle, 'Position', WindowPos );
    
    % Set the axis position and size within the figure
    AxesPos = [0,0,size(InitialFrame,2),size(InitialFrame,1)];
    axes('units','pixels',...
         'Position', AxesPos,...
         'xlimmode','manual',...
         'ylimmode','manual',...
         'zlimmode','manual',...
         'climmode','manual',...
         'alimmode','manual',...
         'layer','bottom');
     
    ImageHandle = imshow(InitialFrame);
    % If a scaling factor is requested, apply it
    if( exist('ScaleFactor','var') )
        truesize(floor(ScaleFactor*size(InitialFrame(:,:,1))));
    end
else
    ImageHandle = findobj(FigureHandle,'type','image');
    set(ImageHandle,'cdata', InitialFrame);
end

