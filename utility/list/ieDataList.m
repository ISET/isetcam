function [names, data, nSamples] = ieDataList(type, varargin)
% Create lists of different types of data
%
% This function is incomplete and poorly documented.
%
% Input
%   dataType
%  
% Optional
%   'wave'
%
% Output
%   names
%   data
%   nSamples
%
% See also
%  We deleted an old thing called ieData which seemed even worse.
%

% Example:
%{
[n,d,s] = ieDataList('refl')
%}
%{
ieDataList('light')
%}

%% Parser
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('type', @ischar);
p.addParameter('wave', 400:10:700, @isnumeric);
p.parse(type, varargin{:});
wave = p.Results.wave;
%%
switch ieParamFormat(type)
    case {'refl', 'reflectance'}
        [names, data, nSamples] = ieReflectanceList('wave', wave);
    case {'light'}
        [names, data, nSamples] = ieLightList('wave', wave);
    case {'sensorqe'}
end

end