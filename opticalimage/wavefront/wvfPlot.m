function [uData, pData, fighdl] = wvfPlot(wvfP, pType, varargin)
% Wavefront plots
%
% Syntax:
%   [userData, plotData, fighdl] = wvfPlot(wvfP, [pType], [varargin]);
%
% Description:
%    By default, this routine opens a new graph window (ieNewGraphWin). If
%    the final varargin argument is set to 'no window', then the
%    ieNewGraphWin is suppressed. Hence, you can use this call to plot
%    within a subplot of a current window.
%
%    Plot types:
%      wvf = wvfCreate;
%      wvf = wvfComputePSF(wvf);
%      wave = wvfGet(wvf, 'measured wavelength');
%      + psf angle - mesh. wvfPlot(wvf, 'psf angle', 'min', [], wave)
%      + psf space - mesh  wvfPlot(wvf, 'psf space', 'um', wave, 10)
%        2d OTF       - mesh (e.g., linepairs/'um')
%        1d OTF       - mesh (e.g., linepairs/'um')
%
%      + 1d psf angle - graph (middle horizontal line)
%      + 1d psf space - graph (middle horizontal line)
%
%      image psf angle   - image ('min')
%      image psf space   - image ('um')
%      image pupil amp   - image ('mm')
%      image pupil phase - image ('mm')
%
%      image wavefront aberration - image (size of aberration in 'um')
%
%      Angle units are 'sec', 'min', or 'deg'   default - 'min'
%      Space units are 'm', 'cm', 'mm', 'um'    default - 'mm'
%      + Add the string 'normalized' to force the 2d and 1d graphs to be
%      scaled to a peak of 1. See example below.
%
% Inputs:
%    wvfP     - Wavefront structure
%    pType    - Plot type
%
% Optional key/val pairs
%    unit       - Spatial units (default: 'mm')
%    wave       - Plotting wavelength (default: wvfGet(wvf,'wave'))
%    plot range - Axis range (default: Inf)
%    airy disk  - Plot an airy disk (default: false)
%    window     - Either a figure handle, or a logical (default: true)
% 
% Outputs:
%    uData    - The user data that are plotted
%    pData    - The handles from the plotted data
%    fighdl   - The figure
%
% Notes:
%    * [Note: JNM - The 'imagepupilphase' below, contains the following
%      requests to fix:
%         1. modify colormap so that periodicity of phase is accounted for.
%         2. code in other plotting scales (distances or angles)
%         3. confirm plotting: currently 90deg flipped of wikipedia
%         4. somehow remove the 0 phase areas outside of calculated pupil]
%
% See Also:
%    wvfComputePSF, v_wvfDiffractionPSF, ieNewGraphWin

% History:
%    xx/xx/12   bw    (c) Wavefront Toolbox Team
%    12/21/17   dhb   Use PsfToOtf to get the OTF for plotting.

% Examples:
%{
wvf = wvfCreate;
wave = 550;
wvf = wvfSet(wvf, 'calc wave', wave);
wvf = wvfCompute(wvf);
[u, p] = wvfPlot(wvf, '1d psf space');
wvfPlot(wvf,'psf','airy disk',true,'plot range',10,'unit','um');
%}
%{
wvf = wvfCreate;

% Change the calculated PSF wavelength and plot again
wave = 500;
wvf = wvfSet(wvf, 'calc wave', wave);
wvf = wvfCompute(wvf);    
wvfPlot(wvf, '1d psf space', 'unit', 'um');
wvfPlot(wvf,'image psf','unit','um','wave',wave,'plot range',10);
wvfPlot(wvf, '1d psf space','window',false);
wvfPlot(wvf,'psf');
wvfPlot(wvf,'psf','plot range',10,'unit','um','window',false);
%}

%% Parse

varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('wvfP',@isstruct);
p.addRequired('pType',@ischar)

p.addParameter('unit','mm',@ischar);
p.addParameter('wave',[],@isvector);
p.addParameter('plotrange',Inf,@isnumeric);
p.addParameter('airydisk',false,@islogical);
p.addParameter('window',true,@(x)(islogical(x) || ...
    isa(x,'matlab.ui.Figure') || ...
    isa(x,'matlab.graphics.layout.TiledChartLayout')));

pType  = ieParamFormat(pType);
varargin = ieParamFormat(varargin);
p.parse(wvfP,pType,varargin{:});

unit   = p.Results.unit;
wave   = p.Results.wave;
pRange = p.Results.plotrange;
window = p.Results.window;
airydisk = p.Results.airydisk;

% Wave list is whatever the wvf has
if isempty(wave), wave  = wvfGet(wvfP,'wave'); end 

% Something gets normalized.
normalizeFlag = contains(pType, 'normalized');

% Return defaults
uData = [];
fighdl  = [];

% Control the window
if islogical(window) && ~window
    fighdl = [];
elseif (isa(window,'matlab.ui.Figure') || isa(window,'matlab.graphics.layout.TiledChartLayout'))
    figure(window);
elseif isempty(window) || window
    fighdl = ieNewGraphWin;
end

%% Switch through the plots

switch(pType)
    
    case {'psfangle', '2dpsfangle', '2dpsfanglenormalized'}
        % wvfPlot(wvfP, '2d psf angle normalized', unit, ...
        %    waveIdx, plotRangeArcMin);
        samp = wvfGet(wvfP, 'psf angular samples', unit, wave);
        psf  = wvfGet(wvfP, 'psf', wave);
        
        % Extract within the range
        if ~isinf(pRange)
            index = (abs(samp) < pRange);
            samp = samp(index);
            psf = psf(index, index);
        end
        
        % Search for key word normalized
        if normalizeFlag
            psf = psf(index, index)/max(psf(:));
        end
        
        % Start the plotting
        pData = mesh(samp, samp, psf);
        s = sprintf('Angle (%s)', unit);
        xlabel(s); ylabel(s); zlabel('PSF amplitude')
        
        uData.x = samp; uData.y = samp; uData.z = psf;
        set(gcf, 'userdata', uData);
        
    case {'psf','psfnormalized'}
        
        samp = wvfGet(wvfP, 'psf spatial samples', unit, wave);
        psf  = wvfGet(wvfP, 'psf', wave);
        if normalizeFlag, psf = psf/max(psf(:)); end
        
        % Extract within the range
        if ~isinf(pRange)
            index = (abs(samp) < max(pRange));
            samp = samp(index);
            psf = psf(index, index);
        end
        
        pData = mesh(samp, samp, psf);
        s = sprintf('Position (%s)', unit);
        xlabel(s); ylabel(s); zlabel('Relative amplitude')
        
        uData.x = samp; uData.y = samp; uData.z = psf;
        set(gcf, 'userdata', uData);

        if airydisk
            % Draw a circle at the first zero crossing (Airy disk) of the
            % diffraction limited aperture.
            if numel(wave) > 1, thisWave = wave(1);
            else, thisWave = wave;
            end
            radius = airyDisk(thisWave,wvfGet(wvfP,'fnumber'),'units',unit);
            nCircleSamples = 200;
            [adX,adY,adZ] = ieShape('circle',nCircleSamples,radius);

            % Height of the Airy Disk ring.  Still experimenting.
            % Considering making this a parameter (BW).
            figure(gcf);hold on;
            ringZ = max(psf(:))*1e-3;
            p = plot3(adX,adY,adZ + ringZ,'k-'); set(p,'linewidth',5); 
            hold off;
            title(sprintf('F# %.1f Wave %d Airy Radius %.2f',wvfGet(wvfP,'fnumber'),wave, radius));
        else
            title(sprintf('F# %.1f Wave %d',wvfGet(wvfP,'fnumber'),wave));
        end

    case {'psfxaxis'}
        % wvfPlot(wvfP,'psf xaxis','unit',unit,'wave',wave,'p range',plotRange)
        % wvfPlot(wvf,'psf xaxis','unit','um','wave',550,'prange',20)

        psf  = wvfGet(wvfP,'psf',wave);
        samp = wvfGet(wvfP,'psf spatial samples',unit,wave);

        % X axis
        lineData = interp2(samp,samp,psf,0,samp);
        radius = airyDisk(wave,wvfGet(wvfP,'fnumber'),'units','um','diameter',false);
        plot(samp,lineData,'ko-'); hold on; 
        plot([-radius, radius],[0 0],'ro');
        grid on; set(gca,'xlim',[-pRange pRange]);
   
        uData.samp = samp; uData.psf = lineData; uData.wave = wave;
        if ~isempty(fighdl)
            title(sprintf('PSF x-axis (Wave %d).',wave));
        end

    case {'psfyaxis'}
        % wvfPlot(wvfP,'psf yaxis',unit,wave,plotRange)
        % wvfPlot(wvf,'psf yaxis','um',550,20)

        psf  = wvfGet(wvfP,'psf',wave);
        samp = wvfGet(wvfP,'psf spatial samples',unit,wave);

        % X axis
        lineData = interp2(samp,samp,psf,samp,0);
        radius = airyDisk(wave,wvfGet(wvfP,'fnumber'),'units','um','diameter',false);
        plot(samp,lineData,'ko-'); hold on; 
        plot([-radius, radius],[0 0],'ro');
        grid on; set(gca,'xlim',[-pRange pRange]);
        
        uData.samp = samp; uData.psf = lineData; uData.wave = wave;
        if ~isempty(fighdl)
            title(sprintf('PSF y-axis (Wave %d).',wave));
        end

    case {'imagepsf', 'imagepsfnormalized'}
        % wvfPlot(wvfP, 'image psf space', unit, waveIdx, plotRangeArcMin);
        samp = wvfGet(wvfP, 'psf spatial samples', unit, wave);
        psf  = wvfGet(wvfP, 'psf', wave);
        % If the string contains normalized
        if normalizeFlag
            psf = psf / max(psf(:));
        end
        
        % Extract within the range
        if ~isinf(pRange)
            index = (abs(samp) < pRange);
            samp = samp(index);
            psf = psf(index, index);
        end
        
        % Put up the image
        pData = imagesc(samp, samp, psf);
        colormap(hot(64)); axis image; grid(gca, 'on');
        set(gca, 'xcolor', [.5 .5 .5]);
        set(gca, 'ycolor', [.5 .5 .5]);
        s = sprintf('Position (%s)', unit);
        xlabel(s); ylabel(s); title('Relative amplitude')
        
        % Save the data
        uData.x = samp; uData.y = samp; uData.z = psf;
        set(gcf, 'userdata', uData);
        
    case {'imagepsfangle'}
        % wvfPlot(wvfP, 'image psf angle', unit, waveIdx, plotRangeArcMin);
        samp = wvfGet(wvfP, 'psf angular samples', unit, wave);
        psf = wvfGet(wvfP, 'psf', wave);
        % If the string contains normalized
        if normalizeFlag
            psf = psf / max(psf(:));
        end
        
        % Extract within the range
        if ~isinf(pRange)
            index = (abs(samp) < pRange);
            samp = samp(index);
            psf = psf(index, index);
        end
        
        % Put up the image
        pData =  imagesc(samp, samp, psf);
        colormap(hot(64)); axis image; grid(gca, 'on');
        set(gca, 'xcolor', [.5 .5 .5]);
        set(gca, 'ycolor', [.5 .5 .5]);
        s = sprintf('Position (%s)', unit);
        xlabel(s); ylabel(s); title('Relative amplitude')
        
        % Save the data
        uData.x = samp; uData.y = samp; uData.z = psf;
        set(gcf, 'userdata', uData);
        
        
    case {'1dpsf', '1dpsfspace', '1dpsfnormalized'}
        % wvfPlot(wvfP, '1d psf normalized', waveIdx, plotRangeArcMin);
        psfLine = wvfGet(wvfP, '1d psf', wave);
        if normalizeFlag
            psfLine = psfLine / max(psfLine(:));
        end
        
        samp = wvfGet(wvfP, 'psf spatial samples', unit, wave);
        
        % Make a plot through of the returned PSF in the central region.
        if ~isinf(pRange)
            index = find(abs(samp) < pRange);
            samp = samp(index);
            psfLine = psfLine(index);
        end
        
        pData = plot(samp, psfLine,'LineWidth', 2);
        s = sprintf('Position (%s)', unit);
        xlabel(s); ylabel('PSF slice'); grid on;
        
        % Store the data
        uData.x = samp; uData.y = psfLine;
        set(gcf, 'userdata', uData);
        
    case { '1dpsfangle', '1dpsfanglenormalized'}
        % wvfPlot(wvfP, '1d psf angle', unit, waveIdx, plotRangeArcMin);
        
        psfLine = wvfGet(wvfP, '1d psf', wave);
        samp = wvfGet(wvfP, 'psf angular samples', unit, wave);
        
        % Make a plot through of the returned PSF in the central region.
        index = find(abs(samp) < pRange);
        samp = samp(index);
        psfLine = psfLine(index);
        if normalizeFlag
            psfLine = psfLine / max(psfLine(:));
        end
        
        pData = plot(samp, psfLine, 'r', 'LineWidth', 4);
        str = sprintf('Angle (%s)', unit);
        xlabel(str); ylabel('PSF slice');
        
        % Store the data
        uData.x = samp; uData.y = psfLine;
        set(gcf, 'userdata', uData);
        
        
    case {'2dotf', 'otfspace', 'otf'}
        % wvfPlot(wvfP, '2d otf', unit, waveIdx, plotRangeFreq);
        % wvfPlot(wvfP, '2d otf', 'mm', 2, []);
        
        % Get the data and if the string contains normalized ...
        psf = wvfGet(wvfP, 'psf', wave);
        if normalizeFlag
            warning('Normalized otf plotted.')
            psf = psf / max(psf(:));
        end
        
        freq = wvfGet(wvfP, 'otf support', unit, wave);
        % This is how we calculate the frequency
        %
        % samp = wvfGet(wvfP, 'samples space', unit, wList);
        % nSamp = length(samp);
        % dx = samp(2) - samp(1);
        % nyquistF = 1 / (2 * dx);   % Line pairs (cycles) per unit space
        % freq = unitFrequencyList(nSamp) * nyquistF;
        %
        
        % Compute OTF, with DC at center for visualazation.  Not entirely
        % clear why we don't simply get the otf from the wvf structure
        % using wvfGet, shift to zero center using fftshift, and plot that.
        % [~,~,otf] = PsfToOtf([],[],psf);
        otf  = fftshift(fft2(ifftshift(psf)));  % Key line from PTB
        
        % Restrict to parameter range
        if ~isinf(pRange)
            index = (abs(freq) < pRange);
            freq = freq(index);
            otf = otf(index, index);
        end
        
        % Axes, labeling, store data
        % ieNewGraphWin;
        mesh(freq, freq, abs(otf))
        str = sprintf('Freq (lines/%s)', unit);
        xlabel(str); ylabel(str); title(sprintf('OTF %.0f', wave));
        uData.fx = freq; uData.fy = freq; uData.otf = abs(otf);
        set(gcf, 'userdata', uData);
        % set(gca,'ylim',[0 1.2]);
        
    case {'1dotf','1dotfspace'}
        % Plot the positive frequency part of a slice through the 2D
        % OTF.
        % Get the data and if the string contains normalized ...
        psf = wvfGet(wvfP, 'psf', wave);
        if normalizeFlag
            psf = psf / max(psf(:));
        end
        
        freq = wvfGet(wvfP, 'otf support', unit, wave);
        % samp = wvfGet(wvfP, 'samples space', unit, wList);
        % nSamp = length(samp);
        % dx = samp(2) - samp(1);
        % nyquistF = 1 / (2 * dx);   % Line pairs (cycles) per unit space
        % freq = unitFrequencyList(nSamp) * nyquistF;
        
        % Compute OTF, with DC at center for visualazation.  Not entirely
        % clear why we don't simply get the otf from the wvf structure
        % using wvfGet, shift to zero center using fftshift, and plot that.
        % [~,~,otf] = PsfToOtf([],[],psf);
        otf = fftshift(fft2(ifftshift(psf)));  % Key line from PTB

        % Restrict to parameter range
        if ~isinf(pRange)
            index = (abs(freq) < pRange);
            freq = freq(index);
            otf = otf(index, index);
        end
        
        % Axes, labeling, store data
        % ieNewGraphWin;
        middleRow = (freq == 0);
        positiveCols = (freq >= 0);
        plot(freq(positiveCols), abs(otf(middleRow,positiveCols)));
        
        str = sprintf('Freq (lines/%s)', unit);
        xlabel(str); ylabel(str);
        grid on
        title(sprintf('OTF %.0f', wave));
        uData.fx = freq; uData.fy = freq; uData.otf = abs(otf);
        set(gcf, 'userdata', uData);
        set(gca,'ylim',[0 1.2]);
        
    case {'1dotfangle'}
        % wvfPlot(wvf0, '1d otf angle', 'deg', wave, 10)
        % Plot the positive frequency part of a slice through the 2D
        % OTF.

        % Get the data and if the string contains normalized ...
        psf = wvfGet(wvfP, 'psf', wave);
        if normalizeFlag
            psf = psf / max(psf(:));
        end
        
        freq = wvfGet(wvfP, 'otf support', unit, wave);
        % samp = wvfGet(wvfP, 'samples space', unit, wList);
        % nSamp = length(samp);
        % dx = samp(2) - samp(1);
        % nyquistF = 1 / (2 * dx);   % Line pairs (cycles) per unit space
        % freq = unitFrequencyList(nSamp) * nyquistF;
        
        % Compute OTF, with DC at center for visualazation.  Not entirely
        % clear why we don't simply get the otf from the wvf structure
        % using wvfGet, shift to zero center using fftshift, and plot that.
        % [~,~,otf] = PsfToOtf([],[],psf);
        otf = fftshift(fft2(ifftshift(psf)));  % Key line from PTB

        % Restrict to parameter range
        if ~isinf(pRange)
            index = (abs(freq) < pRange);
            freq = freq(index);
            otf = otf(index, index);
        end
        
        % This is a small angle linear approximation.  We could try to
        % find the spacing that is a bit uneven, but that would also
        % be a problem for interpreting the harmonics over any
        % distance.
        %
        % To change from cycles/space to cycles/deg we multiply
        % freq * space/deg = freq / (deg/space)
        
        % Axes, labeling, store data
        % ieNewGraphWin;
        middleRow = (freq == 0);
        positiveCols = (freq >= 0);
        plot(freq(positiveCols), abs(otf(middleRow,positiveCols)));
        
        str = sprintf('Freq (lines/deg)');
        xlabel(str); ylabel(str); grid on
        title(sprintf('1D OTF %.0f', wave));
        uData.fx = freq; uData.fy = freq; uData.otf = abs(otf);
        set(gcf, 'userdata', uData);
        set(gca,'ylim',[0 1.2]);
        
    case {'imagepupilamp', 'imagepupilamplitude','imagepupilampspace', '2dpupilamplitudespace'}
        % wvfPlot(wvfP, '2d pupil amplitude space', 'mm', pRange)
        % plots the 2d pupil function amplitude for calculated pupil
        % Things to fix
        %  1. code in other plotting scales (distances or angles)

        samp = wvfGet(wvfP, 'pupil spatial samples', unit, wave);
        pupilfunc = wvfGet(wvfP, 'pupil function', wave);
        
        % Extract within the range
        if ~isinf(pRange)
            index = (abs(samp) < pRange);
            samp = samp(index);
            pupilfunc = pupilfunc(index, index);
        end
        
        pData = imagesc(samp, samp, abs(pupilfunc), ...
            [0 max(abs(pupilfunc(:)))]);
        s = sprintf('Position (%s)', unit);
        % this is a placeholder, need to fix with actual units?
        xlabel(s); ylabel(s); zlabel('Amplitude');
        title('Pupil Function Amplitude');
        colorbar; axis image;
        uData.x = samp; uData.y = samp; uData.z = abs(pupilfunc);
        set(gcf, 'userdata', uData);
        
    case {'imagepupilphase', '2dpupilphasespace'}
        % plots the 2d pupil function PHASE for calculated pupil
        % wvfPlot(wvfP, '2d pupil phase space', 'mm', pRange)
        %
        % Some things to potentially fix:
        % 1. modify colormap so that periodicity of phase is accounted for.
        % 2. code in other plotting scales (distances or angles)
        % 3. confirm plotting: currently 90deg flipped of wikipedia
        % 4. somehow remove the 0 phase areas outside of calculated pupil
       
        samp = wvfGet(wvfP, 'pupil spatial samples', unit, wave);
        pupilfunc = wvfGet(wvfP, 'pupil function', wave);
        
        % Extract within the range
        if ~isinf(pRange)
            index = (abs(samp) < pRange);
            samp = samp(index);
            pupilfunc = pupilfunc(index, index);
        end
        
        pData = imagesc(samp, samp, angle(pupilfunc), [-pi pi]);
        s = sprintf('Position (%s)', unit);

        % this is a placeholder, need to fix with actual units?
        xlabel(s); ylabel(s); zlabel('Phase');
        title('Pupil Function Phase');
        colormap('gray'); colorbar; axis image;
        uData.x = samp; uData.y = samp; uData.z = angle(pupilfunc);
        set(gcf, 'userdata', uData);
        
    case {'imagewavefrontaberrations', '2dwavefrontaberrationsspace'}
        % wvfPlot(wvfP, '2d pwavefront aberrationsspace space', ...
        %    'mm', pRange)
        % plots - 2d wavefront aberrations in microns for calculated pupil
        
        samp = wvfGet(wvfP, 'pupil spatial samples', unit, wave);
        wavefront = wvfGet(wvfP, 'wavefront aberrations', wave);
        
        % Extract within the range
        if ~isinf(pRange)
            index = (abs(samp) < pRange);
            samp = samp(index);
            wavefront = wavefront(index, index);
        end
        
        clim = [-max(abs(wavefront(:))) max(abs(wavefront(:)))];
        if clim(2) <= clim(1), clim(2) = Inf; end
        pData = imagesc(samp, samp, wavefront,clim);
        s = sprintf('Position (%s)', unit);
        xlabel(s); ylabel(s); zlabel('Amplitude');
        title('Wavefront Aberrations (microns)');
        colormap('gray'); colorbar; axis image;
        uData.x = samp; uData.y = samp; uData.z = wavefront;
        set(gcf, 'userdata', uData);
        
    otherwise
        error('Unknown plot type %s\n', pType);
end

end

% %%% - Interpret the plotting arguments
% function [units, wList, pRange] = wvfReadArg(wvfP, theseArgs)
% % Interpret the plotting arguments
% %
% % Syntax:
% %   [units, wList, pRange] = wvfReadArg(wvfP, [theseArgs])
% %
% % Description:
% %    The idea is to read the varargin in the wvfPlot call.
% %    These are usually unit, wave, plotRange, showPlot
% %    But, it may be that we have only unit, wave, showPlot.
% %    So, we trap that case here.
% %
% % Inputs:
% %    wvfP      - wavefront structure
% %    theseArgs - varagin, by another name
% %
% % Outputs:
% %    units     - Varying unit measurements (Default 'min' for angle and
% %                'mm' for space.
% %                Angle units are 'sec', 'min', or 'deg'     default - 'min'
% %                Space units are 'm', 'cm', 'mm', 'um'      default - 'mm'
% %    wList     - wavelength(s)
% %    pRange    - plot Range
% %
% % Notes:
% %    * [Note: BW - Really, this is all BS. We should have parameter, value
% %      pairs and stop this craziness.]
% 
% % Units
% if ~isempty(theseArgs), units = theseArgs{1};
% else,                   units = 'min';
% end
% 
% % Wavelength list
% if length(theseArgs) > 1, wList = theseArgs{2};
% else,                     wList = [];
% end
% 
% if isempty(wList)
%     wList = wvfGet(wvfP, 'wave');
%     if length(wList) > 1
%         warning('WVF:wList', 'Using 1st wave %d\n', wList(1));
%         wList = wList(1);
%     end
% end
% 
% % Plot range
% if length(theseArgs) > 2 && isnumeric(theseArgs{3})
%     % Make sure the final argument is not 'no window' or a string. If it
%     % is numeric, then set it to the plot range. Plot range is a 2-vector
%     % of min, max values.
%     pRange = theseArgs{3};
% else
%     pRange = Inf;
% end
% end
