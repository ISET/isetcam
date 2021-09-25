function [photons, illuminant, basis, comment, mcCOEF] = vcReadImage(fullname,imageType,varargin)
% Read image monochrome, rgb, or multispectral data, return multispectral
% photons
%
%   [photons, illuminant, basis, comment, mcCOEF ] = ...
%             vcReadImage(fullname,imageType,varargin)
%
% The image data in fullname are converted into photons.  The other
% parameters can be returned if needed.  This routine is called pretty much
% only by sceneFromFile.
%
% There are several different image file types. This program tries to
% determine the type from the file name.  If that fails, the user is
% queried.
%
% INPUTS
%  fullname:  Either a file name or possible RGB data read from a file
%             An empty input filename produces a return, with no error
%             message, to work smoothly with canceling vcSelectImage.
%
%  imageType: The type of input data.  There are two general types
%
%   'rgb','unispectral','monochrome':
%     In this case, varargin{1} can be either
%       * file name to a display (displayCreate) structure
%       * the display structure itself.
%     In that case, the data in the RGB or other format are returned as
%     photons estimated by putting the data into the display framebuffer.
%
%     If there is no display calibration file, we arrange the values so
%     that the display code returns the same RGB values as in the original
%     file.
%     In 'rgb' case, varargin{2} is used as doSub flag. If true, the input
%     image will be converted to subpixel rendered image. The conversion is
%     done by replacing each pixel with the subpixel structure of the
%     display. See displayCompute for details of this conversion. By
%     default, doSub is set to False. Note that, for large image, turning
%     on doSub could be extremely slow.
%
%   'multispectral','hyperspectral': In this case the data are stored as
%     coefficients and basis functions. We build the spectral
%     representation here. These, along with a comment and measurement of
%     the scene illuminant (usually measured using a PhotoResearch PR-650
%     spectral radiometer) can be returned.
%
% RETURNS
%  photons:     RGB format of photon data (r,c,w)
%  illuminant:  An illuminant structure
%  basis:       Structure containing basis functions for multispectral SPD
%  comment:
%  mcCOEF:      Coefficients for basis functions for multispectral SPD
%
% Examples:
%
%   See v_displayLUT.m for example calls.
%
% See also
%   sceneFromFile
%

%%
if notDefined('imageType'), imageType = 'rgb'; end
if notDefined('fullname')
    [fullname,imageType] = vcSelectImage(imageType);
end

if isempty(fullname), photons = []; return; end

% These are loaded for a file, when they are returned.
mcCOEF = []; comment = '';

imageType = ieParamFormat(imageType);

switch lower(imageType)
    
    case {'rgb','unispectral','monochrome'}
        if isempty(varargin) || isempty(varargin{1}), dispCal = [];
        else, dispCal = varargin{1};
        end
        
        % doSub indicates whether or not to use subpixel rendering
        % techniques
        if length(varargin) > 1, doSub = varargin{2};
        else, doSub = false;
        end
        
        % if we do subpixle rendering, the user could specify how many
        % samples per dixel to be used in scene generation
        if length(varargin) > 2, sz = varargin{3};
        else, sz = [];
        end
        
        % Programming Note (HJ):
        %   scene rendered without subpixel (doSub=false) could be
        %   different from the one rendered with subpixel of size [m n]
        %   where m and n indicates the number of pixels per dixel in row
        %   and columns. This kind of inconsistancy will occur especially
        %   when pixels per dixel is not [1 1].
        %
        %   To be more accurate, please turn off subpixel rendering if the
        %   samples per dixel gets very small.
        %
        % (HJ)
        
        % Read the image data and convert them to double
        if ischar(fullname), inImg = double(imread(fullname));
        else,                inImg = double(fullname);
        end
        
        % An rgb image.
        if isempty(dispCal)
            if ismatrix(inImg), inImg = repmat(inImg, [1 1 3]); end
            if ndims(inImg) ~= 3
                error('Bad number of dimensions %.0f of image',ndims(img));
            end
            % If there is no display calibration file, we arrange the
            % photon values so that the scene window shows the same RGB
            % values as in the original file.
            %
            
            % fprintf('[%s]: Assuming input data is 8 bit\n', mfilename);
            fprintf('[%s]: Using block matrix primaries\n', mfilename);
            [xwImg,r,c,~] = RGB2XWFormat(inImg/255);
            
            % Prevent DR > 10,000.  See ieCompressData.
            xwImg = ieClip(xwImg,1e-3,1);
            
            % When we render the RGB data in xwImg, they are multipled
            % by the colorBlockMatrix.  By storing the photons this
            % way, the displayed image in the scene window will be the
            % same as the original RGB image.
            photons = xwImg*pinv(colorBlockMatrix(31));
            
        else
            % The user sent a display calibration file. If the user
            % sent a string, read the file.  If the user sent in the
            % display structure, set it.
            if ischar(dispCal)
                d = displayCreate(dispCal);
            elseif isstruct(dispCal) && isequal(dispCal.type, 'display')
                d = dispCal;
            else
                error('Unknown display structure');
            end
            
            % Get the parameters from the display
            wave   = displayGet(d, 'wave');  % Primary wavelengths
            gTable = displayGet(d, 'gamma table');
            
            nprimaries = displayGet(d, 'n primaries');
            if ismatrix(inImg)
                inImg = repmat(inImg, [1 1 nprimaries]);
            end
            
            % pad third dimension of inImg to nprimaries
            % we pad 0 here because in most cases, the primary missing in
            % the inImg is black
            inImg = padarray(inImg, ...
                [0 0 nprimaries-size(inImg,3)], 0, 'post');
            assert(size(inImg, 3)==nprimaries, 'bad image size');
            
            % Check whether the gTable has enough entries for this
            % image.
            if max(inImg(:)) > size(gTable,1)
                imgMax = max(inImg(:));
                nbits = floor(log2(imgMax));
                warning('Input data (%d bits) exceeds gTable (%d bits)',...
                    nbits,log2(size(gTable,1)));
                % Scale the image data to the range of the display
                % gamma.  First scale to a max of 1, and then scale to
                % the digital value range.
                if nbits     >= 14, maxDisplay = 2^16;
                elseif nbits >= 12, maxDisplay = 2^14;
                elseif nbits >= 10, maxDisplay = 2^12;
                elseif nbits >= 8,  maxDisplay = 2^10;
                end
                
                % Resize gTable to match image bits.
                x_in = (0:1:size(gTable,1)-1) ./ 255;
                y_in = gTable;
                x_out = (0:1:2^(nbits+1)-1) ./ (2^(nbits+1)-1);
                gTable = interp1(x_in, y_in, x_out, 'spline');
                
                % Stretch image to match size of gamma table.
                % This probably isn't necessary
                inImg = inImg/imgMax;
                inImg = round(inImg*(size(gTable,1)-1));
            elseif max(inImg(:)) <= 1
                % DAC values are [0, 2^nBits - 1]
                inImg = round(inImg*(size(gTable,1)-1));
            elseif max(inImg(:)) <= 255
                % We believe this is an 8 bit image.  We check whether
                % the gTable is 8 or 10 or whatever.  If it is not 8
                % bit, then we stretch the image values out to span the
                % same range as the gTable.
                s = size(gTable,1);
                if s > 256
                    % fprintf('[%s] Assuming 8 bit image and %d bit LUT\n',...
                    %          mfilename,log2(s));
                    inImg = round(inImg/255*(s-1));
                end
            end
            
            % Convert the DAC values to linear intensities for the
            % channels.
            inImg  = ieLUTDigital(inImg,gTable);
            
            % Subpixel rendering
            if doSub
                inImg = displayCompute(d, inImg, sz);
            end
            spd = displayGet(d, 'spd');   % Primary SPD in energy
            
            [xwImg,r,c] = RGB2XWFormat(inImg);
            
            % Convert energy units to quanta
            % This step could be slow, espetially when we use sub-pixel
            % sampling
            if numel(xwImg) < ieSessionGet('image size threshold') ...
                    || ~ieSessionGet('waitBar') % small image
                % compute directly
                photons = Energy2Quanta(wave,(xwImg * spd')')';
            else
                % now we have too many pixels, loop over wavelength and
                % print the progress
                wBar = waitbar(0, 'Computing radiance of scene');
                photons = zeros(size(xwImg, 1), length(wave));
                for ii = 1 : length(wave)
                    photons(:, ii) = Energy2Quanta(wave(ii), ...
                        (xwImg * spd(ii,:)')')';
                    waitbar(ii/length(wave), wBar);
                end
                delete(wBar);
            end
        end
        photons = XW2RGBFormat(photons,r,c);
        
    case {'multispectral','hyperspectral'}
        
        % These are always there.  Illuminant should be there, too.  But
        % sometimes it isn't, so we check below, separately.
        
        % See if the representation is a linear model with basis functions
        variables = whos('-file',fullname);
        if ieVarInFile(variables,'mcCOEF')
            disp('Reading multispectral data with mcCOEF.')
            
            % The data are stored using a linear model
            load(fullname, 'mcCOEF', 'basis', 'comment');
            
            % Resample basis functions to the user specified wavelength
            % list.  vcReadImage(fullname,'multispectral',[400:20:800]);
            if ~isempty(varargin) && ~isempty(varargin{1})
                oldWave    = basis.wave;
                newWave    = varargin{1};
                nBases     = size(basis.basis,2);
                extrapVal  = 0;
                newBases   = zeros(length(newWave),nBases);
                for ii=1:nBases
                    newBases(:,ii) = interp1(oldWave(:), basis.basis(:,ii), newWave(:),'linear',extrapVal);
                end
                basis.basis = newBases;
                basis.wave = newWave;
            end
            
            % The image data should be in units of photons
            photons = imageLinearTransform(mcCOEF,basis.basis');
            % vcNewGraphWin; imageSPD(photons,basis.wave);
            
            % These lines are left in because there must be different file
            % types out there somewhere.  Sometimes we stored the mean, and
            % sometimes we didn't.
            if ieVarInFile(variables,'imgMean')
                disp('Saved using principal component method');
                load(fullname,'imgMean')
                
                % Resample the image mean to the specified wavelength list
                if ~isempty(varargin)&& ~isempty(varargin{1})
                    extrapVal  = 0;
                    imgMean = interp1(oldWave(:), imgMean(:), newWave(:),'linear',extrapVal);
                end
                
                % Sometimes we run out of memory here.  So we should have a
                % try/catch sequence.
                %
                % The saved function was calculated using principal components,
                % not just the SVD.  Hence, the mean is stored and we must add
                % it into the computed image.
                [photons,r,c] = RGB2XWFormat(photons);
                try
                    photons = repmat(imgMean(:),1,r*c) + photons';
                catch ME
                    % Probably a memory error. Try with single precision.
                    if strcmp(ME.identifier,'MATLAB:nomem')
                        photons = repmat(single(imgMean(:)),1,r*c) + single(photons');
                    else
                        ME.identifier
                    end
                end
                
                photons = double(XW2RGBFormat(photons',r,c));
                % figure(1); imagesc(sum(img,3)); axis image; colormap(gray(64))
                
            else
                disp('Saved using svd method');
            end
            
            % Deal with the illuminant
            if ieVarInFile(variables,'illuminant')
                load(fullname,'illuminant') %#ok<NASGU>
            else
                % illuminant = [];
                warndlg('No illuminant information in %s\n',fullname);
            end
            
            % Force photons to be positive
            photons = max(photons,0);
            
        else
            % The variable photons should be stored, there is no linear
            % model. We fill the basis slots.  Also, we allow the photons
            % to be stored in 'photons' or 'data'.  We allow the wavelength
            % to be stored in 'wave' or 'wavelength'.  Ask Joyce why.
            disp('Reading multispectral data with raw data.')
            
            % Make this function.
            % [photons,basis] = ieReadMultispectralRaw(fullname);
            
            if ieVarInFile(variables,'photons'), load(fullname,'photons');
            elseif ieVarInFile(variables,'data')
                load(fullname,'data'); photons = data; clear data;
            else, error('No photon data in file');
            end
            if ieVarInFile(variables,'comment'),  load(fullname,'comment'); end
            if ieVarInFile(variables,'wave'), load(fullname,'wave');
            elseif ieVarInFile(variables,'wavelength')
                load(fullname,'wavelength');
                wave = wavelength; clear wavelength;
            end
            
            % Pull out the photons
            if ~isempty(varargin) && ~isempty(varargin{1})
                newWave = varargin{1};
                perfect = 0;
                idx = ieFindWaveIndex(wave,varargin{1},perfect);
                photons = photons(:,:,idx);
                wave = newWave;
                % oldWave = wave;
                % wave = newWave;
            end
            basis.basis = []; basis.wave = round(wave);
        end
        
        % For linear model or no linear model, either way, we try to find
        % illuminant and resample.
        illuminant = [];
        if ieVarInFile(variables,'illuminant'), load(fullname,'illuminant')
        else,         warndlg('No illuminant information in %s\n',fullname);
        end
        illuminant = illuminantModernize(illuminant);
        
        % Resample the illuminant to the specified wavelength list
        if ~isempty(varargin)&& ~isempty(varargin{1})
            % Resample the illuminant wavelength to the new wave in the
            % call to this function.  This interpolates the illuminant
            % data, as well.
            illuminant = illuminantSet(illuminant,'wave',newWave(:));
        end
        
    otherwise
        fprintf('%s\n',imageType);
        error('Unknown image type.');
end

end
