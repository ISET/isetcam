function fluorophorePlot(fl,pType,varargin)
% Gateway routine for plotting fluorophore data
%
% Input
%   fl - Fluorophore structure
%   pType - plot type.  Options are
%
% Optional key/value pairs
%
% Returns
%
% Wandell, Vistasoft team 2018
%
% See also
%

%%
p = inputParser;

pType = ieParamFormat(pType);
varargin = ieParamFormat(varargin);

p.addRequired('fl',@isstruct);
p.addRequired('pType',@ischar)
p.parse(fl,pType,varargin{:});

%%
switch pType
    case 'donaldsonmatrix'
        wave = fluorophoreGet(fl,'wave');
        dMatrix = fluorophoreGet(fl,'donaldson matrix');
        vcNewGraphWin;
        imagesc(wave,wave,dMatrix);
        grid on; xlabel('Wave (nm)'); ylabel('Wave (nm)');
        colorbar;
    case 'emission'
    case 'excitation'
    otherwise
        error('Unknown plot type %s\n',pType);
end