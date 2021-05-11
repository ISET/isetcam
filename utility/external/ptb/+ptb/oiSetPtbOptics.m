function oi = oiSetPtbOptics(oi, varargin)
% Put line spread function or point spread function from PTB into an oi.
%
% Syntax:
%    oi = oiSetPtbOptics(oi)
%
% Description
%    Psychtoolbox has code to generate a number of standard line spread and
%    point spread functions.  This routine takes one of those methods and
%    does the apprpriate massaging to insert it into the optics structure
%    of a passed isetbio oi object.
%
%    There is nothing terribly deep here, but this routine takes care of
%    all the fussing.
%
%    This lives in the +ptb package, prepend ptb. when callling.
%
%    The PSF cases of GeislerLsfAsPsf and DavilaGeislerLsfAsPsf are to see
%    if we better reproduce some of the Geisler and colleagues results on
%    the assumption that this is what they did. It is not meant as a good
%    estimate of the human psf, although the difference between doing this
%    and the right conversion from lsf to psf is fairly subtle.
%
% Inputs:
%    oi - Optical image object to update.
%
% Outputs:
%    oi - Updated optical image object.
%
% Optional key/value pairs:
%
%   'opticsModel' -     Line spread type (default, DavilaGeisler)
%                         'Geisler'         - See PTB's GeislerLSFMinutes
%                         'GeislerLsfAsPsf' - Take Geisler lsf and treat it
%                                             directly as psf
%                         'DavilaGeisler'   - See PTB's DavilaGeislerLSFMinutes
%                         'DavilaGeislerLsfAsPsf' - Take D/G lsf and treat
%                                             it directly as a psf
%                         'Westheimer'    - See PTB's WestheimerLSFMinutes
%                         'Williams'      - See PTB's WilliamsMTF
%
%    'uMPerDegree' -    Scalar, conversion factor between degrees of visual
%                       angle and um on the retina (default 300). You want
%                       this value to match the conversions specified in
%                       the passed oi struct.
%
% See also:
%

% History:
%   12/05/17    dhb   Cleaning up comments a little.
%                     Add uMPerDegree key/value pair.
%

%% Parse input
p = inputParser;
p.addRequired('oi', @isstruct);
p.addParameter('opticsModel', 'DavilaGeisler', @ischar);
p.addParameter('uMPerDegree', 300, @isscalar);
p.parse(oi, varargin{:});

%% Pull out optics structure and get wls
optics = oiGet(oi, 'optics');
wls = opticsGet(optics, 'wave');

%% Check that support is square
%
% Almost surely true, and haven't thought through all the implications if
% it is not.
sfValuesCyclesMm = opticsGet(optics, 'otf support', 'mm');
if (length(sfValuesCyclesMm{1}) ~= length(sfValuesCyclesMm{2}))
    error('Our code assumes that sf support for otf is square, but it isn''t here.')
    end

    %% Get the gridded spatial frequency support of the otf in cycles/deg.
    %
    % We'll also keep it around in cycles/mm.
    %
    % And convert to support in cycles per degree.
    uMPerMm = 1000;
    uMPerDeg = p.Results.uMPerDegree;
    [xSfGridCyclesMm, ySfGridCyclesMm] = meshgrid(sfValuesCyclesMm{1}, sfValuesCyclesMm{2});
    xSfGridCyclesDeg = uMPerDeg * xSfGridCyclesMm / uMPerMm;
    ySfGridCyclesDeg = uMPerDeg * ySfGridCyclesMm / uMPerMm;

    %% Get isetbio format OTF at one wavelength
    otf = opticsGet(optics, 'otf data', wls(1));

    %% Get the psf spatial support from the spatial frequency support
    centerPosition = floor(length(sfValuesCyclesMm{1})/2) + 1;
    [xGridMinutes, yGridMinutes] = SfGridCyclesDegToPositionGridMinutes(xSfGridCyclesDeg, ySfGridCyclesDeg);
    position1DMinutes = xGridMinutes(centerPosition, :);

    %% Get PTB optics as PSF
    switch (p.Results.opticsModel)
        case 'DeltaFunction'
            thePsf = zeros(size(xGridMinutes));
            thePsf(centerPosition, centerPosition) = 1;
        case 'Geisler'
            theLsf = GeislerLSFMinutes(position1DMinutes);
            thePsf = LsfToPsf(theLsf);
        case 'GeislerLsfAsPsf'
            thePsf = GeislerLSFMinutes(sqrt(xGridMinutes.^2 + yGridMinutes.^2));
        case 'DavilaGeisler'
            theLsf = DavilaGeislerLSFMinutes(position1DMinutes);
            thePsf = LsfToPsf(theLsf);
        case 'DavilaGeislerLsfAsPsf'
            thePsf = DavilaGeislerLSFMinutes(sqrt(xGridMinutes.^2 + yGridMinutes.^2));
        case 'Westheimer'
            theLsf = WestLSFMinutes(position1DMinutes);
            thePsf = LsfToPsf(theLsf);
        case 'Williams'
            theMtf = WilliamsMTF(sqrt(xSfGridCyclesDeg.^2 + ySfGridCyclesDeg.^2));
            [a, b, thePsf] = OtfToPsf(xSfGridCyclesDeg, ySfGridCyclesDeg, theMtf);
            if (any(a ~= xGridMinutes | b ~= yGridMinutes))
                error('Internal coordinate system transformation error');
            end
        otherwise
            error('Unknown opticsModel specified');
    end

    %% Make sure psf has unit volume
    %
    % Not all the routines above guarantee this.
    thePsf = thePsf / sum(thePsf(:));

    %% Stick psf into the optics structure
    %
    % The ifftshift puts things into the isetbio format.  These are wavelength
    % indendent optical estimates.  Not realistic.  We're doing this to compare
    % with calculations in the literature that also didn't take chromatic
    % aberration into account.
    [~, ~, theOtfCentered] = PsfToOtf(xGridMinutes, yGridMinutes, thePsf);
    theOtfIsetbio = ifftshift(theOtfCentered);
    insertOtf = zeros(size(opticsGet(optics, 'otf data')));
    for ii = 1:length(wls)
        insertOtf(:, :, ii) = theOtfIsetbio;
    end
    optics = opticsSet(optics, 'otf data', insertOtf);

    %% Stick optics into oi
    oi = oiSet(oi, 'optics', optics);
