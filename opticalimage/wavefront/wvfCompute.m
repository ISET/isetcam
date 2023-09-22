function wvf = wvfCompute(wvf,varargin)
% Compute the pupil function and the point spread function
%
% Synopsis
%   wvf = wvfCompute(wvf,varargin)
%
% Brief description
%   Wrapper for computing the pupil function and psf for the general
%   optics calculation.  
%
% Input
%   wvf
%
% Optional key/val
%   compute pupil function - Call wvfComputePupilFunction
%   compute psf   - Call wvfComputePSF
%   aperture function      - Use this aperture function (matrix)
%   human lca              - Add human longitudinal chromatic aberration
%                            when computing the pupil function
%   lca function           - Use this longitudinal chromatic aberration
%                            function     
%   compute sce            - Add Stiles Crawford effect to aperture
%                            function 
%
% Output
%   wvf - modified wavefront structure
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
%   wvfComputePSF, wvfComputePupilFunction, wvfAperture

%% Parse

varargin = ieParamFormat(varargin);

p = inputParser;

p.addRequired('wvf',@isstruct);
p.addParameter('computepupilfunction',true,@islogical);
p.addParameter('computepsf',true,@islogical);

p.addParameter('humanlca',false,@islogical);   % Apply longitudinal chromatic aberration
p.addParameter('lcafunction',[],@ismatrix);
p.addParameter('aperture',[],@ismatrix);
p.addParameter('computesce',false,@islogical);   % Apply Stiles Crawford effect to aperture function

p.parse(wvf,varargin{:});
params = p.Results;

%% Parameters for computing the pupil function

if params.computepupilfunction

    if params.humanlca && ~isempty(params.lcafunction)
        error('You cannot specify human lca and a custom lca function.')
    end
   
    wvf  = wvfComputePupilFunction(wvf,...
        'human lca',        params.humanlca, ...
        'aperture',         params.aperture, ...
        'compute sce',      params.computesce, ...
        'lca function',     params.lcafunction);
else
    warning('No pupil function computed.');
end

%{
ieNewGraphWin([], 'wide');
subplot(1,3,1); wvfPlot(wvf,'image pupil amp','unit','um','wave',550,'window',false);
subplot(1,3,2); wvfPlot(wvf,'image pupil phase','unit','um','wave',550,'window',false);
subplot(1,3,3); wvfPlot(wvf,'image wavefront aberrations','unit','um','wave',550,'window',false);
%}

%%
if p.Results.computepsf
    wvf  = wvfComputePSF(wvf,'compute pupil func', false);
else
    warning('no psf computed.');
end

end

