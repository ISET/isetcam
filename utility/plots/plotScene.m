function [udata, g] = plotScene(scene,pType,roiLocs,varargin)
% Gateway routine to plot scene radiance properties
%
%  [udata, figNum] = plotScene([scene],[pType='hlineluminance'],[roiLocs])
%
% The scene plots show the radiance, luminance, contrast, illuminant or
% depth data in various formats.
%
% The figure handle is figNum.
% The data are stored in the structure udata.
% This variable is stored in figure: udata = get(figNum,'userdata')
%
% The values of the plot type (pType) are
%
%    Radiance
%     {'radiance hline'}          - Horizontal line radiance (photons)
%     {'radiance vline'}          - Vertical line radiance (photons)
%     {'radiance fft'}            - Contrast spatial frequency amplitude(single wavelength)
%     {'radiance image with grid'}  - Render radiance image
%     {'radiance waveband image'}          - Render waveband range of radiance image
%     {'radiance energy roi'}        - mean energy radiance of roi
%     {'radiance photons roi'}        - mean quantal radiance of roi
%
%    Reflectance
%     {'reflectance roi'}            - mean reflectance of roi
%
%    Luminance and chromaticity
%     {'luminance roi'}           - mean luminance of roi
%     {'luminance hline'}         - Horizontal line luminance
%     {'luminance vline '}        - Vertical line luminance
%     {'luminance fft'}           - 2D fft of scene luminance contrast
%     {'luminance fft hline'}     - Horizontal line luminance contrast Fourier transform
%     {'luminance fft vline'}     - Vertical line luminance Fourier transform
%     {'luminance mesh linear'}
%     {'luminance mesh log10'}
%     {'chromaticity'}            - mean CIE-roiLocs chromaticity of roi
%
%    Contrast
%     {'contrast hline'}          - Horizontal line contrast
%     {'contrast vline'}          - Vertical line contrast
%
%    Illuminant
%     {'illuminant energy'}       - Pure spectral case illuminant energy
%     {'illuminant energy roi'}   - Spatial-spectral illuminant energy
%     {'illuminant photons'}      - Pure spectral case illuminant energy
%     {'illuminant photons roi'}  - Spatial-spectral scene illuminant photons
%     {'illuminant image'}        - RGB image of space-varying illumination
%     {'illuminant hline energy'}
%     {'illuminant hline photons'}
%     {'illuminant vline energy'}
%     {'illuminant vline photons'}
%
%    Depth
%     {'depth map'}              - Depth map (Meters)
%     {'depth map contour'}      - Depth map with contour overlaid (Meters)
%
% See also:  oiPlot, plotSceneRadiance
%
% Examples:
%  A line plot of the radiance, starting at the (x,y) point [1,rows]
%     scene = vcGetObject('SCENE');
%     rows = round(sceneGet(scene,'rows')/2);
%     plotScene(scene,'hline radiance',[1,rows]);
%
%  A region of interest
%
%  Fourier Transform of the luminance in the row
%     uData = plotScene(scene,'luminance fft hline',[1,rows])
%
%  Radiance image with an overlaid spatial grid
%     plotScene(scene,'radiance image with grid')
%
%     plotScene(scene,'illuminant photons')
%     plotScene(scene,'depth map')
%
%  Reflectance data from an ROI
%     scene = vcGetObject('scene');
%     [roiLocs, roiRect]  = vcROISelect(scene);
%     [f, uData] = plotScene(scene,'reflectance',roiLocs);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('scene'), scene = vcGetObject('scene'); end
if ieNotDefined('pType'), pType = 'hlineluminance'; end

% Possible return
udata = [];

% Format the parameter for the plot type
pType = ieParamFormat(pType);

if ieNotDefined('roiLocs')
    switch lower(pType)
        case {'radiancehline','hlineradiance',  ...
                'radiancevline','vlineradiance' ...
                'luminancehline', ...
                'luminancefftvline', ...
                'luminanceffthline' ...
                'luminancevline','vlineluminance' ...
                'contrasthline','hlinecontrast', ...
                'contrastvline','vlinecontrast'}
            
            % Get a location
            roiLocs = vcPointSelect(scene);
            
        case {'radianceenergyroi'...
                'radiancephotonsroi', ...
                'chromaticityroi','chromaticity', ...
                'luminanceroi','luminance',...
                'reflectanceroi','reflectance'...
                'illuminantphotonsroi','illuminantenergyroi'}
            
            % Check illuminant case for spatial spectral
            % All other cases are spatial, so just get the data.
            if isequal( lower(pType),'illuminantphotonsroi') || ...
                    isequal(lower(pType),'illuminantenergyroi')
                if isequal(sceneGet(scene,'illuminant format'),'spatial spectral')
                    [roiLocs, roiRect] = vcROISelect(scene);
                end
            else
                % Region of interest plots
                [roiLocs, roiRect] = vcROISelect(scene);
            end
            
        otherwise
            % There are some cases that are OK without an roiLocs value or ROI.
    end
end

% Make the plot window and use set a default gray scale map.
g = vcNewGraphWin;
mp = 0.4*gray(64) + 0.3*ones(size(gray(64)));
colormap(mp);
nTicks = 4;   % For the images and graphs

switch lower(pType)
    case {'radianceenergyroi'}
        % mean radiance in energy of roi
        % g = plotScene(scene,'radiance energy roi',roiLocs);
        energy = vcGetROIData(scene,roiLocs,'energy');
        wave   = sceneGet(scene,'wave');
        energy = mean(energy,1);
        
        udata.wave = wave;
        udata.energy = energy;
        plot(wave,energy,'-'); grid on;
        
        % Fix an annoying Matlab plotting bug
        if max(energy(:)) < 1.1*min(energy(:))
            set(gca,'ylim',[0.99*min(energy(:)), 1.01*max(energy(:))])
        end
        xlabel('Wavelength (nm)'); ylabel('Radiance (watts/sr/nm/m^2)');
        
    case {'radiancephotonsroi'}
        % mean radiance in photons of roi
        % g = plotScene(scene,'radiance photons roi',roiLocs);
        photons = vcGetROIData(scene,roiLocs,'photons');
        wave = sceneGet(scene,'wave');
        photons = mean(photons,1);
        
        udata.wave = wave;
        udata.photons = photons;
        plot(wave,photons,'-'); grid on;
        
        % Fix an annoying Matlab plotting bug
        if max(photons(:)) < 1.1*min(photons(:))
            set(gca,'ylim',[0.99*min(photons(:)), 1.01*max(photons(:))])
        end
        xlabel('Wavelength (nm)'); ylabel('Radiance (q/sec/sr/nm/m^2)');
        
    case {'radiancehline','hlineradiance'}
        
        data = sceneGet(scene,'photons');
        if isempty(data), warndlg(sprintf('Photon data are unavailable.')); return; end
        
        wave = sceneGet(scene,'wave');
        data = squeeze(data(roiLocs(2),:,:));
        pos = sceneSpatialSupport(scene,'mm');
        
        if size(data,1) == 1
            % Monochrome image
            plot(pos.x,data');
            xlabel('Position (mm)');
            ylabel('radiance (q/s/nm/m^2)');
            grid on; set(gca,'xtick',ieChooseTickMarks(pos.x,nTicks))
        else
            mesh(pos.x,wave,data');
            xlabel('Position (mm)');
            ylabel('Wavelength (nm)'); zlabel('Radiance (q/s/nm/m^2)');
            grid on; set(gca,'xtick',ieChooseTickMarks(pos.x,nTicks))
        end
        colormap(cool(64))
        
        udata.wave = wave; udata.pos = pos.x; udata.data = data';
        udata.cmd = 'mesh(pos,wave,data)';
        
    case {'radiancevline','vlineradiance'}
        % plotScene(scene,'radiance vline',roiLocs)
        %
        data = sceneGet(scene,'photons');
        if isempty(data), warndlg(sprintf('Photon data are unavailable.')); return; end
        
        wave = sceneGet(scene,'wave');
        data = squeeze(data(:,roiLocs(1),:));
        pos = sceneSpatialSupport(scene,'mm');
        
        if size(data,2) == 1
            % Monochrome image
            plot(pos.y,data');
            xlabel('Position (mm)');
            ylabel('radiance (q/s/nm/m^2)');
            grid on; set(gca,'xtick',ieChooseTickMarks(pos.y,nTicks))
        else
            mesh(pos.y,wave,data');
            xlabel('Position (mm)');
            ylabel('Wavelength (nm)'); zlabel('Radiance (q/s/nm/m^2)');
            grid on; set(gca,'xtick',ieChooseTickMarks(pos.y,nTicks))
        end
        colormap(cool(64))
        
        udata.wave = wave; udata.pos = pos.y; udata.data = data';
        udata.cmd = 'mesh(pos,wave,data)';
        
        
    case {'reflectanceroi','reflectance'}
        % plotScene(scene,'reflectance roi')
        % Mean reflectance in the selected region
        wave = sceneGet(scene,'wave');
        reflectance = sceneGet(scene,'roi reflectance',roiLocs);
        reflectance = mean(reflectance);
        
        % Start the plotting and storage
        plot(wave,reflectance);
        mxReflectance = max(reflectance(:));
        set(gca,'ylim',[0,max(1.05,mxReflectance)]);
        xlabel('Wavelength (nm)'); ylabel('Reflectance'); grid on
        
        udata.wave = wave;
        udata.reflectance = reflectance;
        
    case {'radiancefftwaveband'}
        % Spatial frequency amplitude spectrum at a single wavelength.
        % Axis range could be better.
        % The mean is removed, so this is really the contrast amplitude
        % spectrum.
        if isempty(varargin)
            wave = sceneGet(scene,'wave');
            selectedWave = wave(round(length(wave)/2));
        else selectedWave = varargin{1};
        end
        
        data = sceneGet(scene,'photons',selectedWave);
        if isempty(data), warndlg(sprintf('Photon data are unavailable.')); return; end
        % Remove mean to generate contrast
        data = data - mean(data(:));
        sz = size(data);
        
        fov = sceneGet(scene,'h fov');
        x = 1:sz(2); x = x - mean(x); x = x/fov;
        y = 1:sz(1); y = y - mean(y); y = y/fov;
        udata.x = x; udata.y = y;
        
        udata.z = fftshift(abs(fft2(data)));
        udata.cmd = 'mesh(x,y,z)';
        mesh(udata.x,udata.y,udata.z);
        colormap(hot(64))
        xlabel('Cycles/image'); ylabel('Cycles/image'); zlabel('Amplitude');
        str = sprintf('Amplitude spectrum at %.0f nm', selectedWave);
        title(str);
    case {'radiancefftimage'}
        % Spatial frequency amplitude spectrum at a single wavelength.
        % Axis range could be better.
        % The mean is removed, so this is really the contrast amplitude
        % spectrum.
        if isempty(varargin)
            wave = sceneGet(scene,'wave');
            selectedWave = wave(round(length(wave)/2));
        else selectedWave = varargin{1};
        end
        
        data = sceneGet(scene,'photons',selectedWave);
        if isempty(data), warndlg(sprintf('Photon data are unavailable.')); return; end
        % Remove mean to generate contrast
        data = data - mean(data(:));
        sz = size(data);
        
        fov = sceneGet(scene,'h fov');
        x = 1:sz(2); x = x - mean(x); x = x/fov;
        y = 1:sz(1); y = y - mean(y); y = y/fov;
        udata.x = x; udata.y = y;
        udata.z = fftshift(abs(fft2(data)));
        udata.cmd = 'imagesc(x,y,z)';
        imagesc(udata.x,udata.y,udata.z);
        xlabel('Cycles/image'); ylabel('Cycles/image'); zlabel('Amplitude');
        str = sprintf('Amplitude spectrum at %.0f nm', selectedWave);
        title(str); colormap(hot(64));
        
    case {'radianceimagewithgrid','radianceimage'}
        % scene = vcGetObject('SCENE');
        % plotScene(scene,'radianceimagewithgrid')
        
        rad  = sceneGet(scene,'photons');
        wave = sceneGet(scene,'wave');
        sz   = sceneGet(scene,'size');      % Row and col samples
        
        spacing = sceneGet(scene,'sampleSpacing','mm'); % Spacing is mm per samp here
        xCoords = spacing(2) * (1:sz(2)); xCoords = xCoords - mean(xCoords);
        yCoords = spacing(1) * (1:sz(1)); yCoords = yCoords - mean(yCoords);
        
        suggestedSpacing = round(max(xCoords(:))/5);
        if length(varargin) >=1, gSpacing = varargin{1};  % mm spacing
        else
            gSpacing = ieReadNumber('Enter grid spacing (mm)',suggestedSpacing,'%.2f');
        end
        
        imageSPD(rad,wave,1,sz(1),sz(2),1,xCoords,yCoords);
        xlabel('Position (mm)'); ylabel('Position (mm)');
        
        udata.rad = rad;
        udata.xCoords = xCoords;
        udata.yCoords = yCoords;
        
        xGrid = (0:gSpacing:round(max(xCoords))); tmp = -1*fliplr(xGrid); xGrid = [tmp(1:(end-1)), xGrid];
        yGrid = (0:gSpacing:round(max(yCoords))); tmp = -1*fliplr(yGrid); yGrid = [tmp(1:(end-1)), yGrid];
        
        set(gca,'xcolor',[.5 .5 .5]); set(gca,'ycolor',[.5 .5 .5]);
        set(gca,'xtick',xGrid,'ytick',yGrid); grid on
        
    case {'radiancewavebandimage'}
        % scene = vcGetObject('SCENE'); plotScene(scene,'wavebandimage')
        
        % Show just a wavelength range of the image.
        % First developed for rendering infrared band.
        % We don't render it in color, but just as an intensity image
        wave = sceneGet(scene,'wave');
        wSpacing = wave(2) - wave(1);
        str = sprintf('Enter wave range (spacing = %.0f)',wSpacing);
        wLimits = ieReadMatrix([wave(1),wave(end)],'%.0f  ',str);
        
        % Make sure we land on a sampled wavelength
        wLimits(1)  = wave(ieFindWaveIndex(wave,wLimits(1),0));
        
        % Create samples and image title
        if length(wLimits) > 1
            wSamples = (wLimits(1):wSpacing:wLimits(2));
            fTitle = sprintf('Waveband (%.0f:%.0f:%.0f)',...
                wLimits(1),wSpacing,wLimits(2));
        else
            wSamples = wLimits(1);
            fTitle = sprintf('Waveband %.0f',wLimits);
        end
        
        % Go get the radiance image
        rad = sceneGet(scene,'photons',wSamples);
        rad = sum(rad,3);
        
        % Make a new window and show the image
        % figure(vcSelectFigure('GRAPHWIN'));   clf
        imagesc(rad); colormap(gray(256));axis image;
        udata.rad = rad;
        udata.wSamples = wSamples;
        
        set(gca,'xtick',[],'ytick',[]);
        title(fTitle);
        
        % Luminance
    case {'luminancehline'}
        
        data = sceneGet(scene,'luminance');
        if isempty(data), warndlg(sprintf('luminance data are unavailable.')); return; end
        lum = data(roiLocs(2),:);
        pos = sceneSpatialSupport(scene,'mm');
        
        % figure(vcSelectFigure('GRAPHWIN'));   clf
        plot(pos.x,lum);
        xlabel('Position (mm)'); ylabel('luminance (cd/m^2)');
        grid on; set(gca,'xtick',ieChooseTickMarks(pos.x,nTicks))
        
        udata.pos = pos.x; udata.data = lum';
        udata.cmd = 'plot(pos,lum)';
        
    case {'luminanceffthline'}
        % This is the FFT of the luminance contrast
        % space = sceneGet(scene,'spatialSupport');
        
        data = sceneGet(scene,'luminance');
        if isempty(data), warndlg(sprintf('luminance data are unavailable.')); return; end
        lum = data(roiLocs(2),:);
        pos = sceneSpatialSupport(scene,'mm');
        
        % Compute amplitude spectrum in units of millimeters
        normalize = 1;
        [freq,fftlum] = ieSpace2Amp(pos.x,lum,normalize);
        
        % figure(vcSelectFigure('GRAPHWIN'));   clf
        plot(freq,fftlum,'r-');
        xlabel('Cycles/mm'); ylabel('Normalized amplitude'); grid on
        
        udata.freq = freq; udata.data = fftlum;
        udata.cmd = 'plot(freq,data,''r-'')';
        
    case {'luminancevline','vlineluminance'}
        
        data = sceneGet(scene,'luminance');
        if isempty(data), warndlg(sprintf('luminance data are unavailable.')); return; end
        lum = data(:,roiLocs(1));
        pos = sceneSpatialSupport(scene,'mm');
        
        % figure(vcSelectFigure('GRAPHWIN'));   clf
        plot(pos.y,lum);
        xlabel('Position (mm)'); ylabel('luminance (cd/m^2)');
        grid on; set(gca,'xtick',ieChooseTickMarks(pos.y,nTicks))
        
        udata.pos = pos.y; udata.data = lum';
        udata.cmd = 'plot(pos,lum)';
        
    case {'luminancefftvline'}
        
        % space = sceneGet(scene,'spatialSupport');
        
        data = sceneGet(scene,'luminance');
        if isempty(data), warndlg(sprintf('luminance data are unavailable.')); return; end
        lum = data(:,roiLocs(1));
        yPosMM = sceneSpatialSupport(scene,'mm');
        
        % Compute amplitude spectrum in units of millimeters
        normalize = 1;
        [freq,fftlum] = ieSpace2Amp(yPosMM.y,lum,normalize);
        
        % figure(vcSelectFigure('GRAPHWIN'));   clf
        plot(freq,fftlum,'r-');
        xlabel('Cycles/mm'); ylabel('Normalized amplitude'); grid on
        
        udata.freq = freq; udata.data = fftlum;
        udata.cmd = 'plot(freq,data,''r-'')';
        
    case {'luminanceroi','luminance'}
        % Mean luminance of roi
        % g = plotScene(scene,'luminance roi',roiLocs);
        data = vcGetROIData(scene,roiLocs,'luminance');
        udata.lum = data;
        if isempty(data), error('Luminance must be present in the scene structure.'); end
        histogram(data(:),40);
        xlabel('Luminance (cd/m2)'); ylabel('Count');
        title('Luminance histogram');
        
    case {'chromaticityroi','chromaticity'}
        % Mean CIE-roiLocs chromaticity of roi
        % g = plotScene(scene,'chromaticity roi',roiLocs);
        photons = vcGetROIData(scene,roiLocs,'photons');
        wave   = sceneGet(scene,'wave');
        XYZ    = ieXYZFromPhotons(photons,wave);
        data   = chromaticity(XYZ);
        udata.x = data(:,1); udata.y = data(:,2);
        
        % Values for legend
        if size(XYZ,1) > 1,   val = mean(XYZ); valxy = mean(data);
        else                  val = XYZ; valxy = data;
        end
        
        % Put up the plot of the spectrum locus and the data
        chromaticityPlot(data,[],[],0);
        title('roiLocs-chromaticity (CIE 1931)');
        
        % Legend text
        txt = sprintf('Means\n');
        tmp = sprintf('X= %.02f\nY= %.02f\nZ= %.02f\n',val(1),val(2),val(3));
        txt = addText(txt,tmp);
        tmp = sprintf('x= %0.02f\ny= %0.02f\n',valxy(1),valxy(2));
        txt = addText(txt,tmp);
        text(0.8,0.55,txt);
        axis equal, hold off
        
        % Contrast - plotSceneContrast?  COuld go there.
    case {'contrasthline','hlinecontrast'}
        % Plot percent contrast (difference from the mean as a percentage
        % of the mean).
        
        data = sceneGet(scene,'photons');
        if isempty(data), warndlg(sprintf('Photon data are unavailable.')); return; end
        data = squeeze(data(roiLocs(2),:,:));
        
        % Percent contrast
        mn = mean(data(:));
        if mn == 0, warndlg('Zero mean.  Cannot compute contrast.'); return; end
        data = 100*(data - mn)/mn;
        
        pos = sceneSpatialSupport(scene,'microns');
        
        % figure(vcSelectFigure('GRAPHWIN'));   clf
        wave = sceneGet(scene,'wave');
        
        mesh(pos.x,wave,data');
        xlabel('Position (um)'); ylabel('Wavelength (nm)'); zlabel('Percent contrast');
        grid on; set(gca,'xtick',ieChooseTickMarks(pos.x,nTicks))
        udata.wave = wave; udata.pos = pos.x; udata.data = data';
        udata.cmd = 'mesh(pos,wave,data)';
        
        
    case {'contrastvline','vlinecontrast'}
        %
        data = sceneGet(scene,'photons');
        if isempty(data), warndlg(sprintf('Photon data are unavailable.')); return; end
        wave = sceneGet(scene,'wave');
        
        data = squeeze(data(:,roiLocs(1),:));
        
        % Percent contrast
        mn = mean(data(:));
        if mn == 0, warndlg('Zero mean.  Cannot compute contrast.'); return; end
        data = 100*(data - mn)/mn;
        
        pos = sceneSpatialSupport(scene,'mm');
        
        mesh(pos.y,wave,data');
        xlabel('Position (mm)'); ylabel('Wavelength (nm)');zlabel('radiance (q/s/nm/m^2)')
        zlabel('Percent contrast')
        grid on; set(gca,'xtick',ieChooseTickMarks(pos.y))
        
        udata.wave = wave; udata.pos = pos.y; udata.data = data';
        udata.cmd = 'mesh(pos,wave,data)';
        
        
        % Could go into plotSceneLuminance
    case {'luminancefft','fftluminance'}
        % Spatial frequency amplitude at a single wavelength.  Axis range
        % could be better.
        wave = sceneGet(scene,'wave');
        selectedWave = wave(round(length(wave)/2));
        data = sceneGet(scene,'photons',selectedWave);
        if isempty(data), warndlg(sprintf('Photon data are unavailable.')); return; end
        
        sz = size(data);
        udata.x = 1:sz(2); udata.y = 1:sz(1); udata.z = fftshift(abs(fft2(data)));
        udata.cmd = 'mesh(x,y,z)';
        mesh(udata.x,udata.y,udata.z);
        xlabel('Cycles/image'); ylabel('Cycles/image'); zlabel('Amplitude');
        str = sprintf('Amplitude spectrum at %.0f nm', selectedWave);
        title(str);
        
    case {'luminancemeshlinear','luminancemeshlog10','luminancemeshlog'}
        % plotScene(scene,'luminance mesh linear')
        
        if ieContains(pType,'log'), yScale = 'log';
        else yScale = 'linear';
        end
        
        lum = sceneGet(scene,'luminance');
        lum = fliplr(lum);  % Make same orientation as the image in the window
        
        spacing = sceneGet(scene,'samplespacing','mm');
        sz = size(lum);
        r = (1:sz(1))*spacing(1);
        c = (1:sz(2))*spacing(2);
        
        % It appears that if lum is a constant, the mesh function fails
        % without an error message.  Tell Matlab. This is for version
        % 7.0.1.24704 (R14) Service Pack 1. The actual lum values range a
        % little around 100.  A truly constant value, say
        % 100*ones(size(lum)) plots ok.
        switch yScale
            case 'log'
                mesh(c,r,log10(lum));
                zlabel('cd/m^2 (log 10)')
            case 'linear'
                mesh(c,r,lum);
                zlabel('cd/m^2')
            otherwise
                error('unknown yScale.');
        end
        
        xlabel('mm'); ylabel('mm');
        title('Luminance');
        
        % Illuminant - pure spectral case should go here
        % Could all go into plotSceneIlluminant
    case {'illuminantenergyroi','illuminantenergy'}
        % plotScene(scene,'illuminant energy')
        % plotScene(scene,'illuminant energy roi',roiLocs');
        % Graph for spectral, image for spatial spectral
        handle = ieSessionGet('scenewindowhandle');
        ieInWindowMessage('',handle);
        wave = sceneGet(scene,'wave');
        
        switch sceneGet(scene,'illuminant format')
            case 'spectral'
                energy = sceneGet(scene,'illuminant energy');
                
            case 'spatial spectral'
                % Have the user choose the ROI because the illuminant is
                % space-varying
                energy = vcGetROIData(scene,roiLocs,'illuminant energy');
                energy = mean(energy,1);
            otherwise
                % No illuminant
                ieInWindowMessage('No illuminant data.',handle);
                close(gcf)
        end
        plot(wave(:),energy,'-')
        xlabel('Wavelength (nm)');
        ylabel('Energy (watts/sr/nm/m^2)');
        grid on,  title('Illuminant data')
        udata.wave = wave; udata.energy = energy;
        udata.comment = sceneGet(scene,'illuminant comment');
        
    case {'illuminantphotonsroi','illuminantphotons'}
        % plotScene(scene,'illuminant photons')
        % plotScene(scene,'illuminant photons roi',roiLocs);
        % Graph for spectral, image for spatial spectral
        handle = ieSessionGet('scenewindowhandle');
        ieInWindowMessage('',handle);
        wave = sceneGet(scene,'wave');
        switch sceneGet(scene,'illuminant format')
            case 'spectral'
                photons = sceneGet(scene,'illuminant photons');
            case 'spatial spectral'
                % Spatial region of the illuminant
                photons = vcGetROIData(scene,roiLocs,'illuminant photons');
                photons = mean(photons,1);
            otherwise
                ieInWindowMessage('No illuminant data.',handle);
                close(gcf)
        end
        
        % Plot 'em up
        plot(wave(:),photons,'-')
        xlabel('Wavelength (nm)'); ylabel('Radiance (q/sec/sr/nm/m^2)');
        grid on,  title('Illuminant data')
        udata.wave = wave; udata.photons = photons;
        udata.comment = sceneGet(scene,'illuminant comment');
        
        % Spatial spectral illumination cases
    case {'illuminantimage'}
        % plotScene(scene,'illuminant image')
        % Make an RGB image showing the spatial image of the illuminant.
        
        wave = sceneGet(scene,'wave');
        sz = sceneGet(scene,'size');
        energy = sceneGet(scene,'illuminant energy');
        if isempty(energy)
            ieInWindowMessage('No illuminant data.',handle);
            close(gcf);
            error('No illuminant data');
        end
        
        switch sceneGet(scene,'illuminant format')
            case {'spectral'}
                % Makes a uniform SPD image
                energy = repmat(energy(:)',prod(sz),1);
                energy = XW2RGBFormat(energy,sz(1),sz(2));
            otherwise
        end
        
        % Create an RGB image
        udata.srgb = xyz2srgb(ieXYZFromEnergy(energy,wave));
        imagesc(sz(1),sz(2),udata.srgb);  grid on; axis off
        title('Illumination image')
        
        % Depth - COuld go into plotSceneDepth
    case {'depthmap'}
        %plotScene(scene,'depth map')
        dmap = sceneGet(scene,'depth map');
        if isempty(dmap), error('No depth map')
        else
            imagesc(dmap); colormap(flipud(gray(64))); % Near dark, far light
            axis off; set(g,'Name','ISET: Depth map (m)');
            % Far is dark, close is light
            colormap(flipud(gray(64)));
        end
        udata = dmap;
        
    case {'depthmapcontour'}
        %plotScene(scene,'depth map contour')
        if length(varargin) >=1, n = varargin{1}; else n = 4; end
        
        dmap = sceneGet(scene,'depth map'); mx = max(dmap(:));
        dmap = ieScale(dmap,0,1);
        dmap = 1 - dmap;   % Make near light, far dark
        drgb = cat(3,dmap,dmap,dmap);
        
        imagesc(drgb); hold on; colormap(flipud(gray(64)));
        v = (1:n)/n; contour(dmap,v);
        hold off
        namestr = sprintf('ISET: Depth map (max = %.1f m)',mx);
        axis off; set(g,'Name',namestr);
        
    otherwise
        error('Unknown plotScene type.: %s\n',pType);
end

% Add roi information to the window.
if ~exist('udata','var'), udata = get(gcf,'userdata'); end
if exist('roiRect','var'), udata.roiRect = roiRect; end
if exist('roiLocs','var'), udata.roiLocs = roiLocs; end
set(gcf,'userdata',udata);

return;

