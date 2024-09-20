function wvf = wvfCompute(wvf,varargin)
% Compute the pupil function and the point spread function
%
% Synopsis
%   wvf = wvfCompute(wvf,varargin)
%
% Brief description
%   Wrapper for computing the pupil function and psf based on a
%   wavefront for shift-invariant optics.
%
% Input
%   wvf - Wavefront struct (wvfCreate for an example)
%
% Optional key/val
%   compute pupil function - Call wvfComputePupilFunction
%   compute psf            - Call wvfComputePSF
%   aperture               - Use this aperture function (matrix)
%   compute sce            - Add Stiles Crawford effect to aperture
%                            function 
% Output
%   wvf - modified wavefront structure with pupil function and psf
%
% See also
%   wvfComputePSF, wvfComputePupilFunction, wvfAperture

%% Parse

varargin = ieParamFormat(varargin);

p = inputParser;

p.addRequired('wvf',@isstruct);
p.addParameter('computepupilfunction',true,@islogical);
p.addParameter('computepsf',true,@islogical);

p.addParameter('aperture',[],@ismatrix);
p.addParameter('computesce',false,@islogical);   % Apply Stiles Crawford effect to aperture function

p.parse(wvf,varargin{:});
params = p.Results;

%% Parameters for computing the pupil function

if params.computepupilfunction  
    wvf  = wvfComputePupilFunction(wvf,...
        'aperture',         params.aperture, ...
        'compute sce',      params.computesce);
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

