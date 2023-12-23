function [diam, area] = humanPupilSize(lum, model, varargin)
% Estimated pupil diameter and area (mm^2)
%
% Syntax:
%   [diam, area] = pupilSize([lum], [model], [varargin])
%
% Description:
%    The mean luminance is in candelas/m2. The returned diameter and pupil
%    area are in mm and mm^2, respectively.
%
%    Different models implemented:
%       'ms'  - Moon and Spencer (1944)
%       'dg'  - DeGroot and Gebhard (1952)
%       'sd'  - Stanley and Davies (1995)
%       'wy'  - Watson and Yellott (2012)
%
%    For some models, it requires more parameters than just the luminance
%    and the model.
%
%    Related note:
%       According to James E. Birren, Roland C. Casperon, & Jack Botwinick,
%       Age Changes in Pupil Size, J. Gerontol., #5, 1950, p.216, the
%       following formula can be used to predict minimum diameter as a
%       function of age. (See third example below)
%
%    According to Stanley and Davies (The effect of field of view size on
%    steady-state pupil diameter.) the pupil size should be explained in
%    cd/m2 per deg  of visual angle. They offer another formula
%
%        D = 7.75 - 5.75 [(F / 846) 0.41 / ((F / 846) 0.41 / 2)]
%
%    where D is the pupil diameter (mm) and F is the corneal flux density
%    (cdm-2 deg2).
%
%    According to Andrew B. Watson and John I. Yellott (A unified formula
%    for light-adapted pupil size) the pupil size formula should
%    incorporate the combined effects of the observer's age, the size of
%    adapting field, and number of eyes used (mono/bi - nocular). They
%    describe the formula as:
%
%        D = D_sd(F, 1) + (y - y0) * (0.02132 - 0.009562 * D_sd(F, 1));
%
%    Where D is the pupil size, y is the age, y0 is the reference age, and
%    F = LaM(e), a is the field area in deg^2, L is the luminance in cd/m^2
%
%    This function contains examples of usage inline. To access, type 'edit
%    humanPupilSize.m' into the Command Window.
%
% Inputs:
%    lum    - (Optional) Numeric. The luminance in cd/m^2 or cd/m^2/deg^2
%             for 'sd' and 'wy' model. Default 100 cd/m^2.
%    model  - (Optional) String. The selected model, see notes for details.
%             Default 'wy'.
%
% Outputs:
%    diam   - Numeric. Pupil diameter
%    area   - Numeric.  Pupil area
%
% Optional key/value pairs:
%    area   - Numeric. Used in 'sd' and 'wy' model. Uses units deg^2.
%             Default for 'wy' model is 4 deg^2.
%    age    - Numeric. The age of the subject in years. Default for 'wy'
%             model is 28.
%    eyeNum - Numeric. The options are binocular (2) or monocular (1). This
%             is used in the 'wy' model. Default for 'wy' model is 1.

% History:
%    xx/xx/14  HJ   (c) Vistalab 2014
%    06/26/18  jnm  Formatting

% Examples:
%{
    [d, a] = humanPupilSize(100, 'ms')
    lumSteps = logspace(-4, 4, 50);
    [d1, a] = humanPupilSize(lumSteps, 'ms');
    [d2, a] = humanPupilSize(lumSteps, 'dg');
    semilogx(lumSteps, d1, 'r-', lumSteps, d2, 'g--')

    age = 30:5:70;
    diam = 9.08 - (0.082 * age) + (0.00037 * age.^2);
    plot(age, diam)
%}
%{
    params.age = 30;
    params.eyeNum = 2;
    params.area = pi * 30 ^ 2;
    lumSteps = logspace(-4, 4, 50);
    
    % Figure 16 (WY)
    d0 = humanPupilSize(lumSteps, 'wy', params);
    vcNewGraphWin;
    semilogx(lumSteps, d0);
    grid on;
    xlabel('Log lum');
    ylabel('Diameter')
%}
%{
    Age = 10:80;
    diam = 9.08 - (0.082 * Age) + (0.00037 * Age .^ 2);
    vcNewGraphWin;
    plot(Age, diam);
    xlabel('Age (yrs)');
    ylabel('Min diameter (mm)');
    grid on
%}

if notDefined('lum'), lum = 100; end        % Candelas/m2
if notDefined('model'), model = 'wy'; end   % Watson and Yellott

switch lower(model)
    case 'ms'
        diam = 4.9 - 3 * tanh(0.4 * log10(lum) + 1);
    case 'dg'
        diam = 10 .^ (0.8558 - 0.000401 * (log10(lum) + 8.6) .^ 3);
    case 'sd'
        if isempty(varargin), error('Area in deg^2 required');
        else, area = varargin{1};
        end
        F = lum * area;
        diam = 7.75 - 5.75 * (F / 846) .^ 0.41 ./ ((F / 846) .^ 0.41 + 2);
    case 'wy'
        if isempty(varargin), error('Parameters required');
        else, params = varargin{1};
        end

        age = 28;
        eyeNum = 1;
        area = 4;
        if isfield(params, 'age'), age = params.age; end
        if isfield(params, 'area'), area = params.area; end
        if isfield(params, 'eyeNum'), eyeNum = params.eyeNum; end

        if eyeNum == 1, me = 0.1; elseif eyeNum == 2, me = 1; end

        F = lum * area * me;
        Dsd = humanPupilSize(F, 'sd', 1);
        diam = Dsd + (age - 28.58) * (0.02132 - 0.009562 * Dsd);

    otherwise
        error('Unknown model')
end

if nargout == 2, area = pi * (diam / 2) .^ 2; end

end
