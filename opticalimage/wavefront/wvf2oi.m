function oi = wvf2oi(wvf,varargin)
% Convert wavefront data to ISETCam optical image
%
% Syntax:
%   oi = wvf2oi(wvf)
%
% Description:
%    Convert a wavefront structure into an optical image whose optics match
%    the data in wvf.
%
%    Before calling this function, compute the pupil function and PSF,
%    using wvfCompute.
%
%    Non-optics aspects of the oi structure are assigned default values.
%
% Inputs:
%    wvf - A wavefront parameters structure (with a computed PF and PSF)
%
% Optional key/val
%
%    'human lens' - Replace the standard ISETCam lens transmittance slots
%                   with the human lens object used by ISETBio
%
% Outputs:
%    oi  - Optical image struct
%
% See also
%   oiCreate, s_wvfDiffraction
%
% Notes:
%  * BW:  ZL and I wrote the wvf2optics() method.  We needed it as part of
%     the deeper integration of wvf with oiCreate. We used it here to make
%     this function shorter and easier.
%  * BW:  The wvf2oi(wvf) function did not match the wvf and oi.  I spent a
%     bunch of time checking for the diffraction limited case on both the
%     wvf side and the oi side.  Still more to check (07.01.23). But
%     setting the umPerDeg is important (was not always done properly and
%     consistently with focal length. Also understanding the different
%     models (diffraction, humanmw, wvf human) will be important. See
%     s_wvfDiffraction.m
%  * [NOTE: DHB - There is an interpolation in the loop that computes the
%     otf wavelength by wavelength.  This appears to be there to handle the
%     possibility that the frequency support in the wvf structure could be
%     different for different wavelengths. Does that ever happen?  If we
%     check and it doesn't, I think we could save a little time by getting
%     rid of the interpolation.]
%  * [NOTE: DHB - NCP and I spent a lot of time last summer suffering
%     through the psf <-> otf calculations as part of the IBIOColorDetect
%     project, and the fftshift conventions.]
%  * [NOTE: DHB - There is a note that PSF might start real but that the
%     PSF implied by the OTF computed here might not be.  We should check
%     into that.  We don't want imaginary PSFs showing up in calculations.
%     Perhaps this is handled by the oi methods, in that perhaps they
%     enforce that the psf obtained from the otf is in fact real.]
%  * [NOTE: DHB - It might be worth checking that it is OK just to set the
%     wavelength on the OTF, even if the oi itself has different wavelength
%     sampling.]
%
% See Also:
%    oiCreate, opticsCreate, oiPlot
%

% History:
%	 xx/xx/12       Copyright Wavefront Toolbox Team 2012
%    11/13/17  jnm  Comments & formatting
%    01/01/18  dhb  Set name and oi wavelength from wvf.
%              dhb  Check for need to interpolate, skip if not.
%    01/11/18  jnm  Formatting update to match Wiki
%    04/14/21  dhb  Set fNumber to correspond to wvf calc pupil size.
%                   Previously this was the oi default of 3 mm pupil.

% Examples:
%{
    wvf = wvfCreate;
    wvf = wvfCompute(wvf);
    oi = wvf2oi(wvf);
    oiPlot(oi, 'psf550');
%}
%{
    wvf = wvfCreate('wave', [400 550 700]');
    wvf = wvfSet(wvf, 'zcoeff', 1, 'defocus');
	wvf = wvfCompute(wvf);
    oi = wvf2oi(wvf);
    oiPlot(oi, 'psf550');
%}
%{
    wvf = wvfCreate;
    wvf = wvfCompute(wvf);
    oi = wvf2oi(wvf,'human lens',true);
    scene = sceneCreate;
    oi = oiCompute(oi,scene);
    oiWindow(oi);
%}

%% Set up parameters
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('wvf',@isstruct);
p.addParameter('humanlens',false,@islogical);
p.parse(wvf,varargin{:});

%% Set the frequency support and OTF data into the optics slot of the OI
oi = oiCreate('empty');
oi = oiSet(oi, 'wave', wvfGet(wvf, 'calc wave'));

% Convert the wvf parameters into ISETCam optics struct. The most important
% is the OTF, but we also manage other fields.  
optics = wvf2optics(wvf);

% Add in the wvf to the optics.  This is where the PSF compute function
% will look for it.  We don't think that oiSet(oi,'wvf') should be
% allowable, or at least if it is, then it should also put it into the
% optics.  Also, it is possible that this should be done by wvf2optics,
% rather than here.
optics = opticsSet(optics,'wvf',wvf);

% Put optics into oi and propagate the name.
oi = oiSet(oi,'optics',optics);
oi = oiSet(oi, 'name', wvfGet(wvf, 'name'));

% Convert the ISETCam lens transmittance to the default human lens
if p.Results.humanlens
    if checkfields(oi.optics, 'transmittance')
        oi.optics = rmfield(oi.optics, 'transmittance');
    end
    oi = oiSet(oi, 'optics lens', Lens('wave', oiGet(oi, 'optics wave')));
end

end
