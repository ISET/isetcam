function imgOut = insertInImage(varargin)
% INSERTINIMAGE: Embed any text or graphics object in an input image
%
% Use insertInImage to embed, or burn, any text or graphics item into an
% image. You can specify, using a cell array of parameter-value pairs
% (PVs), or using a structure, any valid properties of the specified object
% to insert.
%
% SYNTAX: IMGOUT = INSERTINIMAGE(BASEIMAGE,INSERTIONCOMMAND,PVs)
%
% INPUTS:
%          BASEIMAGE: an image, or a handle to an image (or parent object
%                 containing an image), in which the object is to be
%                 embedded. (The image need not be displayed, unless a
%                 handle is provided.)
%
%          INSERTIONCOMMAND: text, rectangle, line, ellipse, etc. to embed
%                 in the image. Internally, insertInImage calls FEVAL;
%                 anything that works inside an feval command will work
%                 here. For example, you can insert the string 'TESTING' at
%                 [x,y] = [20,30] using feval( @() text('TESTING',20,30]),
%                 so the insertionCommand for this would be:
%                 @() text(20,30,'TESTING').
%
%                 TEXT:
%                 f = @() text(x,y,string);
%
%                 RECTANGLE:
%                 f = @() rectangle('position',[x y w h]);
%
%                 LINE:
%                 f = @() line(x,y);
%
%                 NOTE: INSERTIONCOMMAND may be a cell array of function
%                       handles! (See note at PVs below.)
%
%          PVs (OPTIONAL): Cell array or structure of any parameter-value
%                 pairs valid for the TYPE of object you wish to insert.
%                 (Note that this _may_ include a 'position' parameter,
%                 which will overwrite any position set with the insertion
%                 command. For example, when you insert a string, PVs can
%                 be any Parameter-Value pairs valid for TEXT objects. (See
%                 'Text Properties' for details.)
%
%                 NOTE: If INSERTIONCOMMAND is a cell array, PVs must be a
%                       cell array of cell arrays of PV pairs, one cell for
%                       each insertionCommand.
%
% OUTPUT:
%          IMGOUT: output RGB image of the same class as imgin, with
%                 embedded text or graphic item(s).
%
% EXAMPLES:
%
%%% Example 1: Text insertion
% img = imread('rice.png');
% imgOut = insertInImage(img, @()text(40,50,'This is embedded text!'),...
%    {'fontweight','bold','color','m','fontsize',11,...
%    'linewidth',3,'margin',5,'edgecolor',[0 1 1],'backgroundcolor','y'});
% imshow(imgOut);
%
%%% Example 2: Rectangle insertion
% img = imread('pout.tif');
% f = @() rectangle('position',[55 11 114 120]);
% params = {'linewidth',2,'edgecolor','c'};
% imgOut = insertInImage(img,f,params);
% imshow(imgOut);
%
%%% Example 3: Rectangle, Text, Line
% img = imread('cameraman.tif');
% % Cell array of function handles!
% f = {@() text(20,20,'This is the cameraman'),...
% 	@() line([20,40],[35,75])};
% % Cell array of (cell array of) PV-Pairs
% params = {{'color','y','fontsize',10,'fontweight','bold','edgecolor','m'},...
% 	{'color','c','linewidth',2}};
% imgOut = insertInImage(img,f,params);
% figure,imshow(imgOut)
%
%%% Example 4: Detect, label, and point to yellow circles
% img = imread('coloredChips.png');
% mask = rgb2gray(img);
% [centers,radii] = imfindcircles(mask,[20 30],...
% 	'Sensitivity',0.89,...
% 	'Method','TwoStage',...
% 	'ObjectPolarity','Bright');
% colors = jet(size(centers,1));
% fcnHndls = {@()text(20,30,'Auto-detected Yellow Circles')};
% params = {{'color',[0.6 0.2 0],'fontsize',24,'fontweight','b'}};
% for ii = 1:size(centers,1)
% 	fcnHndls = {fcnHndls{:},...
% 		@() rectangle('position',...
% 		[centers(ii,1)-radii(ii) centers(ii,2)-radii(ii) radii(ii)*2 radii(ii)*2]),...
% 		@() line('x',[100,centers(ii,1)],'y',[50,centers(ii,2)])};
% 	params = {params{:},...
% 		{'linewidth',4,'edgecolor','m','curvature',[1 1]},...
% 		{'linewidth',3,'color',colors(ii,:)}};
% end
% imgOut = insertInImage(img,fcnHndls,params);
% figure,imshow(imgOut)
%
%%% Example 5: SPECIFYING STRINGS, POSITIONS, ETC. DYNAMICALLY
%%% (In the above examples, strings and positions are hard-coded in the
%%% function definition. Note that you can use an anonymous function
%%% directly, with arguments, in the call to insertInImage):
%   xPos = 20;
%   yPos = 30;
%   myString = 'testing123';
%   compositeImage = imread('peppers.png');
%   textFormat.FontSize = 20;
%   textFormat.FontWeight = 'Bold';
%   textFormat.color = 'g';
%   textFormat.verticalAlignment = 'top';
%   alteredImg = insertInImage(compositeImage, @()text(xPos,yPos,myString), textFormat);
%   figure,imshow(alteredImg)
%
%
% NOTES:
%          SPECIFYING POSITION: Some items (like TEXT) cannot be created
%          without specifying a position inside the insertionCommand.
%          Others (like RECTANGLE) have default positions, which can be
%          modified using PVs. In the former case, you must include the
%          position with the insertionCommand. In either case, specifying
%          'position' as a PV pair will overwrite the initial position.
%
%          This function incorporates and uses functionality I have
%          previously shared on the File Exchage as |createButtonLabel|.
%
%          Usage of the function requires the Image Processing Toolbox.
%
% Created by Brett Shoelson, Ph.D.
% 10/15/2012
%
% brett.shoelson@mathworks.com (Comments/suggestions welcome!)
%
% NOTE: The Computer Vision System Toolbox provides some officially
%       supported functionality that may be useful here.
%
% See also: createButtonLabel, insertText, insertMarker,
%           insertObjectAnnotation, insertShape
% REVISIONS:
% 11/15/13  V2.0 Rearchitected to simplify and improve the extraction
%           of color information. No longer relies on masking the image
%           using the bounding box. Now recognizes backgroundColor and
%           edgeColor for text... Generally, much improved, more robust,
%           and yields better results.
%
% 12/3/13   Fixed a typo in the description. Also added an example
%           showing how one might use this specifying strings and positions
%           (for example) functionally (rather than hard-coded). (Thanks to
%           ImageAnalyst for the suggestion.
%
% 4/29/2016 V3.0 Major overhaul to use print-to-rgb instead of getframe.
%           Note that getframe behavior changed ("DPI-Aware Behavior") in
%           R2015b, in a manner that broke my code. This rework, suggested
%           by Andy Skinner (MathWorks), greatly simplifies the code and
%           fixes the issue. The code is now faster, and takes cell arrays
%           of function handles and PV-Paired cell arrays, as well (so you
%           can avoid making multiple calls to the function). Plus, the new
%           version no longer necessitates the visualization of a temporary
%           figure for screen capture! (Thanks, Andy!)
%
% 2/11/2017 Fixed bug for input mxnx3 base image--returns false for
%           ismatrix. (Now check for color image separately.)
%
% 07/04/2019 V3.1 Incoporated 'InvertHardcopy','off' into figure
%           construction. That property was causing poor behavior for black
%           text on a white backround, and vice versa.
% 07/09/2019 V3.2 Allow specification of resolution--much better results
%           with higher resolution, at the expense of memory/time.
%
% Copyright MathWorks, Inc. 2016.
[baseImage,insertionCommand,PVs,resolution] = parseInputs(varargin{:});
if isa(PVs,'struct')
    PVs = [fieldnames(PVs) struct2cell(PVs)]';
    PVs = PVs(:)';
end
if ishandle(baseImage)
    if ~strcmp(get(baseImage,'type'),'image')
        baseImage = findobj(baseImage,'type','image');
        baseImage = baseImage(1);
    end
    baseImage = get(baseImage,'cdata');
end
[m,n,~] = size(baseImage);
%
thisFig = figure('windowstyle','normal',...
    'units','pixels',...
    'menubar','none',...
    'position',[0 0 n m],...
    'invertHardcopy','off',...
    'visible','off',...
    'color',[0 0 0]);
axes('units','normalized','position',[0 0 1 1],...
    'visible','off','activepositionproperty','outerposition');
%NOTE: This is for debugging purposes, and can be commented out!
%thisFig.Visible = 'on';shg;
imshow(baseImage,'InitialMagnification',100);
hold on
%
if ~iscell(insertionCommand)
    insertionCommand = {insertionCommand};
end
if ~iscell(PVs{1})
    PVs = {PVs};
end
for ii = 1:numel(insertionCommand)
    insertObject(insertionCommand{ii},PVs{ii});
end
% dpi = get(groot, 'ScreenPixelsPerInch');
opt = [ '-r' num2str(resolution) ];
imgOut = print(thisFig,'-RGBImage',opt);%,opt);%'-r300');%opt
delete(thisFig);
% BEGIN NESTED SUBFUNCTIONS
    function applyPVs(obj,pvarray)
        if isempty(pvarray)
            return;
        end
        for jj = 1:2:numel(pvarray)
            set(obj,pvarray{jj},pvarray{jj+1});
        end
    end %applyPVs
    function insertObject(thisCommand,thisPV)
        tmp = feval(thisCommand);
        if ~isempty(thisPV)
            % Apply any input Parameter-Value pairs
            applyPVs(tmp,thisPV);
            drawnow;
        end
    end %insertObject
    function [baseImage,insertionCommand,PVs,resolution] = parseInputs(varargin)
        narginchk(2,4);
        baseImage = varargin{1};
        validateattributes(baseImage, {'double' 'uint8' 'uint16' 'int16' 'single'}, ...
            {'3d'}, mfilename, 'baseImage', 1);
        insertionCommand = varargin{2};
        validateattributes(insertionCommand,{'function_handle','cell'},{},mfilename,'insertionCommand',2)
        %Defaults:
        PVs = [];
        if nargin > 2
            PVs = varargin{3};
        end
        resolution = get(groot, 'ScreenPixelsPerInch');
        if nargin > 3
            resolution = varargin{4};
        end
    end %parseInputs
end