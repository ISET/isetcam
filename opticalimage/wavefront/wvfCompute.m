function wvf = wvfCompute(wvf,varargin)
% Compute the pupil function and PSF
%
% More to do.
%
% Wrapper for computing the pupil function and psf for the general
% optics calculation.  
%
% Input
%   wvf
%
% Key/val pairs
%  lca - Add longitudinal chromatic aberration to pupil function
%  pupil function - Compute pupil function 
%  aperture function - Use this aperture function
%
% See also
% 

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('wvf',@isstruct);
p.addParameter('pupilfunction',true,@islogical);
p.addParameter('aperturefunction',[],@ismatrix);
p.addParameter('lca',false,@islogical);

p.parse(wvf,varargin{:});

%%  Designed for general optics
if p.Results.pupilfunction

    wvf  = wvfComputePupilFunction(wvf,...
        'lca',p.Results.lcafunction);    
end

wvf  = wvfComputePSF(wvf,'compute pupil func', false);

end

