function rtPlot(oi,dataType,varargin)
%Ray trace plotting gateway routine
%
%   rtPlot(oi,dataType,[roiFlag=0])
%
% Plot various ray trace functions including psf and otf and field
% height distortions.
%
%  {'psf'}                   -- point spread function mesh
%  {'psf550'}                -- point spread function mesh at 550 nm
%  {'psfimage'}              -- point spread function  array of images
%  {'relativeillumination'}  -- relative illumination mesh
%  {'distortion'}            -- geometric distortion mesh
%  {'distortionw'}           -- geometric distortion at a wavelength
%  {'otf550'}                -- OTF at 550 nm
%  {'psf movie'}             -- Movie of the PSF as a function of
%                               field height
%
%  {'ls550','linespreadfunction550','lsf500'}  -- Not yet implemented
%  {'lsfwavelength'}                           -- Not yet implemented
%
% The roiFlag options are not yet implemented.
%
% Copyright ImagEval Consultants, LLC, 2003.

% Examples:
%{
   oi = oiCreate('raytrace');
   rtPlot(oi,'psf550');
   rtPlot(oi,'psf',550,1);
   rtPlot(oi,'psf image');
   rtPlot(oi,'psf movie');
   rtPlot(oi,'distortion');
   rtPlot(oi,'distortionw',550);
   rtPlot(oi,'otf550');
   rtPlot(oi,'otf',550,0.5);
%}

%%
if ieNotDefined('oi'), oi = vcGetObject('opticalimage'); end
if ieNotDefined('dataType'), dataType = 'psf'; end

optics = oiGet(oi,'optics');
rt = opticsGet(optics,'rayTrace');
if isempty(rt)
    hndl = guihandles(ieSessionGet('oifigure'));
    ieInWindowMessage('No ray trace data in optics.',hndl); return;
end

figNum =  vcNewGraphWin;

% Put a good name in the figure title
opticsName = opticsGet(optics,'rtname');
if isempty(opticsName), opticsName = 'unnamed'; end
set(figNum,'name',opticsName);

%%
dataType = ieParamFormat(dataType);

switch lower(dataType)
    
    case {'psf','pointspread','psfsurfacegraph'}
        % rtPlot(oi,'psf',550,1);
        % Plotting parameters
        if length(varargin) < 2
            % Need the wavelength and field height in mm
            prompt={'Enter wavelength (nm)','Enter field height (mm)'};
            answer=inputdlg(prompt,'PSF properties',1,{'550','0'});
            if isempty(answer), disp('User canceled'); return;
            else
                w  = str2num(answer{1}); %#ok<*ST2NM>
                fh = str2num(answer{2});
            end
            % fa = 0;
        else
            w = varargin{1};
            fh = varargin{2};
        end
        
        optics = oiGet(oi,'optics');
        y = opticsGet(optics,'rtPsfSupportRow','um');
        x = opticsGet(optics,'rtPsfSupportCol','um');
        % Center the positions.
        x = x - mean(x(:)); y = y - mean(y(:));
        
        % Retrieve the PSF at wave and field height but no angle.  Why not
        % an angle?
        %
        PSF = rtPSFInterp(optics,fh,0,w);
        
        % Plot the PSF in units of microns
        mesh(y,x,PSF);
        xlabel('Position (microns)'); ylabel('Position (microns)');
        str = sprintf('PSF\nWave - %.0f nm\nField height - %.2f mm',w,fh);
        title(str);
        
        % Make available for user
        uData.xPos = x; uData.yPos = y;
        uData.PSF = PSF;
        set(gcf,'userdata',uData);
        
    case {'psfimage','psfimages','pointspreadimage'}
        % Need the wavelength and field height in mm
        prompt={'Enter wavelengths (nm)','Enter field heights (mm)'};
        answer=inputdlg(prompt,'PSF selections',1,{'450:50:600','0:0.5:2'});
        if isempty(answer), disp('User canceled'); return;
        else
            w  = str2num(answer{1});
            fh = str2num(answer{2});
        end
        
        optics = oiGet(oi,'optics');
        
        % Plot the PSF in units of microns
        % sSpacing = opticsGet(optics,'rtPsfSpacing','um');
        
        % Re-write using rtPsfSupportRow/Col
        psfSupportX = opticsGet(optics,'rtPsfSupportX','um');
        psfSupportY = opticsGet(optics,'rtPsfSupportY','um');
        
        % To change the number of grid points, change 4 to something else.
        xGrid = ieChooseTickMarks(psfSupportX,4);
        yGrid = ieChooseTickMarks(psfSupportY,4);
        
        count = 1;
        for ii=1:length(fh)
            for jj=1:length(w)
                PSF = rtPSFInterp(optics,fh(ii),0,w(jj));
                PSF = PSF/sum(PSF(:));
                subplot(length(fh),length(w),count)
                imagesc(psfSupportX,psfSupportY,PSF); axis image
                
                set(gca,'xcolor',[.5 .5 .5]);
                set(gca,'ycolor',[.5 .5 .5]);
                set(gca,'xtick',xGrid,'ytick',yGrid);
                grid on
                count = count + 1;
                title(sprintf('W: %.0f Hgt: %.2f',w(jj),fh(ii)));
            end
        end
        colormap(gray(256))
    case {'psfmovie'}
        % rtPlot(oi,'psf movie');
        rtPSFVisualize(oiGet(oi,'optics'));
        
    case {'otf','opticaltransferfunction'}
        % rtPlot(oi,'otf',550,0.5);
        if length(varargin) < 2
            % Need the wavelength and field height in mm
            prompt={'Enter wavelength (nm)','Enter field height (mm)'};
            answer=inputdlg(prompt,'PSF properties',1,{'550','0'});
            if isempty(answer), disp('User canceled'); return;
            else
                w  = str2num(answer{1}); %#ok<*ST2NM>
                fh = str2num(answer{2});
            end
        else
            w = varargin{1};
            fh = varargin{2};
        end
        
        % fa = 0;
        
        optics = oiGet(oi,'optics');
        xFreq = opticsGet(optics,'rtFreqSupportX','mm');
        yFreq = opticsGet(optics,'rtFreqSupportY','mm');
        
        % Retrieve the PSF at the center of the field (0 height and 0
        % angle)
        PSF = rtPSFInterp(optics,fh,0,w);
        
        OTF = abs(fftshift(fft2(PSF)));
        
        % Plot the OTF in units of cycles per millimeter
        mesh(xFreq,yFreq,OTF);
        xlabel('Frequency (c/mm)'); ylabel('Frequency (c/mm)');
        str = sprintf('OTF %.0f at %.1f mm',w,fh);   title(str);
        
        uData.xFreq = xFreq; uData.yFreq = yFreq;
        uData.OTF = OTF;
        set(gcf,'userdata',uData);
        
    case {'otf550','opticaltransferfunction550'}
        % rtPlot(oi,'otf550');
        optics = oiGet(oi,'optics');
        
        % Retrieve the PSF at the center of the field (0 height and 0
        % angle)
        PSF   = rtPSFInterp(optics,0,0,550);
        xFreq = opticsGet(optics,'rtFreqSupportX','mm');
        yFreq = opticsGet(optics,'rtFreqSupportY','mm');
        OTF = abs(fftshift(fft2(PSF)));
        
        % Plot the PSF in units of microns
        mesh(xFreq,yFreq,OTF);
        xlabel('Frequency (c/mm)'); ylabel('Frequency (c/mm)');
        str = sprintf('OTF 550nm at center');   title(str);
        
        % Store data in the window
        uData.xFreq = xFreq; uData.yFreq = yFreq;
        uData.OTF = OTF;
        set(gcf,'userdata',uData);
        
    case {'relativeillumination','ri','relillum'}
        % Only the wavelength
        waveList = opticsGet(optics,'rtriwavelength');
        riFH = opticsGet(optics,'rtrifieldheight','mm');
        
        % Relative illumination is ri(fieldHeight, wave)
        ri = opticsGet(optics,'rtrifunction','mm');
        
        % Odd that ri is (fh,wave) in row,col but the surf needs wave
        % by FH.  This is because surf(X,Y,Z), not
        % surf(row,col,height).
        surf(waveList,riFH,ri)
        xlabel('Wavelength (nm)');  ylabel('Distance (mm)');
        title('Relative illumination');
        
        % Store data in the window
        uData.wave = waveList; uData.fieldHeight = riFH;
        uData.relativeIllumination = ri;
        set(gcf,'userdata',uData);
        
    case {'distortion','di','distimght'}
        % At all wavelengths
        FH = opticsGet(optics,'rtgeomfieldheight','mm');
        waveList = opticsGet(optics,'rtgeomwavelength');
        diFH = opticsGet(optics,'rtgeomfunction',[],'mm');
        nWave = length(waveList);
        surf(waveList,FH,diFH - repmat(FH,1,nWave))
        xlabel('Wavelength (nm)');  ylabel('Field height (mm)');
        zlabel('Height distortion (mm)')
        title('Field distortion (mm)');
        
    case {'distortionw','diw','distimghtw'}
        if ~isempty(varargin)
            w = varargin{1};
        else % Only at one wavelength
            w = ieReadNumber('Enter wavelength (nm)',550,'%.0f');
        end
        FH = opticsGet(optics,'rtgeomfieldheight');
        % waveList = opticsGet(optics,'wave');
        diFH = opticsGet(optics,'rtgeomfunction',w);
        plot(FH,diFH - FH,'-x'); axis equal; grid on;
        xlabel('Geometric height (mm)');  ylabel('Distance (mm)');
        title(sprintf('Field distortion (mm) at %.0f',w));
        
    case {'psf550','pointspread550','ps550'}
        optics = oiGet(oi,'optics');
        % sSpacing = opticsGet(optics,'rtPsfSpacing','mm');   % Units of mm
        
        % Retrieve the PSF at the center of the field (0 height and 0
        % angle)
        PSF = rtPSFInterp(optics,0,0,550);
        x = opticsGet(optics,'rtPsfSupportCol','um');
        y = opticsGet(optics,'rtPsfSupportRow','um');
        x = x - mean(x(:)); y = y - mean(y(:));
        
        % Plot the PSF in units of microns
        mesh(y,x,PSF);
        xlabel('Position (microns)'); ylabel('Position (microns)');
        str = sprintf('PSF 550nm');   title(str);
        
    case {'ls550','linespreadfunction550','lsf500'}
        disp('Not yet implemented: ls550')
        
    case {'lswavelength','linespreadfunction','lsfwavelength'}
        disp('Not yet implemented: lswavelength')
        
    otherwise
        error('Unknown rtPlot option.')
end


end