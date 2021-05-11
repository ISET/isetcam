function figHdl = vcNewGraphWin(figHdl, fType, varargin)
% Deprecated:  Now it simply calls ieNewGraphWin;
%
% vcNewGraphWin;
% vcNewGraphWin([],'wide');
% vcNewGraphWin([],'tall');
if ~exist('figHdl', 'var'), figHdl = []; end
if ~exist('fType', 'var'), fType = 'default'; end

figHdl = ieNewGraphWin(figHdl, fType, varargin{:});

end
