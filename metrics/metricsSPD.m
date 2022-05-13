function [val, params] = metricsSPD(spd1,spd2,varargin)
% Calculate metrics comparing two spectral power distributions
%
% Synopsis
%  [val, params] = metricsSPD(spd1,spd2,varargin)
%
% Inputs
%   spd1, spd2 - Two spectral power distributions in energy units
% 
% Optional key/val
%   metric - Either 'angle', 'cielab', or 'cct'
%   white point - XYZ white point (Default is XYZ of spd1)
%
% Return
%   val - The angle between the vectors, the delta E, or the mired of
%         the color temperature
%
% Description
%   We measure the difference between two spectral power
%   distributions in several ways.
%
% See also
%   s_metricsSPD.m, v_metrics.m

% Examples:
%{
 wave = 400:10:700;
 s1 = daylight(wave,6500);
 s2 = daylight(wave,5500);
 w = s1;
 ieNewGraphWin; plot(wave,s1,'-',wave,s2,'--');

 % Just the angle
 val = metricsSPD(s1,s2,'metric','angle');

 % The delta E
 [val,params] = metricsSPD(s1,s2,'metric','cielab','wave',400:10:700);

 % We can specify the white point. delta E value differs
 val = metricsSPD(s1,s2,'metric','cielab','white point',[94.9409  100.0000  108.6656]*5,'wave',400:10:700);
 val = metricsSPD(s1,s2,'metric','cielab','white point',[94.9409  100.0000  108.6656]/5,'wave',400:10:700);

 % The mired
 [val,params] = metricsSPD(s1,s2,'metric','cct','wave',400:10:700);
%}

varargin = ieParamFormat(varargin);
params = [];

p = inputParser;

% Which metric
% Options are:  angle, deltaE, noise
p.addRequired('spd1',@isvector);
p.addRequired('spd2',@(x)(numel(x) == numel(spd1)));

p.addParameter('metric','angle',@ischar);

% If deltaE or noise we set the spd (energy) to 100 cd/m2 or this
% value
p.addParameter('luminance',100,@isscalar);

% Default is D65, Y = 100
% wave = 400:10:700; ieXYZFromEnergy(daylight(wave,6500)',wave)
% [94.9409  100.0000  108.6656]
p.addParameter('whitepoint',[],@isvector);
p.addParameter('wave',(400:10:700),@(x)(numel(x) == numel(spd1)));

p.parse(spd1,spd2,varargin{:});


%%
switch p.Results.metric
    case 'angle'
        CosTheta = max(min(dot(spd1,spd2)/(vecnorm(spd1)*vecnorm(spd2)),1),-1);
        val = real(acosd(CosTheta));

    case 'cielab'
        wave = p.Results.wave;

        % Scale the spds to have the desired luminance
        spd1L = ieLuminanceFromEnergy(spd1,wave);
        spd1 = (spd1/spd1L)*p.Results.luminance;

        spd2L = ieLuminanceFromEnergy(spd2,wave);
        spd2 = (spd2/spd2L)*p.Results.luminance;

        whitePoint = p.Results.whitepoint;
        if isempty(whitePoint)
            % Use the first spd as the white point if not passed
            % Match the white point luminance
            whitePoint = ieXYZFromEnergy(spd1',wave);
            whitePoint = (whitePoint/whitePoint(2))*p.Results.luminance;
        end

        % Convert to CIELAB
        lab1 = ieXYZ2LAB(ieXYZFromEnergy(spd1',wave),whitePoint);
        lab2 = ieXYZ2LAB(ieXYZFromEnergy(spd2',wave),whitePoint);
        % Matlab's version.
        %  lab1 = xyz2lab(ieXYZFromEnergy(spd1',wave),'whitePoint',whitePoint);

        % Equivalent:  sqrt(sum((lab1 - lab2).^2))
        val = norm(lab1 - lab2,2);
        params.lab1 = lab1;
        params.lab2 = lab2;

    case {'mired','cct'}
        % Correlated color temperature difference 
        %  1/ccct1 - 1/cct2
        % Defined as mired.  See wikipedia.

        wave = p.Results.wave;

        [u(1),v(1)] = xyz2uv(ieXYZFromEnergy(spd1',wave),'uv');
        [u(2),v(2)] = xyz2uv(ieXYZFromEnergy(spd2',wave),'uv');
        uv = [u; v];
        cTemps = cct(uv);

        % This is the formula for mired
        % https://en.wikipedia.org/wiki/Mired
        val = abs(1/cTemps(2) - 1/cTemps(1))*1e6;

        params.cTemps = cTemps;
        params.uv = uv;

    otherwise
        error('Unknown metric %s',metric);
end

end

