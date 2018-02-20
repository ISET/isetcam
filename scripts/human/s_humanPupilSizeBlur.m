%% s_PupilSizeBlur
%
% Calculate the effect of pupil size on blur in the human retina model
% developed by Hopkins and implemented in humanCore.
%
% The human OTF that we calculate is based on two elements. The first is
% the Hopkins model of the human eye. This is an idealized eye that
% accounts for chromatic aberration, but it does not have all of the
% features needed to capture the imperfections of the constructed human
% eye.
%
% Hence, we added a second factor that degrades image quality. This comes
% from empirical measurements made in Dave Williams' lab. This reduces the
% contrast passed uniformly across all wavelengths uniformly.
%
% But the degradation that we use is not pupil size dependent.  This is a
% significant limitation in the accuracy of the model.  In fact, for an
% idealized eye as the pupil size grows, the linespread will sharpen
% because there is less diffraction to contend with.  In the real eye,
% however, the data go in the other direction.  As the pupil size grows the
% eye's aberrations play a larger role and there is degradation of the
% linespread.  
%
% Hence, the model we use here and in humanCore isn't handling pupil radius
% correctly (demonstrated in the calculations). The data are not bad around
% 3mm diameter, but they are too good at 6mm diameter.
%
% One way to fix this problem is to have the degradation factor we use from
% the Williams' data depend on the pupil diameter.  We should do this by
% examining  published linespreads and adjusting the variable in humanCore
% called 'williamsFactor' to be pupil size dependent. (Wandell, May, 2010).
%
% See also: humanOTF, humanLSF, humanCore
%
% Copyright ImagEval Consultants, LLC, 2010.

%% Create linespread functions for a very large and a slightly small pupil
p1 = 0.003;    % 6 mm diameter
p2 = 0.001;    % 2 mm diameter
unit = 'um';
wStep = 5; wave = 400:wStep:700;
dioptricPower   = 59.9404;

% Set up LSF arguments
lsfBigPupil     = humanLSF(p1,dioptricPower,unit,wave);
[lsfSmallPupil,xDim,wave] = humanLSF(p2,dioptricPower,unit,wave);

% You can re-run this for various wavelengths by re-selecting w.  The
% wavelength range is from 400:700 in 1 nm increments
for thisWave = [450,550]
    fig = vcNewGraphWin;
    idx = (thisWave - wave(1))/wStep + 1;
    plot(xDim,lsfSmallPupil(idx,:),'r--',xDim,lsfBigPupil(idx,:),'b-');

    xlabel('Spatial position (um)');
    ylabel('Relative intensity');

    legend(sprintf('Diam = %.1f mm',2*p1*10^3),sprintf('Diam = %.1f mm',2*p2*10^3));
    title(sprintf('Line spread %.0f nm',wave(idx)));
    grid on

end

% Note that the LSF of the larger pupil size is sharper than the smaller
% size.  This is not right.  See comments at the top for how we should
% adjust this.