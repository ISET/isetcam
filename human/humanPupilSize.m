function [diam,area] = humanPupilSize(lum,model)
% Estimated pupil diameter and area (mm^2)
%
%  [diam,area] = pupilSize(lum,'model')
%
% The mean luminance is in candelas/m2.  The returned diameter and pupil
% area are in mm and mm^2, respectively.
%
% Two models implemented.
%    'ms'  - Moon and Spencer (1944)
%    'dg'  - DeGroot and Gebhard (1952)
%
% Related note:
%   According to James E. Birren, Roland C. Casperon, & Jack Botwinick,
%   Age Changes in Pupil Size, J. Gerontol., #5, 1950, p.216, the following
%   formula can be used to predict minimum diameter as a function of age.
%        Age = 10:80;
%        diam = 9.08 - (0.082 * Age) + (0.00037 * Age.^2);
%        vcNewGraphWin;
%        plot(Age,diam); xlabel('Age (yrs)'); ylabel('Min diameter (mm)');
%        grid on
%
%   According to Stanley and Davies (The effect of field of view size on
%   steady-state pupil diameter.) the pupil size should be explained in
%   cd/m2 per deg  of visual angle.  They offer another formula
%
%      D = 7.75-5.75 [(F/846)0.41/((F/846)0.41 / 2)]
%
%   where D is the pupil diameter (mm) and F is the corneal flux density
%   (cdm-2 deg2). Not implemented here, but perhaps it should be.
%
% Example:
%    [d,a] = humanPupilSize(100,'ms')
%
%    lumSteps = logspace(-6,6,20);
%    [d1,a] = humanPupilSize(lumSteps,'ms');
%    [d2,a] = humanPupilSize(lumSteps,'dg');
%    semilogx(lumSteps,d1,'r-',lumSteps,d2,'g--')
%
%    age = 30:5:70;
%    diam = 9.08 - (0.082 * age) + (0.00037 * age.^2);
%    plot(age,diam)
%

if ieNotDefined('lum'), lum = 100; end % Candelas/m2
if ieNotDefined('model'), model = 'dg'; end

switch lower(model)
    case 'ms'
        diam = 4.9 - 3*tanh(0.4*log10(lum) + 1);
    case 'dg'
        diam = 10.^(0.8558 - 0.000401*(log10(lum) + 8.6).^3);
    case 'agemin'
    otherwise
        error('Unknown model')
end

if nargout == 2, area = pi*(diam/2).^2; end

return;
