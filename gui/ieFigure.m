function thisFigure = ieFigure(thisFigure, fType, titleString, varargin)
% Open a window for plotting
%
% figHdl = ieFigure([fig handle],[figure type],[titleString],varargin)
%
% Open a figure.  The Matlab figure handle is returned.
%
% A few figure shapes are pre-defined
%   fType:  Default - Matlab normal figure position
%           upper left    Simple (default)
%           tall          (for 2x1 format)
%           wide          (for 1x2 format)
%           upperleftbig  (for 2x2 format)
%           upperright    Simple
%
%   This list may grow.
%
% The varargin options are a set of (param,val) pairs that are applied
%
%     set(gcf,param,val);
%
% You can set your preferred color order and other properties in the
% startup file by using set() command with the graphics root
% structure
%
%   groot = get(0);
%   % Color order, RGB ...
%   co = [1 0 0; 0 1 0 ; 0 0 1; 1 0 1; 0 1 1; 0 0 0];
%   set(groot,'defaultAxesColorOrder',co)
%   set(groot,'DefaultAxesFontsize',16)
%   set(groot,'DefaultAxesFontName','Georgia')
%
% Examples:
%  ieNewGraphWin;
%
%  ieNewGraphWin([],'upper left')
%  ieNewGraphWin([],'tall')
%  ieNewGraphWin([],'wide')
%  ieNewGraphWin([],'upper left big')
%
% Or set your own position
%  ieNewGraphWin([],[],'position',[0.5 0.5 0.28 0.36]);
%
% To set other fields, use
%  ieNewGraphWin([],'wide','Color',[0.5 0.5 0.5])
%  g = ieNewGraphWin([],[],'Visible','Off');
%  g.Visible = 'on';
%
% See also:
%   ieSessionSet
%

%%
if ieNotDefined('thisWindow'), thisFigure = figure; end
if ieNotDefined('fType')
    fType = 'upperleft';
end
if ieNotDefined('titleString'), titleString = 'ISET GraphWin'; end

thisFigure.Name = titleString;
thisFigure.NumberTitle = 'Off';

% when deployed we can't use chararray syntax, apparently
if isdeployed
    thisFigure.CloseRequestFcn = @ieCloseRequestFcn;
else
    thisFigure.CloseRequestFcn = 'ieCloseRequestFcn';
end

thisFigure.Color = [1 1 1];
thisFigure.Units = 'normalized';

% Position the figure
fType = ieParamFormat(fType);

switch(fType)
    case {'default','upperleft'}
        thisFigure.Position = [0.007 0.55  0.28 0.36];
    case 'upperright'
        thisFigure.Position = [0.7156    0.5611    0.2801    0.3597];
    case 'lowerleft'
        thisFigure.Position = [0.0098    0.0403    0.2801    0.3597];
    case 'lowerright'
        thisFigure.Position = [0.7098    0.0403    0.2801    0.3597];
    case 'tall'
        thisFigure.Position = [0.007 0.055 0.28 0.85];
    case 'wide'
        thisFigure.Position = [0.007 0.62  0.60  0.3];
    case {'upperleftbig','big'}
        % Like upperleft but bigger
        thisFigure.Position = [0.007 0.40  0.40 0.50];
    otherwise % Matlab default
end

%% Apply the varargin arguments as key/value pairs
if ~isempty(varargin)
    n = length(varargin);
    if ~mod(n,2)
        for ii=1:2:(n-1)
            set(thisFigure,varargin{ii},varargin{ii+1});
        end
    end
end

%% Store some information.  Not sure it is needed; not much used.
% ieSessionSet('graphwinfigure',thisWindow);
% ieSessionSet('graphwinhandle',guidata(thisWindow));

end
