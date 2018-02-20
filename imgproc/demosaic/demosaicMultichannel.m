function img = demosaicMultichannel(rgbFormat,sensor,method)
% Multichannel demosaicking; channels are processed separately
%
%  rgbFormat - CFA rgbFormat image format (from plane2rgb)
%  img    - interpolated image; each channel is interpolated separately
%  method - ether 'mean' (default), 'median' or kernelregression.
%
% The rgbFormat image format is an RGB style 3d-matrix in which many of the
% color plane entries are zero.  This routine fills the zero entries in the
% separate planes.
%
% The returned image has the same number of channels as the input. Hence,
% if the input is row x col x W the return is not yet an RGB image.  To
% convert the image to an RGB you must apply a subsequent transform that
% maps the multiple wave bands into RGB.
%
% Example:
%  img = demosaicMultichannel(rgbFormat,sensor,'mean')
%
% Copyright ImagEval Consultants, LLC, 2009.

if ieNotDefined('sensor'),    sensor = vcGetObject('sensor'); end
if ieNotDefined('method'),    method = 'mean'; end

% Initialize output matrix, img;
img = rgbFormat;   % row x col x nBands
[nRows,nCols,nBands] = size(rgbFormat);
[X,Y] = meshgrid(1:nCols,1:nRows);  % The output positions
jFactor = 10e-6;                    % Jiggle factor. See below for griddata

% Create a matrix that size of sensor, cfaN, where each entry indexes the
% color filter 
[cfa,cfaN] = sensorDetermineCFA(sensor);
% figure; image(cfaN); colormap(hsv);


% The first band in the img is from the first color filter.  It will have a
% value assigned to it from the sensorColorOrder.  So, if the first color
% filter is bXXX, the img(:,:,1) will be at locations marked by 3, because
% the 'b' is the third entry in sensorColorOrder.
% So here we find which number in sensorColorOrder is assigned to the
% several bands.  We need this information to get the right positions from
% the different image planes.

% Just commented  ....
% filterNames = sensorGet(sensor,'filterColorLetters');
% colorOrder  = sensorColorOrder('string');
% for ii=1:nBands
%     bandIdentifier(ii) = strfind(colorOrder,filterNames(ii));
% end

switch lower(method)
    
    case 'interpolate'
        % In this method, we treat the responses as being a set of (x,y,v)
        % that are not on the fullsampling grid.  We then use gridfit (or
        % ffndgrid) to create a regularly sampled set of values.
        showBar = ieSessionGet('waitbar');
        if showBar, wbar = waitbar(0,'Multichannel demosaicking'); end
        for band=1:nBands
            
            % Find the positions for this band
            [r,c] = find(cfaN == band); %figure(1); plot(r,c,'.')
            
            % If there are some points in this band ...
            nSamp = length(r);
            if nSamp > 0
                % The values for this band are in [r,c,img(r,c,band)]
                thisBand   = img(:,:,band);  
                % figure(1); imagesc(thisBand); colormap(gray(255))
                bandValues = thisBand(cfaN == band);
                % figure(1);hist(bandValues(:),50)

                % We interpolate the data.
                % This should be updated with a triScatteredInterp
                % Could do a try/catch for modern programming use.
                % griddata fail when (r,c) are very simple and uniformly
                % spaced. We jiggled the r,c to handle this case.  Perhaps
                % we should detect this and use interp2 in that case.
                if showBar, waitbar(band/nBands,wbar,sprintf('Band %.0f',band)); end
                img(:,:,band) = ...
                    griddata(c+randn(size(c))*jFactor,...
                             r+randn(size(r))*jFactor,...
                             bandValues,X,Y);
                         tmp = img(:,:,band);
                         tmp(isnan(tmp)) = 0; 
                         img(:,:,band) = tmp;
                         % figure(1); imagesc(img(:,:,band)); colormap(gray)
            end
            % imtool(img(:,:,band))
        end
        if showBar, close(wbar); end
    case 'mean'
        % Should probably be deleted here and in demosaicMultichannel
        % In this option, we replace the zeros with the local mean.
        for band=1:nBands
            for row = startRow:stopRow
                for col = startCol:stopCol
                    % This is an assumption about the layout ...
                    % We should use the data to get the layout, we
                    % shouldn't assume.
                    tmpRows = (row-floor(wSize/2)):(row+floor(wSize/2));
                    tmpCols = (col-floor(wSize/2)):(col+floor(wSize/2));
                    
                    % Data for this band,
                    tmp = rgbFormat(tmpRows,tmpCols,band);
                    if any(tmp)
                        % Replace the 0 values with the local average
                        img(row,col,band) = mean(tmp(tmp>0));
                    end
                end % row 
            end % column
        end % band
        
    case 'median'
        % Should probably be deleted here and in demosaicMultichannel
        % As above, but replaces local mean with local median
        for band=1:nBands
            for row = startRow:stopRow
                for col = startCol:stopCol
                    tmpRows = (row-floor(wSize/2)):(row+floor(wSize/2));
                    tmpCols = (col-floor(wSize/2)):(col+floor(wSize/2));
                    
                    tmp = rgbFormat(tmpRows,tmpCols,band);
                    if any(tmp)
                        img(row,col,band) = median(tmp(tmp>0));
                    end
                end % row
            end % column
        end % band
        
    case 'kernelregression'
        % Should probably be deleted here and in demosaicMultichannel
        % This is the complicated program MP liked from the Santa Cruz
        % research scientists.  Very slow.
        
        % Find CFA arrangement and create sampling masks for each color
        % channel. These masks are the size of the 2D sensor and have 1s
        % where a color was sampled and 0s everywhere else
        
        sensorSize = sensorGet(sensor,'size');
        nBands     = sensorGet(sensor,'nFilters');
        pattern    = sensorGet(sensor,'pattern');
        
        sRows = sensorSize(1);
        sCols = sensorSize(2);
        cRows = size(pattern,1);
        cCols = size(pattern,2);
        
        cfa = zeros(cRows,cCols,nBands);
        
        for ii = 1:cRows
            for jj = 1:cCols
                cfa(ii,jj,pattern(ii,jj)) = 1;
            end
        end
        
        showBar = ieSessionGet('waitbar');
        if showBar, hWait = waitbar(0,'');
            str = sprintf('Demosaicking channel 1 of %d',nBands);
            set(hWait,'Name',str);
        end
        for band = 1:nBands
            if showBar
                set(hWait,'Name',sprintf('Processing channel %d of %d',band,nBands));
            end
            % Find the sampling grid
            Sband = repmat(cfa(:,:,band),sRows/cRows,sCols/cCols);
            
            % Pilot estimation by second order classic kernel regression
            h     = 1;    % the global smoothing parameter
            ksize = 2*round(sqrt(0.1*min(sRows,sCols))) + 1; % kernel size
            [zc, zx1c, zx2c] = ckr2_irregular(...
                rgbFormat(:,:,band), Sband, h, ksize);
            
            % Obtain orientation information
            wsize  = max(cRows,cCols); % the size of local analysis window
            lambda = 1;   % the regularization for the elongation parameter
            alpha  = 0.1; % the structure sensitive parameter
            C = steering(zx1c, zx2c, Sband, wsize, lambda, alpha);
            
            img(:,:,band) = skr2_irregular(...
                rgbFormat(:,:,band), Sband, h, C, ksize);
            
            if showBar,  waitbar(band/nBands,hWait); end
        end
        if showBar, close(hWait); end
end 

% Clip any negative numbers.  Then scale so max is 1
img = ieScale(ieClip(img,0,[]),1);

end




