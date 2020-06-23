function psfMovie(optics,figNum,delay)
%Show a movie of the pointspread functions 
%
%   psfMovie([optics],[figNum=1],[delay = 0.2])
%
% The movies differ slightly for the shift-invariant and ray trace
% methods. The shift-invariant doesn't depend on field height; the ray
% trace does.  So we show the full set differently.
%
% For the shift invariant we just show a movie over wavelength
%
% For the ray trace
% The image height increase along the x-axis.  The data are displayed for
% one wavelength first, and then the next wavelength. The horizontal axis
% indicates the image height in microns.
%
% Example:
%   oi = vcGetObject('oi'); optics = oiGet(oi,'optics');
%   psfMovie(optics,1)
%
% This example loads, visualizes, rotates, and visualizes again.
%   psfMovie;
%
%   vcImportObject('OPTICS');
%   psfMovie([],1);
%   optics = vcGetObject('optics');
%   optics = rtPSFEdit(optics,0,1,2);
%
% Copyright ImagEval, LLC, 2005

if ieNotDefined('optics'), optics = oiGet(vcGetObject('oi'), 'optics'); end
if ieNotDefined('figNum'), figNum = ieNewGraphWin; end
if ieNotDefined('delay'), delay = 0.2; end

figure(figNum)
set(figNum,'name','PSF Movie');

opticsModel = opticsGet(optics,'model');
switch lower(opticsModel)
    case 'diffractionlimited'
        disp('Not yet implemented for diffraction limited')
    case 'shiftinvariant'
        psf  = opticsGet(optics,'psfData');
        support = opticsGet(optics,'psfSupport','um');
        y = support{1}(:); x = support{2}(:);
        wave = opticsGet(optics,'wavelength');
        w = size(psf,3);

        for ii=1:w
            imagesc(y,x,psf(:,:,ii));
            xlabel('Position (um)');
            ylabel('Position (um)');
            grid on; axis image
            title(sprintf('Wave %.0f nm',wave(ii)));
            pause(delay);
        end
    case 'raytrace'
        name = opticsGet(optics,'rtname');
        set(figNum,'name',sprintf('%s: PSF movie',name));
        colormap(gray(256));

        wave   = opticsGet(optics,'rt psf wavelength');
        imgHgt = opticsGet(optics,'rt psf field height','um');
        psf    = opticsGet(optics,'rt psf data');
        c = opticsGet(optics,'rt psf support col','um');
        r = opticsGet(optics,'rt psf support col','um');

        % Should we plot them on a single image and move them, or centered
        % like this?
        gColor = [.5 .5 0];
        for jj=1:length(wave)
            for ii=1:length(imgHgt)
                imagesc(r + imgHgt(ii),c + imgHgt(ii),squeeze(psf(:,:,ii,jj)));
                set(gca,'yticklabel',[]); xlabel('Position (um)');
                set(gca,'xcolor',gColor,'ycolor',gColor);
                grid on; axis image
                title(sprintf('Wave %.0f nm\nField height %.2f um',wave(jj),imgHgt(ii)));
                pause(delay);
            end
        end
    otherwise
        error('Unknown model %s\n',opticsModel);
end


return;