function figHdl = ieNewGraphWin(figHdl, fType, titleString, varargin)
% Open a window for plotting (future of vcNewGraphWin)
%
%    figHdl = ieNewGraphWin([fig handle],[figure type],[titleString],varargin)
%
% Open a figure.  The figure handle is returned and stored in the currernt
% vcSESSION.GRAPHWIN entry.
%
% A few figure shapes are pre-defined
%   fType:  Default - Matlab normal figure position
%           upper left    Simple
%           tall          (for 2x1 format)
%           wide          (for 1x2 format)
%           upperleftbig  (for 2x2 format)
%   This list may grow.
%
% The varargin options are a set of (param,val) pairs that are applied
%
%     set(gcf,param,val);
%
% You can set your preferred color order and other properties in the
% startup, say by using 
%
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
%  g = ieNewGraphWin([],[],'Visible','off'); 
%  set(g,'Visible','on')
%
% Copyright ImagEval Consultants, LLC, 2005
%
% See also:  
%   ieSessionSet
%


%% TODO
% We should make vcNewGraphWin call this
%
%    

%%
if ieNotDefined('figHdl'), figHdl = figure; end
if ieNotDefined('fType')  
    fType = 'default'; 
    wPos = ieSessionGet('wpos');
    wPos = wPos{6};
    if isempty(wPos), fType = 'upperleft'; end
end
if ieNotDefined('titleString'), titleString = 'ISET GraphWin'; end

set(figHdl,'Name',titleString,'NumberTitle','off');
set(figHdl,'CloseRequestFcn','ieCloseRequestFcn');
set(figHdl,'Color',[1 1 1]);

% Position the figure
fType = ieParamFormat(fType);
switch(fType)
    case 'default'
        % Use the getpref window position for the graph window
        set(figHdl,'Units','normalized','Position',wPos);
    case 'upperleft'
        set(figHdl,'Units','normalized','Position',[0.007 0.55  0.28 0.36]);
    case 'tall'
        set(figHdl,'Units','normalized','Position',[0.007 0.055 0.28 0.85]);
    case 'wide'
        set(figHdl,'Units','normalized','Position',[0.007 0.62  0.60  0.3]);
    case {'upperleftbig','big'}
        % Like upperleft but bigger
        set(figHdl,'Units','normalized','Position',[0.007 0.40  0.40 0.50]);
    otherwise % Matlab default
end

%% Apply the varargin arguments as key/value pairs
if ~isempty(varargin)
    n = length(varargin);
    if ~mod(n,2)
        for ii=1:2:(n-1)
            set(figHdl,varargin{ii},varargin{ii+1});
        end
    end
end

%% Store some information.  Not sure it is needed; not much used.
ieSessionSet('graphwinfigure',figHdl);
ieSessionSet('graphwinhandle',guidata(figHdl));

end
