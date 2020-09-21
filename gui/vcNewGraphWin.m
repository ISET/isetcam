function figHdl = vcNewGraphWin(figHdl, fType, varargin)
% Deprecated:  Calls ieNewGraphWin;
%

if ~exist('figHdl','var'), figHdl = []; end
if ~exist('fType','var'), fType = 'default'; end

figHdl = ieNewGraphWin(figHdl, fType, varargin{:});

end

%{
if ieNotDefined('figHdl'), figHdl = figure; end
if ieNotDefined('fType')  
    fType = 'default'; 
    wPos = ieSessionGet('wpos');
    wPos = wPos{6};
    if isempty(wPos), fType = 'upperleft'; end
end

set(figHdl,'Name','ISET GraphWin','NumberTitle','off');
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
%}

