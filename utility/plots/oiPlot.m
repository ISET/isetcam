function [udata, g] = oiPlot(oi,pType,roiLocs,varargin)
% Gateway routine for plotting optical image (oi) properties
%
%   [udata, g] = oiPlot([oi],[pType='illuminance hline'],[ROI],[wave])
%
% TODO:  Make a 'no figure' option work.  It is stuck in below, but not as
% effective as the 'window', false in wvfPlot.
%
% Gateway routine to plot the irradiance or illuminance data in the optical
% image. There are many options.
%
% The data shown in the plot are generally returned in udata.  The data can
% also be retrieved from the figure, using get(figHandle,'userdata');
%
% Inputs are the optical image (oi), the plot type (pType), in some cases a
% position or ROI locations is required (xy) and in some cases other
% arguments can be included to make plotting from scripts possible without
% user intervention (e.g., grid spacing in irradiance image with grid).
%
% This is a list of the plot types
%
%    Irradiance
%     {'irradiance photons roi'} - Irradiance within an ROI of the image
%     {'irradiance energy roi'}  - Irradiance within an ROI of the image
%     {'irradiance hline'}  - Horizontal line spectral irradiance (photons)
%                            (space x wavelength)
%     {'irradiance vline'}  - Vertical line spectral irradiance (photons)
%                            (space x wavelength)
%     {'irradiance fft'}    - 2D FFT of radiance at some wavelength
%     {'irradiance image with grid'} - Show spatial grid on irradiance image
%     {'irradiance image wave grid'} - Irradiance image within a band
%
%    Illuminance
%     {'illuminance mesh log'}      - Me'psfsh plot of image log illuminance
%     {'illuminance mesh linear'}   - Mesh plot of image illuminance
%     {'illuminance fft'}       - 2D FFT of illuminance
%     {'illuminance hline'}     - Horizontal line illuminance
%     {'illuminance fft hline'} - Horizontal line illuminance fft
%     {'illuminance vline'}     - Vertical line luminance
%     {'illuminance fft vline'} - Vertical line luminance FFT
%     {'illuminance roi'}       - Histogram of illuminance in an ROI
%
%    CIE
%      {'chromaticity roi'}     - CIE xy in a region of interest
%
%    Contrast
%     {'contrast hline'}       - Horizontal line contrast at a wavelength
%     {'contrast vline'}       - Vertical line contrast
%
%    Depth
%     {'depth map'}            - If it has a depth map, plot it as a mesh
%     {'depth map contour'}    - If it has a depth map, plot it as a mesh
%
%    Optics related:
%      {'otf'}            - Optical transfer function, units are lines/mm
%      {'otf 550'}        - OTF at 550 nm
%      {'otf wavelength'} - One dimensional cut through the OTF at all
%                           wavelengths. Units are cycles/mm
%      {'psf'}            - Point spread function at selected wavelength
%      {'psf 550'}        - PSF at 550nm spatial units are microns
%      {'ls wavelength'}  - Line spread function at all wavelengths.
%         Peak spatial frequency can be set for the OTF (default:
%         3*incoherent cutoff). Number of spatial samples to plot in the
%         line spread can be set (default: 40).
%
%      {'relative illumination'} - Calls opticsPlotOffAxis
%      {'lens transmittance'}    - Calls opticsPlotTransmittance
%
% The source code contains examples
%
% See also:  plotOITest, scenePlot, sensorPlot
%
% Copyright ImagEval Consultants, LLC, 2005.

% Examples:
%{
scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);

rows = round(oiGet(oi,'rows')/2);

uData = oiPlot(oi,' irradiance hline',[1,rows])
uData = oiPlot(oi,'illuminance fft hline',[1,rows])

uData = oiPlot(oi,'contrast hline',[1,rows])

% Commented out because it asks the user for a value
% uData = oiPlot(oi,'irradiance image with grid')

uData = oiPlot(oi,'irradiance image with grid',[],40)
uData = oiPlot(oi,'irradiance image wave',[],500,40);

% Commented out because it crashes.
% uData = oiPlot(oi,'irradiance energy roi');

uData = oiPlot(oi,'psf 550','um')
uData = oiPlot(oi,'otf 550','um')
uData = oiPlot(oi,'ls wavelength')

uData = oiPlot(oi,'relative illumination');

oiPlot(oi,'psf',[],550,'airydisk',true);
%}


%% Programming note
%  This function includes within it the previous functions plotOTF and
%  plotOIIrradiance. Those have been deprecated.

if ieNotDefined('oi'), oi = vcGetObject('OI'); end
if ieNotDefined('pType'), pType = 'hlineilluminance'; end

% In some cases we want to select the app window.  The user can indicate
% which oiWindow by appending the app as the last argument to this call.
% With this method, we have the window available when we need it, below.
thisW = [];
if ~isempty(varargin)
    % See if the user sent in thisW
    if isequal(class(varargin{end}),'oiWindow_App')
        thisW = varargin{:};
        
        % Remove the app from the array.  Backwards compatibility.
        varargin = varargin(1:(end-1));
    end
end

% Reformat the parameter - no spaces, all lower case
pType = ieParamFormat(pType);

if ieNotDefined('roiLocs')
    
    if ~isempty(thisW)
        % Focus on the oiWindow for clicking.
        figure(thisW.figure1);
    end
    
    switch pType
        case {'irradiancehline','hline','hlineirradiance' , ...
                'irradianceenergyhline','energyhline','hlineirradianceenergy' , ...
                'illuminancehline','horizontallineilluminance','hlineilluminance', ...
                'illuminanceffthline',...
                'contrasthline','hlinecontrast', ...
                }
            roiLocs = iePointSelect(oi);
            
            % Draw a line on the oiWindow.  I may be off by 1.
            sz = oiGet(oi,'size');
            ieROIDraw(oi,'shape','line','shape data',[1 sz(2) roiLocs(2) roiLocs(2)]);
            
        case {'irradiancevline','vline','vlineirradiance',...
                'illuminancevline','vlineilluminance', ...
                'contrastvline','vlinecontrast','illuminancefftvline'}
            % We need to add the 'energy' case here.
            roiLocs = iePointSelect(oi);
            
            % Draw a line on the oiWindow.  I may be off by 1.
            sz = oiGet(oi,'size');
            ieROIDraw(oi,'shape','line','shape data',[roiLocs(1) roiLocs(1) 1 sz(1)]);
            
        case {'irradianceenergyroi','irradiancephotonsroi', ...
                'chromaticityroi','illuminanceroi'}
            roiLocs = ieROISelect(oi);
            
        otherwise
            % There are many cases that don't need a position
    end
end

%% Make the plot window and use this default gray scale map

g = ieNewGraphWin; g.Visible = 'off';
mp = 0.4*gray(64) + 0.4*ones(size(gray(64)));
colormap(mp);

switch pType
    
    % Irradiance related
    case {'irradiancephotonsroi'}
        %[uData, g] = oiPlot(oi,'irradiance photons roi',roiLocs);
        %
        udata = plotOIIrradiance(oi,'photons',roiLocs);
    case {'irradianceenergyroi'}
        %[uData, g] = oiPlot(oi,'irradiance energy roi',roiLocs);
        %
        udata = plotOIIrradiance(oi,'energy',roiLocs);
        
    case {'irradiancehline','hline','hlineirradiance'}
        % oiPlot('irradiance hline')
        data = oiGet(oi,'photons');
        if isempty(data), warndlg(sprintf('Photon data are unavailable.')); return; end
        
        wave = oiGet(oi,'wave');
        data = squeeze(data(roiLocs(2),:,:));
        if isa(data,'single'), data = double(data); end
        
        posMicrons = oiSpatialSupport(oi,'um');
        
        if size(data,1) == 1
            % Manage monochrome data
            plot(posMicrons.x,data');
            xlabel('Position (mm)');
            ylabel('Irradiance (q/s/nm/m^2)');
            title('Monochrome image')
            grid on; set(gca,'xtick',ieChooseTickMarks(posMicrons.x))
        else
            mesh(posMicrons.x,wave,double(double(data')));
            xlabel('Position (um)');
            ylabel('Wavelength (nm)'); zlabel('Irradiance (q/s/nm/m^2)');
            grid on; set(gca,'xtick',ieChooseTickMarks(posMicrons.x))
        end
        
        udata.roiLocs = roiLocs;
        udata.wave = wave; 
        udata.pos = posMicrons.x; udata.data = double(data');
        udata.cmd = 'mesh(pos,wave,data)';
        set(g,'Name',sprintf('ISET GraphWin: line %.0f',roiLocs(2)));
        colormap(jet(64));
        
    case {'irradianceenergyhline','hlineenergy','hlineirradianceenergy'}
        % oiPlot('irradiance hline')
        data = oiGet(oi,'energy');
        if isempty(data), warndlg(sprintf('Energy data are unavailable.')); return; end
        
        wave = oiGet(oi,'wave');
        data = squeeze(data(roiLocs(2),:,:));
        if isa(data,'single'), data = double(data); end
        
        posMicrons = oiSpatialSupport(oi,'um');
        
        if size(data,1) == 1
            % Manage monochrome data
            plot(posMicrons.x,data');
            xlabel('Position (mm)');
            ylabel('Irradiance (watts/nm/m^2)');
            title('Monochrome image')
            grid on; set(gca,'xtick',ieChooseTickMarks(posMicrons.x))
        else
            mesh(posMicrons.x,wave,double(double(data')));
            xlabel('Position (um)');
            ylabel('Wavelength (nm)'); zlabel('Irradiance (watts/nm/m^2)');
            grid on; set(gca,'xtick',ieChooseTickMarks(posMicrons.x))
        end
        
        udata.wave = wave; 
        udata.roiLocs = roiLocs;
        udata.pos = posMicrons.x; udata.data = double(data');
        udata.cmd = 'mesh(pos,wave,data)';
        set(g,'Name',sprintf('ISET GraphWin: line %.0f',roiLocs(2)));
        colormap(jet(64));

    case {'irradiancevline','vline','vlineirradiance',}
        % oiPlot(oi,'irradiance vline')
        data = oiGet(oi,'photons');
        if isempty(data), warndlg(sprintf('Photon data are unavailable.')); return; end
        
        wave = oiGet(oi,'wave');
        data = squeeze(data(:,roiLocs(1),:));
        if isa(data,'single'), data = double(data); end
        
        posMicrons = oiSpatialSupport(oi,'microns');
        
        if size(data,2) == 1
            plot(posMicrons.y,data);
            xlabel('Position (mm)');
            ylabel('Irradiance (q/s/nm/m^2)');
            title('Monochrome image')
            grid on; set(gca,'xtick',ieChooseTickMarks(posMicrons.y))
        else
            mesh(posMicrons.y,wave,double(data'));
            xlabel('Position (um)');
            ylabel('Wavelength (nm)'); zlabel('Irradiance (q/s/nm/m^2)');
            grid on; set(gca,'xtick',ieChooseTickMarks(posMicrons.y))
        end
        
        % Attach data to the figure
        udata.wave = wave;         
        udata.roiLocs = roiLocs;
        udata.pos = posMicrons.y; udata.data = double(data');
        set(g,'Name',sprintf('Line %.0f',roiLocs(1)));
        colormap(jet(64));
        
    case {'irradiancefft'}
        % plot(oi,'irradiance fft',roiLocs,wave)
        % This is the fft of the region at the selected wavelength.
        %
        % Default: roiLocs - whole image, roiLocs not tested adequately.
        %          wave    - middle wavelength
        %
        % The mean is not included in the graph to help with the dynamic
        % range.
        % Axis range could be better.
        
        if isempty(varargin)
            wave = oiGet(oi,'wave');
            selectedWave = wave(round(length(wave)/2));
        else
            selectedWave = varargin{1};
        end
        
        
        data = oiGet(oi,'photons',selectedWave);
        if isempty(data), warndlg(sprintf('Photon data are unavailable.')); return; end
        
        if isa(data,'single'), data = double(data); end
        sz = size(data);
        
        % Remove the mean
        data = data - mean(data(:));
        
        % Plot and attach data to figure
        udata.x = 1:sz(2); udata.y = 1:sz(1); udata.z = fftshift(abs(fft2(data)));
        udata.cmd = 'mesh(x,y,z)';
        mesh(udata.x,udata.y,udata.z);
        xlabel('Cycles/ROI-image'); ylabel('Cycles/ROI-image'); zlabel('Amplitude');
        str = sprintf('Amplitude spectrum at %.0f nm', selectedWave);
        title(str);
        set(g,'Name',sprintf('Irradiance with grid'));
        colormap(jet(64))
        
    case {'irradianceimagewave','irradianceimagewavegrid'}
        % oiPlot(oi,'irradianceImageWave',wave,gSpacing);
        if isempty(varargin), wave = 500;
        else, wave = varargin{1};
        end
        
        irrad   = oiGet(oi,'photons',wave);
        sz      = oiGet(oi,'size');
        spacing = oiGet(oi,'sampleSpacing','um');
        
        % This is probably now a spatial support oiGet ...
        xCoords = spacing(2) * (1:sz(2)); xCoords = xCoords - mean(xCoords);
        yCoords = spacing(1) * (1:sz(1)); yCoords = yCoords - mean(yCoords);
        suggestedSpacing = round(max(xCoords(:))/5);
        if length(varargin) == 2, gSpacing = varargin{2};
        else
            gSpacing = ieReadNumber('Enter grid spacing (um)',suggestedSpacing,'%.2f');
            if isempty(gSpacing), return; end
        end
        
        imagesc(xCoords,yCoords,irrad); colormap(gray(64))
        xlabel('Position (um)'); ylabel('Position (um)');
        
        udata.irrad = irrad;
        udata.xCoords = xCoords;
        udata.yCoords = yCoords;
        
        xGrid = (0:gSpacing:round(max(xCoords))); tmp = -1*fliplr(xGrid); xGrid = [tmp(1:(end-1)), xGrid];
        yGrid = (0:gSpacing:round(max(yCoords))); tmp = -1*fliplr(yGrid); yGrid = [tmp(1:(end-1)), yGrid];
        
        set(gca,'xcolor',[.5 .5 .5]); set(gca,'ycolor',[.5 .5 .5]);
        set(gca,'xtick',xGrid,'ytick',yGrid); grid on
        set(g,'Name',sprintf('Image with grid'));
        
    case {'irradianceimagegrid','irradianceimagewithgrid','irradianceimage'}
        % oiPlot(oi,'irradianceImage',sampleSpacing-um);
        irrad   = oiGet(oi,'photons');
        wave    = oiGet(oi,'wave');
        nWave   = oiGet(oi,'nwave');
        sz      = oiGet(oi,'size');
        spacing = oiGet(oi,'sampleSpacing','um');
        gam     = oiGet(oi,'gamma');
        
        % This is probably now a spatial support oiGet ...
        xCoords = spacing(2) * (1:sz(2)); xCoords = xCoords - mean(xCoords);
        yCoords = spacing(1) * (1:sz(1)); yCoords = yCoords - mean(yCoords);
        if length(varargin) >= 1, gSpacing = varargin{1};
        else
            suggestedSpacing = round(max(xCoords(:))/5);
            gSpacing = ieReadNumber('Enter grid spacing (um)',suggestedSpacing,'%.2f');
            if isempty(gSpacing), return; end
        end
        
        if nWave > 1
            imageSPD(irrad,wave,gam,sz(1),sz(2),1,xCoords,yCoords,g);
        else
            wList = oiGet(oi,'wavelength');
            [row,col] = size(irrad);
            % Pass in the window handle
            imageSPD(irrad,wList,gam,row,col,1,xCoords,yCoords,g);
        end
        xlabel('Position (um)'); ylabel('Position (um)');
        
        udata.irrad = irrad;
        udata.xCoords = xCoords;
        udata.yCoords = yCoords;
        
        xGrid = (0:gSpacing:round(max(xCoords))); tmp = -1*fliplr(xGrid); xGrid = [tmp(1:(end-1)), xGrid];
        yGrid = (0:gSpacing:round(max(yCoords))); tmp = -1*fliplr(yGrid); yGrid = [tmp(1:(end-1)), yGrid];
        
        set(gca,'xcolor',[.5 .5 .5]); set(gca,'ycolor',[.5 .5 .5]);
        set(gca,'xtick',xGrid,'ytick',yGrid); grid on
        set(g,'Name',sprintf('Irradiance with grid'));
        
        % Illuminance and chromaticity
    case {'illuminanceroi'}
        % Histogram of illuminance in an ROI
        udata = plotOICIE(oi,'illuminance',roiLocs);
    case {'chromaticityroi'}
        % Graph of chromaticity coords in an ROI
        udata = plotOICIE(oi,'chromaticity',roiLocs);
        
    case {'illuminancehline','horizontallineilluminance','hlineilluminance'}
        % oiPlot(oi,'illuminance hline')
        data = oiGet(oi,'illuminance');
        if isempty(data), warndlg(sprintf('Illuminance data are unavailable.')); return; end
        illum = data(roiLocs(2),:);
        posMicrons = oiSpatialSupport(oi,'um');
        
        plot(posMicrons.x,illum);
        xlabel('Position (um)'); ylabel('Illuminance (lux)');
        grid on; set(gca,'xtick',ieChooseTickMarks(posMicrons.x))
        
        udata.pos = posMicrons.x; udata.data = illum';
        udata.cmd = 'plot(pos,illum)';
        set(g,'Name',sprintf('Line %.0f (%s)',roiLocs(2),oiGet(oi,'name')));
        
    case {'illuminancemeshlog'}
        % Mesh plot of image log illuminance
        udata = plotIlluminanceMesh(oi,'log');
    case {'illuminancemeshlinear'}
        % Mesh plot of image illuminance
        udata = plotIlluminanceMesh(oi,'linear');
    case {'illuminanceffthline'}
        % oiPlot(oi,'illuminance fft hline')
        % The mean is removed to keep the dynamic range reasonable.
        
        data = oiGet(oi,'illuminance');
        if isempty(data), warndlg(sprintf('Illuminance data are unavailable.')); return; end
        illum = data(roiLocs(2),:); illum = illum - mean(illum(:));
        xPosMM = oiSpatialSupport(oi,'mm');
        
        % Compute amplitude spectrum in units of millimeters
        normalize = 1;
        [freq,fftIllum] = ieSpace2Amp(xPosMM.x,illum,normalize);
        
        plot(freq,fftIllum,'r-');
        xlabel('Cycles/mm'); ylabel('Normalized amplitude'); grid on
        
        udata.freq = freq; udata.data = fftIllum;
        udata.cmd = 'plot(freq,data,''r-'')';
        set(g,'Name',sprintf('Line %.0f',roiLocs(2)));
        
    case {'illuminancevline','vlineilluminance'}
        % oiPlot(oi,'illuminance vline')
        
        data = oiGet(oi,'illuminance');
        if isempty(data), warndlg(sprintf('Illuminance data are unavailable.')); return; end
        illum = data(:,roiLocs(1));
        posMicrons = oiSpatialSupport(oi,'um');
        
        plot(posMicrons.y,illum);
        xlabel('Position (um)'); ylabel('Illuminance (lux)');
        grid on; set(gca,'xtick',ieChooseTickMarks(posMicrons.y))
        
        udata.pos = posMicrons.y; udata.data = illum';
        udata.cmd = 'plot(pos,illum)';
        set(g,'Name',sprintf('Line %.0f (%s)',roiLocs(1),oiGet(oi,'name')));
        
    case {'illuminancefftvline'}
        % oiPlot(oi,'illuminance fft vline')
        
        % space = oiGet(oi,'spatialSupport');
        
        data = oiGet(oi,'illuminance');
        if isempty(data), warndlg(sprintf('Illuminance data are unavailable.')); return; end
        illum = data(:,roiLocs(1));
        yPosMM = oiSpatialSupport(oi,'mm');
        
        % Compute amplitude spectrum in units of millimeters
        normalize = 1;
        [freq,fftIllum] = ieSpace2Amp(yPosMM.y,illum,normalize);
        
        plot(freq,fftIllum,'r-');
        xlabel('Cycles/mm'); ylabel('Normalized amplitude'); grid on
        
        udata.freq = freq; udata.data = fftIllum;
        udata.cmd = 'plot(freq,data,''r-'')';
        set(gcf,'Name',sprintf('Line %.0f',roiLocs(1)));
        
    case {'illuminancefft','fftilluminance'}
        % oiPlot(oi,'illuminance fft')
        % Spatial frequency amplitude at a single wavelength.  Axis range
        % could be better.
        
        % This seems wrong ... it should be a get on illuminance, not
        % photons.
        data = oiGet(oi,'illuminance');
        sz = size(data);
        udata.x = 1:sz(2); udata.y = 1:sz(1); udata.z = fftshift(abs(fft2(data)));
        udata.cmd = 'mesh(x,y,z)';
        mesh(udata.x,udata.y,udata.z);
        xlabel('Cycles/image'); ylabel('Cycles/image'); zlabel('Amplitude');
        title('Illuminance amplitude spectrum');
        
        % Contrast related
    case {'contrasthline','hlinecontrast'}
        % oiPlot(oi,'contrast hline')
        % Plot percent contrast (difference from the mean as a percentage
        % of the mean).
        
        data = oiGet(oi,'photons');
        if isempty(data), warndlg(sprintf('Photon data are unavailable.')); return; end
        data = squeeze(data(roiLocs(2),:,:));
        if isa(data,'single'), data = double(data); end
        
        % Percent contrast
        mn = mean(data(:));
        if mn == 0, warndlg('Zero mean.  Cannot compute contrast.'); return; end
        data = 100*(data - mn)/mn;
        
        posMicrons = oiSpatialSupport(oi,'microns');
        
        wave = oiGet(oi,'wave');
        
        mesh(posMicrons.x,wave,double(data'));
        xlabel('Position (um)'); ylabel('Wavelength (nm)'); zlabel('Percent contrast');
        grid on; set(gca,'xtick',ieChooseTickMarks(posMicrons.x))
        udata.wave = wave; udata.pos = posMicrons.x; udata.data = double(data');
        udata.cmd = 'mesh(pos,wave,data)';
        set(g,'Name',sprintf('Line %.0f',roiLocs(2)));
        colormap(jet(64))
        
    case {'contrastvline','vlinecontrast'} % Done
        % oiPlot(oi,'contrast vline')
        % Plot percent contrast (difference from the mean as a percentage
        % of the mean).
        data = oiGet(oi,'photons');
        if isempty(data)
            warndlg(sprintf('Photon data are unavailable.'));
            return;
        end
        
        wave = oiGet(oi,'wave');
        data = squeeze(data(:,roiLocs(1),:));
        if isa(data,'single'), data = double(data); end
        
        % Percent contrast
        mn = mean(data(:));
        if mn == 0, warndlg('Zero mean.  Cannot compute contrast.'); return; end
        data = 100*(data - mn)/mn;
        
        posMicrons = oiSpatialSupport(oi,'microns');
        
        mesh(posMicrons.y,wave,double(data'));
        xlabel('Position (um)'); ylabel('Wavelength (nm)');zlabel('Irradiance (q/s/nm/m^2)')
        zlabel('Percent contrast')
        grid on; set(gca,'xtick',ieChooseTickMarks(posMicrons.y))
        
        udata.wave = wave; udata.pos = posMicrons.y; udata.data = double(data');
        udata.cmd = 'mesh(pos,wave,data)';
        set(g,'Name',sprintf('Line %.0f',roiLocs(1)));
        
        % Depth related
    case {'depthmap'}
        % oiPlot(oi,'depth map')
        dmap = oiGet(oi,'depth map');
        if isempty(dmap),  close(g); error('No depth map')
        else
            imagesc(dmap); colormap(flipud(gray(64)))
            namestr = sprintf('Depth map (max=%.1f)',max(dmap(:)));
            set(g,'Name',namestr);
            colormap(flipud(gray(64)));
            axis image; cb = colorbar;
            set(get(cb,'label'),'string','Meters','Rotation',90)
        end
        udata.dmap = dmap;
    case {'depthmapcontour','depthcontour'}
        % oiPlot(oi,'depth contour')
        dmap = oiGet(oi,'depth map');
        dmap = ieScale(dmap,0,1); mx = max(dmap(:));
        drgb = cat(3,dmap,dmap,dmap);
        
        image(drgb); colormap(flipud(gray(64))); hold on
        n = 4; v = (1:n)/n; contour(dmap,v);
        hold off
        namestr = sprintf('ISET: Depth map (max = %.1f m)',mx);
        axis off; set(g,'Name',namestr);
        
        % Optics related
    case {'relativeillumination'}
        % Optics relative illumination
        udata = opticsPlotOffAxis(oi,g);
    case{'lenstransmittance'}
        udata = opticsPlotTransmittance(oi,g);
        
    case {'otf','otfanywave'}
        % User asked to select a wavelength
        % Optical transfer function, units are lines/mm
        % oiPlot(oi,'otf',[],420);
        optics = oiGet(oi,'optics');
        opticsModel = opticsGet(optics,'model');
        switch lower(opticsModel)
            case 'raytrace'
                rtPlot(oi,'otf');
            otherwise
                if isempty(varargin), udata = plotOTF(oi,'otf');
                else, w = varargin{1}; udata = plotOTF(oi,'otf', 'this wave', w);
                end
        end
        set(g,'userdata',udata);
        set(g,'name','OTF');
        colormap(jet(64))
        
    case {'otf550'}
        % OTF at 550 nm
        udata = plotOTF(oi,'otf 550');
        set(g,'userdata',udata);
        set(g,'name','OTF 550');
        colormap(jet(64))
        
    case {'psf'}
        % oiPlot(oi,'psf',[],wave);
        % Point spread function at selected wavelength
        %
        if isempty(varargin), udata = plotOTF(oi,'psf', 'airy disk', true);
        else, w = varargin{1}; 
            idx = find(strcmp('airydisk',varargin));
            if ~isempty(idx), airydisk = varargin{idx+1};
            else, airydisk = true;
            end
            udata = plotOTF(oi,'psf', 'this wave', w,'airy disk', airydisk);
            udata.wave = w;
        end
        set(g,'userdata',udata);
        namestr = sprintf('ISET: %s',oiGet(oi,'name'));
        set(g,'Name',namestr);
        colormap(jet(128))
        
    case {'psfxaxis'}
        % oiPlot(oi,'psf xaxis',[],[wave=550],[units='um']);
        %
        % We also put a red dot at the Airy Disk radius, just to
        % confirm.
        thisWave = 550; units = 'um';
        if numel(varargin) > 0, thisWave = varargin{1}; end
        if numel(varargin) > 1, units = varargin{2}; end

        udata = oiGet(oi,'optics psf xaxis',thisWave,units);
        plot(udata.samp,udata.data,'k-','LineWidth',2); grid on; 
        xlabel(sprintf('Pos (%s)',units)); ylabel('Amp (a.u.)');

        fNumber = oiGet(oi,'optics fnumber');
        AD = airyDisk(thisWave,fNumber,'units','um','diameter',false);
        hold on; plot([-AD AD],[0 0],'ro');
        title(sprintf('F# %.2f Wave %d Airy D %.2f',...
            fNumber,thisWave,AD));
        hold off;

    case {'psfyaxis'}
        thisWave = 550; units = 'um';
        if numel(varargin) > 0, thisWave = varargin{1}; end
        if numel(varargin) > 1, units = varargin{2}; end

        udata = oiGet(oi,'optics psf yaxis',thisWave,units);
        plot(udata.samp,udata.data,'k-','LineWidth',2); grid on;
        xlabel(sprintf('Pos (%s)',units)); ylabel('Amp (a.u.)');

        fNumber = oiGet(oi,'optics fnumber');
        AD = airyDisk(thisWave,fNumber,'units','um','diameter',false);
        hold on; plot([-AD AD],[0 0],'ro');
        title(sprintf('F# %.2f Wave %d Airy D %.2f',...
            fNumber,thisWave,AD));
        hold off;

    case {'psf550'}
        % PSF at 550nm spatial units are microns
        udata = plotOTF(oi,'psf', 'this wave', 550, 'airy disk', true);
        set(g,'userdata',udata);
        namestr = sprintf('ISET: %s',oiGet(oi,'name'));
        set(g,'Name',namestr);
        colormap(jet(64))
        
    case {'lswavelength','lsfwavelength'}
        % uData = oiPlot(oi,pType,[],nSpatialSamps)
        % the nSpatialSamps part isn't working.
        %
        % Line spread function at all wavelengths.
        %    Peak spatial frequency can be set for the OTF (default:
        %    3*incoherent cutoff). Number of spatial samples to plot in the
        %    line spread can be set (default: 40).
        optics = oiGet(oi,'optics');
        opticsModel = opticsGet(optics,'model');
        switch lower(opticsModel)
            case 'raytrace'
                ieInWindowMessage('Ray trace: ls wavelength not yet implemented.',handles);
                disp('Not yet implemented')
            otherwise
                if ~isempty(varargin), nSamps = varargin{1};
                else, nSamps = 40;
                end
                udata = plotOTF(oi,'ls wavelength','nsamp', nSamps);
                set(g,'userdata',udata);
        end
        set(g,'name','LS by Wave');
        colormap(jet(64))
        
    case{'otfwavelength','mtfwavelength'}
        % One dimensional otf at all wavelengths as  mesh plot.
        % Units are cycles/mm
        optics = oiGet(oi,'optics');
        opticsModel = opticsGet(optics,'model');
        switch lower(opticsModel)
            case 'raytrace'
                % Not what the user asked for.  Must fix.  Add varargin
                % and make the right plot.  This isn't it.
                rtPlot(oi,'otf');
            otherwise
                udata = plotOTF(oi,'otf wavelength');
                set(g,'userdata',udata);
        end
        set(g,'name','OTF by Wave');
        colormap(jet(64))
        
    case {'illuminantimage'}
        % oiPlot(oi,'illuminant image')
        % Make an RGB image showing the spatial image of the illuminant.
        
        wave = oiGet(oi,'wave');
        sz   = oiGet(oi,'size');
        energy = oiGet(oi,'illuminant energy');
        if isempty(energy)
            ieInWindowMessage('No illuminant data.',handle);
            close(gcf);
            error('No illuminant data');
        end
        
        switch oiGet(oi,'illuminant format')
            case {'spectral'}
                % Makes a uniform SPD image
                energy = repmat(energy(:)',prod(sz),1);
                energy = XW2RGBFormat(energy,sz(1),sz(2));
            otherwise
        end
        
        % Create an RGB image
        udata.srgb = xyz2srgb(ieXYZFromEnergy(energy,wave));
        imagesc(sz(1),sz(2),udata.srgb);
        grid on; axis off; axis image;
        title('Illumination image')
        
    otherwise
        error('Unknown oiPlot type %s.',pType);
end

if exist('udata','var'), set(gcf,'userdata',udata); end

% Suppress showing the window if the final varargin is nofigure
% or nowindow.
if ~isempty(varargin) && isa(varargin{end},'char') && ...
        (isequal(ieParamFormat(varargin{end}),'nofigure') || ...
        isequal(ieParamFormat(varargin{end}),'nowindow'))
    % Maybe?
    delete(g);
    return;
else
    % Make it visible.
    g.Visible = 'On';
end

end

% - Brought into this file from a separate function
function udata = plotOIIrradiance(oi,dataType,roiLocs)
%Plot mean irradiance within a selected ROI of the optical image window
%
%   udata = plotOIIrradiance(oi,dataType,roiLocs)
%
% Plot the average optical image irradiance within a selected ROI. The
% default data type is photons.  If the optical image is not  monochrome,
% the results are plotted in the GRAPHWIN.   Otherwise, the mean irradiance
% within the ROI is displayed in a message box.
%
% The user data and the graphWin figure number are returned
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('dataType'), dataType = 'photons'; end

wave = oiGet(oi,'wave');
irradiance = vcGetROIData(oi,roiLocs,dataType);
irradiance = mean(irradiance);

if length(wave) == 1
    % For a monochrome image, a plot doesn't make any sense.  So, we just
    % put up a box describing the mean irradiance.
    switch dataType
        case 'photons'
            str = sprintf('Irradiance: %.3e (q/s/m^2/nm)  at %.0f nm',irradiance,wave);
        case 'energy'
            str = sprintf('Irradiance: %.3e (Watts/m^2/nm) at %.0f nm',irradiance,wave);
        otherwise
            error('Unknown data type.');
    end
    msgbox(str);
else
    
    % Attach data to the figure itself
    udata.x = wave; udata.y = irradiance;
    udata.roiLocs = roiLocs;
    
    plot(wave,irradiance);
    set(gca,'ylim',[.95*min(irradiance(:)),1.03*max(irradiance(:))]);
    xlabel('Wavelength (nm)');
    grid on;
    
    switch lower(dataType)
        case 'photons'
            ylabel('Irradiance (q/s/m^2/nm)');
        case 'energy'
            ylabel('Irradiance (Watts/m^2/nm)');
        otherwise
            disp('Unknown data type')
    end
end

end

% Moved into oiPlot June, 2012.
function uData = plotOTF(oi,pType,varargin)
%Plot OTF functions associated with the optics in an optical image
%
%   plotOTF(oi,[pType], )
%
%      {'otf'}           - Optical transfer function, units are lines/mm
%      {'otf 550'}       - OTF at 550 nm
%      {'psf'}           - Point spread function at selected wavelength
%      {'psf 550'}       - PSF at 550nm spatial units are microns
%      {'ls wavelength'} -  Line spread function at all wavelengths.
%         Peak spatial frequency can be set for the OTF (default:
%           3*incoherent cutoff)
%         Number of spatial samples to plot in the line spread can be set
%          (default: 40).
%      {'otfwavelength'} -  One dimensional cut through the OTF at a all
%          wavelengths.  Units are cycles/mm
%
% Retquired
%   oi    - optical image struct
%   pType - Plot type
%
% Optional key/val
%   airydisk - Overlay Airy Disk
%   nsamp    - Number of samples around the airy disk circle
%   thiswave - By default 550nm
%   units    - by default 'um'
%
% See also
%

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('oi', @isstruct);
p.addRequired('pType', @ischar);
p.addParameter('airydisk', false, @islogical);
p.addParameter('nsamp', 40, @isnumeric);
p.addParameter('thiswave', 550, @isnumeric);
p.addParameter('units', 'um', @ischar);
p.parse(oi, pType, varargin{:});

airydisk = p.Results.airydisk;
nSamp    = p.Results.nsamp;
thisWave = p.Results.thiswave;
units    = p.Results.units;
%%
wavelength = oiGet(oi,'wavelength');
optics     = oiGet(oi,'optics');

% This catches the case in which the oi has not yet been defined, but the
% optics have.
if isempty(wavelength)
    oi = initDefaultSpectrum(oi,'hyperspectral');
    optics = initDefaultSpectrum(optics,'hyperspectral');
    wavelength = opticsGet(optics,'wavelength');
end

nWave      = oiGet(oi,'nwave');
pType = ieParamFormat(pType);

switch lower(pType)
    case {'otf','otf550'}
        % Good example of why we need to parse the varargin
        % oiPlot(oi,'otf',[], thisWave);
        % plotOTF(oi,'otf',thisWave,nSamp);
        % OTF at a selected wavelength.
        units = 'mm';  % Units are cycles/mm
        
        % Retrieve OTF data (which might be complex) from the optics
        opticsModel = opticsGet(optics,'opticsModel');
        switch lower(opticsModel)
            case {'dlmtf','diffractionlimited'}
                % Compute the otf data
                
                % Specify frequency support and compute the dl MTF
                fSupport = opticsGet(optics,'dl fsupport matrix',thisWave,units,nSamp);
                fSupport = fSupport*4;  % Enlarge the frequency support
                otf = dlMTF(oi,fSupport,thisWave,units);
                
                % DC is at (1,1); we plot with DC in the center.
                otf = fftshift(otf);
                figTitle = sprintf('DL OTF at %.0f',thisWave);
                
            case {'shiftinvariant'}
                % In this case, the otf data must be stored
                otf = opticsGet(optics,'otf data',thisWave);
                if isempty(otf), error('No OTF data'); end
                
                % Units are cycles/mm of optics support
                % We are returned fSupport(:,:,1/2) for X and Y
                fSupport = opticsGet(optics,'otf support matrix');
                
                % Transform so DC is in center
                otf = fftshift(otf);
                figTitle = sprintf('abs(OTF) at %.0f nm',thisWave);
                
            case {'raytrace'}
                error('Ray trace plot: Not yet implemented');
                % figTitle = sprintf('abs(OTF) at %.0f nm',thisWave);
                
            otherwise
                error('Unknown optics model: %s\n',opticsModel);
        end
        
        X = fSupport(:,:,1); Y = fSupport(:,:,2);
        
        % Select the support and plot the mesh
        % I decided to show the whole thing for now.
        %         sz  = selectPlotSupport(otf,0.005);
        %         X   = getMiddleMatrix(X,sz);
        %         Y   = getMiddleMatrix(Y,sz);
        %         otf = getMiddleMatrix(otf,sz);
        if isreal(otf(:)), mesh(X,Y,otf);
        else
            title('ABS(otf)')
            mesh(X,Y,abs(otf));
        end
        
        % Label axes and store data
        xlabel('cyc/mm'), ylabel('cyc/mm'), zlabel('amplitude');
        title(figTitle);
        uData.otf = otf; uData.fx = X(1,:); uData.fy = Y(:,1);
        
    case {'psf','psf550'}
        % oiPlot(oi,'psf',[],thisWave,units)  % empty param is roiLocs
        % oiPlot(oi,'psf 550',[],thisWave,units)
        % Spatial scale default is microns.
        
        opticsModel = opticsGet(optics,'model');
        switch lower(opticsModel)
            case {'diffractionlimited'}
                
                val = opticsGet(oi.optics,'psf data',thisWave,units);
                psf = val.psf;
                sSupport = val.xy;

                % Frequency units are cycles/micron. The spatial
                % frequency support runs from -Nyquist:Nyquist. With
                % this support, the Nyquist frequency is actually the
                % highest (peak) frequency value. There are two
                % samples per Nyquist, so the sample spacing is
                % 1/(2*peakF)
                %
                % peakF = max(fSupport(:));
                % deltaSpace = 1/(2*peakF);
                % Make the spatial support for the PSF
                %                 samp = (-nSamp:(nSamp-1));
                %                 [X,Y] = meshgrid(samp,samp);
                %                 sSupport(:,:,1) = X*deltaSpace;
                %                 sSupport(:,:,2) = Y*deltaSpace;
                
                % Calculate the Airy disk
                fNumber = opticsGet(optics,'fNumber');
                radius = airyDisk(thisWave,fNumber,'units',units);

                % Draw a circle at the first zero crossing (Airy disk)
                nCircleSamples = 200;
                [adX,adY,adZ] = ieShape('circle',nCircleSamples,radius);
                
            case {'shiftinvariant'}
                psfData  = opticsGet(optics,'psf data',thisWave);
                psf      = psfData.psf;
                sSupport = psfData.xy;
                
                % Calculate the Airy disk
                fNumber = opticsGet(optics,'fNumber');

                % This is the Airy disk radius, by formula
                radius = airyDisk(thisWave,fNumber,'units',units);
                % radius = radius * ieUnitScaleFactor(units);
                % radius = (2.44*fNumber*thisWave*10^-9)/2 * ieUnitScaleFactor(units);

                % Draw a circle at the first zero crossing (Airy disk)
                nCircleSamples = 200;
                [adX,adY,adZ] = ieShape('circle',nCircleSamples,radius);

            case {'raytrace'}
                % opticsGet(optics,'rtPSFdata') should be
                % cleaned up for this call.  Spatial support, frequency
                % support, all of that should be in there.
                error('Not yet implemented');
                
            otherwise
                error('Unknown otf function: %s\n',opticsModel);
        end
        
        mesh(sSupport(:,:,1),sSupport(:,:,2),abs(psf));

        if airydisk
            % No longer check if diffraction limited or shift invariant
            %  if strcmpi(opticsModel,'diffractionlimited') ||...
            %     strcmpi(opticsModel, 'shiftinvariant')
            ringZ = max(psf(:))*1e-3;
            hold on; p = plot3(adX,adY,adZ + ringZ,'k-');
            set(p,'linewidth',3); hold off;
            %  end
        end

        % Label, store data
        xlabel('Position (um)'); ylabel('Position (um)');
        zlabel('Irradiance (relative)');
        title(sprintf('Point spread (%.0f nm)',thisWave));
        uData.x = sSupport(:,:,1); uData.y = sSupport(:,:,2);
        uData.psf = psf;
        
    case {'lswavelength'}
        % Line spread function at all wavelengths
        units = 'um';
        wavelength = oiGet(oi,'wavelength');
        nWave      = oiGet(oi,'nwave');
        model      = opticsGet(optics,'model');
        
        % Choose the peak frequency for the OTF.  If none is passed in, we
        % use the incoherent cutoff frequency.
        switch lower(model)
            case 'diffractionlimited'
                inCutoff = opticsGet(optics,'inCutoff',units);
                peakF = 3*max(inCutoff);
            case 'shiftinvariant'
                fx = opticsGet(optics,'otffx','um');
                peakF = max(abs(fx(:)));
            otherwise
                error('LS not implemented for %s model',model);
        end
        
        middleSamps = 40;
        
        % The incoherent cutoff frequency has units of cycles/micron
        % So, 1/inCutoff has units of microns/Nyquist
        % The maximum frequency is at the Nyquist, and there are two
        % samples at the Nqyuist.  So the sample spacing is half the
        deltaSpace = 1/(2*peakF);
        
        % Make the spatial frequency samples used to compute the OTF. These
        % run from [-peakF, +peakF].  We make 100 samples, which is pretty
        % arbitrary.  Not sure how to choose this better. Should be using
        % unitFrequencyList() here.
        nSamp = 100;
        fSamp = (-nSamp:(nSamp-1))/nSamp;
        [fX,fY] = meshgrid(fSamp,fSamp);
        fSupport(:,:,1) = fX*peakF;
        fSupport(:,:,2) = fY*peakF;
        
        opticsModel = opticsGet(optics,'opticsModel');
        switch lower(opticsModel)
            case {'dlmtf','diffractionlimited'}
                otf = dlMTF(oi,fSupport,wavelength,units);
            case {'shiftinvariant'}
                sz=opticsGet(optics,'otf size');
                otf = zeros(sz(1),sz(2),nWave);
                for ii=1:nWave
                    otf(:,:,ii) = opticsGet(optics,'otfdata',wavelength(ii));
                end
            otherwise
                error('LSWavelength1D not implemented for model: %s\n',opticsModel);
        end
        
        % Create the line spread for a horizontal line. We use the first
        % row of the otf to estimate the line spread. This only works if
        % the OTF is circularly symmetric; if it is not, there isn't really
        % a single line spread.
        for ii=1:nWave
            % The central line in the otf is the first line
            tmp = otf(1,:,ii);  % figure; imagesc(abs(otf(:,:,ii)))
            
            % We invert the OTF along that line to get an LSF.  We apply
            % the fftshift because we want the lsf to be centered.
            lsf = fftshift(ifft(tmp));   % figure; plot(abs(lsf))
            
            % Pull out samples from the middle because otherwise the image
            % can be hard to see.
            lsWave(:,ii) = getMiddleMatrix(lsf,middleSamps); %#ok<AGROW>
        end
        %  Apparently we sometimes have a little complex value
        lsWave = abs(lsWave);
        
        % Choose the x coordinates that match the line spread spatial
        % samples.
        X = (-nSamp:(nSamp-1))*deltaSpace;
        X = getMiddleMatrix(X,middleSamps);
        
        % Show it
        if nWave > 1
            mesh(X,wavelength,lsWave');
            xlabel('Position (um)'); ylabel('Wavelength (nm)'); zlabel('Intensity (rel.)');
        else
            plot(X,lsWave(:));
            xlabel('Wavelength (nm)'); ylabel('Intensity (rel.)');
        end
        view(30,20);
        
        % Store the results in the figure.
        uData.x = X; uData.wavelength = wavelength; uData.lsWave = lsWave';
        
    case {'otfwavelength'}
        % Plot a line through the center of the OTF as a function of
        % wavelength
        opticsModel = opticsGet(optics,'opticsModel');
        units = 'um';
        
        % We get the OTF slightly differently for the different models.  If
        % we rewrote opticsGet to check for the optics model, we could do
        % things a little more simply here.  Maybe we should put this code
        % into opticsGet. -- BW
        switch lower(opticsModel)
            case {'dlmtf','diffractionlimited'}
                % Make the spatial frequency samples used to compute the OTF.
                % These run from [-peakF, +peakF].  We make 100 samples,
                % which is pretty arbitrary.  Not sure how to choose this better.
                % Should be using unitFrequencyList() here.
                inCutoff = opticsGet(optics,'inCutoff',units);
                peakF = 3*max(inCutoff);
                
                nSamp = 100;
                fSamp = (-nSamp:(nSamp-1))/nSamp;
                [fX,fY] = meshgrid(fSamp,fSamp);
                fSupport(:,:,1) = fX*peakF;
                fSupport(:,:,2) = fY*peakF;
                % The fftshift centers the OTF data so that DC is in the
                % middle.
                otf = dlMTF(oi,fSupport,wavelength,units);
                
            case {'shiftinvariant'}
                % Data are stored in OTF slot
                fSupport = opticsGet(optics,'otf support matrix');
                otf = zeros(size(fSupport,1),size(fSupport,2),nWave);
                for ii=1:nWave
                    otf(:,:,ii) = abs(opticsGet(optics,'otfdata',wavelength(ii)));
                end
                
            otherwise
                error('OTF 1D plot not implemented for: %s\n',opticsModel);
        end
        
        fx = fSupport(1,:,1);
        otfWave = zeros(length(fx),nWave);
        for ii=1:nWave, otfWave(:,ii) = fftshift(otf(1,:,ii)); end
        
        mesh(fx,wavelength,otfWave'); view(30,20);
        xlabel('cycles/mm'); ylabel('Wavelength (nm)'); zlabel('abs(OTF)');
        
        % Store the data in the figure.
        uData.otf = otfWave; uData.fSupport = fx;
        uData.wavelength = wavelength;
        
    otherwise
        error('Unknown plotOTF data type.');
end

% There should be a uData no matter what.  But just in case ...
if exist('uData','var'), set(gcf,'UserData',uData); end

end

function uData = plotIlluminanceMesh(oi,yScale)
% Plot optical image illuminance (lux) as a mesh
%
%   plotIlluminanceMesh(oi,yScale)
%
% The default scaling of the lux axis is logarithmic.  Set yScale to 'linear' for a
% linear scale.
%
% If roiFlag is set to true (1), the user selects a region of the image
% from the optical image window. Otherwise the entire image is plotted.
%
% In the GraphWin, set Tools | Move Camera to rotate the view.
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('oi'), error('OI required.'); end
if ieNotDefined('yScale'),  yScale = 'log'; end

illum = oiGet(oi,'illuminance');

spacing = oiGet(oi,'sample spacing','um');
sz = size(illum);
r = (1:sz(1))*spacing(1);
c = (1:sz(2))*spacing(2);
switch yScale
    case 'log'
        uData.data = fliplr(log10(illum));
        mesh(c,r,uData.data);
        zlabel('Lux (Log 10)')
    case 'linear'
        uData.data = fliplr(illum);
        mesh(c,r,uData.data);
        zlabel('Lux')
    otherwise
        error('unknown yScale.');
end

uData.c = c; uData.r = r;

xlabel('um'); ylabel('um');
title('Illuminance');

end

function uData = plotOICIE(oi,dataType,roiLocs)
% plotting CIE data from optical image.  Could be moved into the case
% statements of the mother ship.
%
%  uData = plotOICIE(oi,dataType,roiLocs)
%
%   Graph  optical image properties (Luminance, chromaticity coordinates)
%   from an ROI.  The user is prompted to select the ROI in the OI window.
%
%   The plotted values can be obtained from the GraphWin using
%
%       udata = get(gcf,'userdata');
%
% Examples:
%   oi = vcGetObject('oi');
%   ieNewGraphWin;
%   udata = plotOICIE(oi,'chromaticity')
%   plotOICIE(oi,'illuminance',roiLocs);
%   plotOICIE(oi,'chromaticity',roiLocs);
%
% Copyright ImagEval Consultants, LLC, 2003.

switch lower(dataType)
    
    case {'chromaticity'}
        photons = vcGetROIData(oi,roiLocs,'photons');
        wave = oiGet(oi,'wave');
        XYZ = ieXYZFromPhotons(photons,wave);
        data = chromaticity(XYZ);
        uData.x = data(:,1); uData.y = data(:,2);
        val = mean(XYZ); valxy = mean(data);
        
        chromaticityPlot(data,[],[],0);
        title('roiLocs-chromaticity (CIE 1931)');
        
        txt = sprintf('Means\n');
        tmp = sprintf('X= %.02f\nY= %.02f\nZ= %.02f\n',val(1),val(2),val(3));
        txt = addText(txt,tmp);
        tmp = sprintf('x= %0.02f\ny= %0.02f\n',valxy(1),valxy(2));
        txt = addText(txt,tmp);
        text(0.8,0.65,txt);
        axis equal
        hold off
        
    case {'illuminance'}
        data = vcGetROIData(oi,roiLocs,'illuminance');
        histogram(data(:));
        uData.illum = data;
        xlabel('Iluminance (lux)'); ylabel('Count');
        title('Iluminance histogram');
        
    otherwise
        error('Unknown oi plot data type %s\n',dataType);
end

uData.roiLocs = roiLocs;
oName = oiGet(oi,'name');
set(gcf,'Name',sprintf('ISET-OI: %s',oName));

end


%---------------------------------------------------
%{
function sz = selectPlotSupport(data,prct)
% Select a central region for plotting
%
%  sz = selectPlotSupport(data,prct)
%
% Sometimes we have a large surface to plot but the interesting part is
% near the middle of the data set.  Rather than plotting the entire surf or
% mesh(data) we pull out a central region.  This routine encapsulates the
% method for choosing the  extent of data we pull out.  This routine is
% used in conjunction with getMiddleMatrix.
%
%  See meshPlot
%
% TODO: What if data are a vector?  Can we adjust this routine to make it work?

if ieNotDefined('prct'), prct = 0.01; end

r = size(data,1); mx = max(data(:));
centerRow = round(r/2);

% Find the locations in the center row that are less than prct of the
% data maximum.
l = (data(centerRow,:) <= prct*mx);

if max(l) == 0
    % Nothing found
    sz = centerRow - 1;
else
    % Not sure what is going on here ...
    [v,idx] = max(data(centerRow,l));
    sz = max(25,centerRow - idx);
end

end
%}
