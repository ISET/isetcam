function [udata, g] = scenePlot(scene,pType,roiLocs,varargin)
% Gateway routine to plot scene radiance properties
%
% Synopsis
%  [udata, hdl] = scenePlot([scene],[pType='luminance hline'],[roiLocs],varargin)
%
% Brief:
%   Various plots of the scene radiance, luminance, contrast,
%   illuminant or depth data in various formats.
%
% Optional
%   'nofigure' - When the last argument is 'nofigure', the plot is
%                deleted, only the data are returned;
% Returns
%  udata:  The plotted data are stored in the structure udata.
%         This variable is stored in figure: udata = get(figNum,'userdata')
%  hdl:    The figure handle
%
% The roiLocs can usually be specified either as an Nx2 matrix of locations
% or as a rect, in which case the rect is recognized and converted to
% roiLocs by the routine ieRect2Locs (within vcGetROIData)
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
%     {'luminance mesh linear'}   - Use this to see a luminance image.
%     {'luminance mesh log10'}
%     {'chromaticity roi'}        - xy-chromaticity diagram of points in an roi
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
% ieExamplesPrint('scenePlot');
%
% See also
%   oiPlot, sensorPlot, ipPlot

% Examples:
%{
    % A line plot of the radiance, starting at the (x,y) point [1,rows]
    scene = sceneCreate;
    rows = round(sceneGet(scene,'rows')/2);
    scenePlot(scene,'hline radiance',[1,rows]);
%}
%{
   % ETTBSkip
   % Skip because it requires user clicking
   scene = sceneCreate; sceneWindow(scene);
   scenePlot(scene,'hline radiance');
   scenePlot(scene,'vline radiance');
%}
%{
   % Fourier Transform of the luminance in the row
   scene = sceneCreate;
   rows = round(sceneGet(scene,'rows')/2);
   uData = scenePlot(scene,'luminance fft hline',[1,rows])
%}
%{
   % ETTBSkip
   % Skip because it requires user clicking
   %
   % Radiance image with an overlaid spatial grid
   scene = sceneCreate;
   scenePlot(scene,'radiance image with grid')
   scenePlot(scene,'illuminant photons')
   scenePlot(scene,'depth map')
%}
%{
   % ETTBSkip
   % Skip because it requires user clicking
   %
   % Reflectance data from an ROI
   scene = sceneCreate;
   sceneWindow(scene);
   [roiLocs, roiRect]  = ieROISelect(scene);
   [f, uData] = scenePlot(scene,'reflectance',roiLocs);
%}

if ieNotDefined('scene'), scene = vcGetObject('scene'); end
if ieNotDefined('pType'), pType = 'hlineluminance'; end

% Possible return
udata = [];

% Format the parameter for the plot type
pType = ieParamFormat(pType);

%% Deal with the ROI
if ieNotDefined('roiLocs')
    switch lower(pType)
        case {'radiancevline','vlineradiance', ...
                'luminancefftvline', ...
                'luminancevline','vlineluminance' ...
                'contrastvline','vlinecontrast'}
            
            % Get a location and draw a vertical line
            roiLocs = iePointSelect(scene);
            
            % Draw a line on the sceneWindow.  I may be off by 1.
            sz = sceneGet(scene,'size');
            ieROIDraw(scene,'shape','line','shape data',[roiLocs(1) roiLocs(1) 1 sz(1)]);
            
        case {'radiancehline','hlineradiance',...
                'luminancehline','luminancehlinergb','luminanceffthline' ...
                'contrasthline','hlinecontrast'}
            
            % Get a location and draw a horizontal line
            roiLocs = iePointSelect(scene);
            
            % Draw a line on the sceneWindow.  I may be off by 1.
            sz = sceneGet(scene,'size');
            ieROIDraw(scene,'shape','line','shape data',[1 sz(2) roiLocs(2) roiLocs(2)]);
            
        case {'radianceenergyroi', 'radiancephotonsroi', ...
                'chromaticityroi','chromaticity', ...
                'luminanceroi','luminance',...
                'reflectanceroi','reflectance'}
            
            roiLocs = ieROISelect(scene);  % Should be ieROIRectSelect() or add parameters
            
        case {'illuminantphotonsroi','illuminantenergyroi'}
            
            % Check about the ROI for spatial spectral
            % All other cases are spatial, so just get the data.
            
            if isequal(sceneGet(scene,'illuminant format'),'spatial spectral')
                % User should select the ROI
                if ~exist('roiLocs','var')
                    [roiLocs, roiRect] = vcROISelect(scene);
                elseif isempty(roiLocs)
                    % Passed as empty.  Choose the whole scene.
                    sz = sceneGet(scene,'size');
                    roiRect = [1 1 sz(2) sz(1)];
                end
                ieROIDraw(scene,'shape','rect','shape data',roiRect);
            else
                % Not spatial spectral.
                disp('No ROI needed unless spatial spectral illluminant');
            end
            
        otherwise
            % There are some cases that are OK without an roiLocs value or
            % ROI. But we make it exist and be empty.
            roiLocs = [];
    end
elseif isa(roiLocs,'images.roi.Rectangle')
    % We now allow sending in a Matlab Rectangle roi
    roiRect = round(roiLocs.Position);
    roiLocs = ieRect2Locs(roiRect);
    ieDrawShape(scene,'rectangle',roiRect);
end


%% Make the plot window and use set a default gray scale map.

% Plot starts off.  Turned on at the end, except if no figure
% argument is passed.
g = ieNewGraphWin; g.Visible = 'off';
mp = 0.4*gray(64) + 0.3*ones(size(gray(64)));
colormap(mp);
nTicks = 4;   % For the images and graphs

switch lower(pType)
    case {'radianceenergyroi'}
        % mean radiance energy in a rectangular roi
        %
        %  g = scenePlot(scene,'radiance energy roi',roi);
        % 
        % The roi can be a Rectangle object, or a rect, or roiLocs.
        %
        energy = vcGetROIData(scene,roiLocs,'energy');
        wave   = sceneGet(scene,'wave');
        energy = mean(energy,1);
        
        udata.wave = wave;
        udata.energy = energy;
        if isscalar(energy)
            bar(wave,energy); grid on;
        else
            plot(wave,energy,'k-'); grid on;
        end
        
        % Fix an annoying Matlab plotting bug
        if max(energy(:)) < 1.1*min(energy(:))
            set(gca,'ylim',[0.99*min(energy(:)), 1.01*max(energy(:))])
        end
        xlabel('Wavelength (nm)'); ylabel('Radiance (watts/sr/nm/m^2)');
        
    case {'radiancephotonsroi'}
        % mean radiance in photons of roi
        % g = scenePlot(scene,'radiance photons roi',roiLocs);
        photons = vcGetROIData(scene,roiLocs,'photons');
        wave = sceneGet(scene,'wave');
        photons = mean(photons,1);
        
        udata.wave = wave;
        udata.photons = photons;
        if isscalar(photons)
            bar(wave,photons); grid on;
        else
            plot(wave,photons,'k-'); grid on;
        end
        
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
        udata.xy = roiLocs;
        
    case {'radiancevline','vlineradiance'}
        % scenePlot(scene,'radiance vline',roiLocs)
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
        % scenePlot(scene,'reflectance roi')
        % Mean reflectance in the selected region
        wave = sceneGet(scene,'wave');
        reflectance = sceneGet(scene,'roi reflectance',roiLocs);
        reflectance = mean(reflectance);
        
        % Start the plotting and storage
        plot(wave,reflectance,'k-');
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
        else, selectedWave = varargin{1};
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
        else, selectedWave = varargin{1};
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
        % scenePlot(scene,'radianceimagewithgrid')
        
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
        % scene = vcGetObject('SCENE'); scenePlot(scene,'wavebandimage')
        
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
        % Horizontal line of the luminance
        data = sceneGet(scene,'luminance');
        if isempty(data), warndlg(sprintf('luminance data are unavailable.')); return; end
        lum = data(roiLocs(2),:);
        pos = sceneSpatialSupport(scene,'mm');
        
        % figure(vcSelectFigure('GRAPHWIN'));   clf
        plot(pos.x,lum);
        xlabel('Position (mm)'); ylabel('luminance (cd/m^2)');
        grid on; set(gca,'xtick',ieChooseTickMarks(pos.x,nTicks))
        
        udata.pos = pos.x; udata.data = lum'; udata.row = roiLocs(2);
        udata.cmd = 'plot(pos,lum)';
        lineN = sprintf('Row %d',roiLocs(2));
        legend(({lineN}))
    case {'luminancehlinergb'}
        % scenePlot(scene,'luminance hline rgb',[1 564]);
        %
        % Plot the luminance of a line superimposed on the RGB
        % image.  The illuminance is log10 luminance plot.
        
        % The rgb image has the rendering parameters of the oiWindow.
        rgb = sceneGet(scene,'rgb'); cols = size(rgb,2);        
        imagesc(rgb); axis off; hold on;
        thisL = line([1 cols],[roiLocs(2) roiLocs(2)],'Color','g','LineStyle','--');
        thisL.LineWidth = 0.1;
        yyaxis left % No numbers on the image axis.
        set(gca,'xticklabel','','yticklabel','');

        % A white line of log illuminance.  Values on the right.
        yyaxis right;
        udata = scenePlot(scene,'luminance hline',[1,roiLocs(2)],'no figure');
        plot(1:numel(udata.data),udata.data,'w-');
        ax = gca; ax.YAxis(2).Scale = 'log'; 
        yMin = 10^(floor(log10(min(udata.data(:))))); 
        yMax = 10^(ceil(log10(max(udata.data(:)))));

        % This scale places the log plot in the bottom third of the image.
        ax.YAxis(2).Limits = [yMin,yMax^3];
        n = log10(yMax)-log10(yMin)+1;
        yTick = logspace(log10(yMin),log10(yMax),n);
        yTick = yTick(1:2:n);   % Space by 2 log units
        set(ax,'ytick',yTick);
        ylabel('Log10 luminance (cd/m^2)'); axis on;
        truesize;

        % Set the name and indicate the line.
        set(g,'Name',sprintf('Line %.0f (%s)',roiLocs(2),sceneGet(scene,'name')));

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
        plot(freq,fftlum,'k-');
        xlabel('Cycles/mm'); ylabel('Normalized amplitude'); grid on
        
        udata.freq = freq; udata.data = fftlum;
        udata.cmd = 'plot(freq,data,''k-'')';
        
    case {'luminancevline','vlineluminance'}
        
        data = sceneGet(scene,'luminance');
        if isempty(data), warndlg(sprintf('luminance data are unavailable.')); return; end
        lum = data(:,roiLocs(1));
        pos = sceneSpatialSupport(scene,'mm');
        
        % figure(vcSelectFigure('GRAPHWIN'));   clf
        plot(pos.y,lum);
        xlabel('Position (mm)'); ylabel('luminance (cd/m^2)');
        grid on; set(gca,'xtick',ieChooseTickMarks(pos.y,nTicks))
        
        udata.pos = pos.y; udata.data = lum'; udata.column = roiLocs(1);
        udata.cmd = 'plot(pos,lum)';
        lineN = sprintf('Col %d',roiLocs(1));
        legend(({lineN}))

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
        plot(freq,fftlum,'k-');
        xlabel('Cycles/mm'); ylabel('Normalized amplitude'); grid on
        
        udata.freq = freq; udata.data = fftlum;
        udata.cmd = 'plot(freq,data,''k-'')';
        
    case {'luminanceroi','luminance'}
        % Mean luminance of roi
        % g = scenePlot(scene,'luminance roi',roiLocs);
        data = vcGetROIData(scene,roiLocs,'luminance');
        udata.lum = data;
        if isempty(data), error('Luminance must be present in the scene structure.'); end
        histogram(data(:),40);
        xlabel('Luminance (cd/m2)'); ylabel('Count');
        title('Luminance histogram');
        
    case {'chromaticityroi','chromaticity'}
        % xy-chromaticity of roi locations
        %
        % The mean is shown in the legend
        %
        % g = scenePlot(scene,'chromaticity roi',roiLocs);
        photons = vcGetROIData(scene,roiLocs,'photons');
        wave   = sceneGet(scene,'wave');
        XYZ    = ieXYZFromPhotons(photons,wave);
        data   = chromaticity(XYZ);
        udata.x = data(:,1); udata.y = data(:,2);
        
        % Values for legend
        if size(XYZ,1) > 1,   val = mean(XYZ); valxy = mean(data);
        else ,                val = XYZ; valxy = data;
        end
        
        % Put up the plot of the spectrum locus and the data
        chromaticityPlot(data,[],[],0);
        title('xy-chromaticities (CIE 1931)');
        
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
        % scenePlot(scene,'luminance mesh linear')
        
        if ieContains(pType,'log'), yScale = 'log';
        else, yScale = 'linear';
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
        % scenePlot(scene,'illuminant energy')
        % scenePlot(scene,'illuminant energy roi',roiLocs');
        % scenePlot(scene,'illuminant energy roi',[]);
        % Graph for spectral, image for spatial spectral
        app = ieSessionGet('scenewindow');
        ieInWindowMessage('',app);
        wave = sceneGet(scene,'illuminant wave');
        
        switch sceneGet(scene,'illuminant format')
            case 'spectral'
                energy = sceneGet(scene,'illuminant energy');
                
            case 'spatial spectral'
                % Have the user choose the ROI because the illuminant is
                % space-varying
                if isempty(roiLocs)
                    energy = sceneGet(scene,'energy');
                    energy = mean(RGB2XWFormat(energy),1)';
                else
                    energy = vcGetROIData(scene,roiLocs,'illuminant energy');
                    energy = mean(energy,1);
                end
            otherwise
                % No illuminant
                ieInWindowMessage('No illuminant data.',app);
                close(gcf)
        end
        plot(wave(:),energy,'k-')
        xlabel('Wavelength (nm)');
        ylabel('Energy (watts/sr/nm/m^2)');

        % Protect any underscores in the name
        grid on,  title(strrep(sprintf('%s Illuminant',sceneGet(scene,'name')),'_','\_'));
        udata.wave = wave; udata.energy = energy;
        udata.comment = sceneGet(scene,'illuminant comment');
        
    case {'illuminantphotons','illuminantphotonsroi'}
        % scenePlot(scene,'illuminant photons')
        % scenePlot(scene,'illuminant photons roi')
        %
        %
        % Used if user knows the scene is not spatial-spectral
        app = ieSessionGet('scenewindow');
        ieInWindowMessage('',app);
        wave = sceneGet(scene,'illuminant wave');
        switch sceneGet(scene,'illuminant format')
            case 'spectral'
                photons = sceneGet(scene,'illuminant photons');
            case 'spatial spectral'
                if isempty(roiLocs)
                    % Get all the photons, convert to XW format, take the
                    % mean.
                    photons = sceneGet(scene,'photons');
                    photons = mean(RGB2XWFormat(photons),1)';
                else
                    photons = vcGetROIData(scene,roiLocs,'illuminant photons');
                    photons = mean(photons,1);
                end
            otherwise
                ieInWindowMessage('No illuminant data.',handle);
                close(gcf)
        end
        
        % Plot 'em up
        plot(wave(:),photons,'k-')
        xlabel('Wavelength (nm)'); ylabel('Radiance (q/sec/sr/nm/m^2)');
        % Protect any underscores in the name
        grid on,  title(strrep(sprintf('%s Illuminant',sceneGet(scene,'name')),'_','\_'));
        udata.wave = wave; udata.photons = photons;
        udata.comment = sceneGet(scene,'illuminant comment');
        

        % Spatial spectral illumination cases
    case {'illuminantimage'}
        % scenePlot(scene,'illuminant image')
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
        imagesc(sz(1),sz(2),udata.srgb);
        grid on; axis off; axis image;
        title('Illumination image')
        
        % Depth - COuld go into plotSceneDepth
    case {'depthmap'}
        %scenePlot(scene,'depth map')
        dmap = sceneGet(scene,'depth map');
        if isempty(dmap), error('No depth map')
        else
            imagesc(dmap); colormap(flipud(gray(64))); % Near dark, far light
            axis off; set(g,'Name','ISET: Depth map (m)');
            % Far is dark, close is light
            
            colormap(flipud(gray(64)));
            axis image; cb = colorbar;
            set(get(cb,'label'),'string','Meters','Rotation',90)
        end
        udata = dmap;
        
    case {'depthmapcontour'}
        %scenePlot(scene,'depth map contour')
        if length(varargin) >=1, n = varargin{1}; else, n = 4; end
        
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
        error('Unknown scenePlot type.: %s\n',pType);
end

%% Add information to the window.

% In some cases the udata is the image data (depth map)
if ~exist('udata','var'),  udata = get(gcf,'userdata'); end

% If it is a struct, then we add some information
if isstruct(udata)
    if exist('roiRect','var'), udata.roiRect = roiRect; end
    if exist('roiLocs','var'), udata.roiLocs = roiLocs; end
    set(gcf,'userdata',udata);
end

%% Suppress showing the window if the final varargin is nofigure
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
