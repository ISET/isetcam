function val = oiPSF(oi,param,varargin)
% Utility for summarizing OI containing a single point spread image
%
% Syntax
%   val = oiPSF(oi,param,varargin);
%
% Input
%  oi:
%  param
%
% Output
%   val: Calculated value in param
%
% param options
%    area:       Area of the PSF that exceeds a threshold of max PSF
%    diameter:   Diameter of the PSF that exceeds a threshold
%
% See also
%  isetlens-s_isetauto

%% Should add input parser
p = inputParser;
p.addRequired('oi',@isstruct);
p.addRequired('param',@ischar);

p.addParameter('units','m',@ischar);
p.addParameter('threshold',0.1,@isscalar);

p.parse(oi,param,varargin{:});

%%
param = ieParamFormat(param);
switch param
    case 'area'
        % oiPSF(oi,'area','units','um','threshold',0.1);
        %
        % Estimate the diameter of the point spread (illuminance). If the
        % PSF is roughly circular, then this is a meaningful estimate of
        % the PSF diameter.  Perhaps we should check the circularity.
        %
        ill = oiGet(oi,'illuminance');
        
        % Find all the points that are at least 10 percent the amplitude of
        % the peak illuminance
        threshold = p.Results.threshold;
        mx = max(ill(:));
        ill(ill < threshold*mx)  = 0;
        ill(ill >= threshold*mx) = 1;
        
        % Find the area of the points about 10 percent max in microns.
        % Each little rectangle has the area of prod(sampleSpacing).
        units = p.Results.units;
        sampleSpacing = oiGet(oi,'sample spacing',units);
        val = sum(ill(:))*prod(sampleSpacing);
    case 'diameter'
        % oiPSF(oi,'diameter','units','um','threshold',0.1);
        %
        % Estimate the diameter of the point spread (illuminance). If the
        % PSF is roughly circular, then this is a meaningful estimate of
        % the PSF diameter.  Perhaps we should check the circularity.
        %
        psArea = oiPSF(oi,'area',...
            'units',p.Results.units,...
            'threshold',p.Results.threshold);
        
        % circleArea = pi*radius^2 = pi*(diameter/2)^2
        %
        %   diameter = 2*sqrt(circleArea/pi)
        %
        val = 2*(psArea/pi)^0.5;   % Diameter in microns
    otherwise
        error('Unknown psf parameter %s\n',param);
end

