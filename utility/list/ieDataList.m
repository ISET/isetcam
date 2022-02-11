function [names, data, nSamples] = ieDataList(type, varargin)

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
    case {'sensorqe'}
end

end