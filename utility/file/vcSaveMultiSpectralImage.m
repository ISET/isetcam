function fullName = vcSaveMultiSpectralImage(imgDir, fname, mcCOEF, basis, basisLights, illuminant, comment, imgMean)
%
%   fullName = vcSaveMultiSpectralImage(imgDir,fname,mcCOEF,basis,basisLights,illuminant,comment,imgMean)
%
%   Save a Matlab data file containing data for a multi-spectral image
%
%   coefficients (RGB format), basis functions, illuminant information and
%   a comment.
%   In addition, three summary files are created.  These are
%       (a) a tiff thumbnail of the image
%       (b) a tiff image showing a plot of the basis functions
%       (c) a tiff image showing a plot of the basisLights used to calculate the
%       basis functions
%       (d) should we make a plot of the scene illuminant SPD, too?
%
%   The full path to the data is returned in fullname.
%
%   The SPD of the data can be derived from the coefficients and basis
%   functions using:
%
%   spd = rgbLinearTransform(mcCOEF,basis');
%
%EXAMPLE:
%  mcSaveCoefAndBasis('c:\user\Matlab\data\Tungsten','MacbethChart-hdrs',mcCOEF,basis,basisLights,illuminant,comment)
%

if ieNotDefined('basis'), error('Basis function required.'); end
    if ~exist(imgDir, 'dir'), error('No such directory.'); end
    if ieNotDefined('comment'), warning('Empty comment.');
        comment = sprintf('Date: %s\n', date);
    end
    if ieNotDefined('basisLights'), warning('No light description');
        basisLights = [];
    end
    if ieNotDefined('illuminant'), warning('No illuminant data');
        illuminant = [];
    end

    if isempty(fname)
        [fname, imgDir] = uiputfile('*-hdrs.mat', 'Enter HDRS file name');
        if isequal(fname, 0) || isequal(imgDir, 0)
            fullName = [];
            disp('HDRS file write canceled.')
            return;
        end
    end
    fullName = fullfile(imgDir, fname);

    % Write out the matlab data file with all of the key information needed.
    % Sometimes we save out data approximated usingly on the SVD
    % Other times, we use a principal component method and have an image mean
    if ieNotDefined('imgMean')
        save(fullName, 'mcCOEF', 'basis', 'basisLights', 'illuminant', 'comment');
    else
        save(fullName, 'mcCOEF', 'basis', 'basisLights', 'illuminant', 'imgMean', 'comment');
    end

    return;
    %
    % % Write out a thumbnail, too, say we can browse them later and identify them.
    % thumbNail = ieScale(mcCOEF(:,:,1),0,1);
    % r = size(thumbNail,1);
    % sFactor = 128/r;
    % thumbNail = imResize(thumbNail,sFactor).^(0.5);
    % [p,n] = fileparts(fullName);
    % fullName = fullfile(p,[n,'.jpg']);
    % imwrite(thumbNail,fullName,'jpg');
    %
    % % Write out the basis functions
    % figNum = figure; set(figNum,'Visible','off')
    % plot(basis.wave,ieScale(basis.basis,1));
    % set(figNum,'pos',[ 528   608   300  230]);
    % set(gca,'xtick',(400:100:700),'fontsize',14);
    % xlabel('Wavelength (nm)')
    % ylabel('Photons (relative)');
    % title('Color Signal Basis');
    % grid on
    % fullName = fullfile(p,'basis.tiff');
    % print(figNum,'-dtiff','-r72',fullName);
    %
    % % Summary statistics about the processed image
    % photons = imageLinearTransform(mcCOEF,basis.basis');
    % [xwData, rows,cols,w] = RGB2XWFormat(photons);
    %
    % % Convert into luminance
    % luminance = ieLuminanceFromPhotons(xwData,basis.wave);
    %
    % % Summary of the statistics
    % dr = max(luminance(:))/min(luminance(:));
    % meanSPD = mean(xwData);
    %
    % clf
    % set(figNum,'pos',[ 528   608   300  230]);
    % plot(basis.wave,ieScale(meanSPD,1),'r-');
    % set(gca,'xtick',(400:100:700),'fontsize',14);
    % leg{1} = 'Mean SPD';
    %
    % % Write out the illuminant.
    % if ~isempty(basisLights)
    %     hold on;
    %     plot(basis.wave,ieScale(basisLights,1),'k:');
    %     leg{2} = 'Basis Light';
    % end
    % if ~isempty(illuminant)
    %     hold on;
    %     plot(illuminant.wavelength,ieScale(illuminant.data,1),'k--');
    %     leg{3} = 'Scene illuminant';
    % end
    % xlabel('Wavelength (nm)')
    % ylabel('Photons (relative)');
    % legend(leg);
    %
    % grid on
    % str = sprintf('DR:   %.0f',dr);
    % t = text(basis.wave(2),0.9,str);
    % set(t,'fontsize',14);
    % fullName = fullfile(p,'summary.tiff');
    % print(figNum,'-dtiff','-r72',fullName);
    % close(figNum);
    %
    % return;
