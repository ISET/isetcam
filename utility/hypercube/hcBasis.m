function [imgMean, basis, coef, varExplained] = hcBasis(hc,bType,mType)
% Create wavelength basis functions and coefficients for an hc image
%
% Synopsis
%  [imgMean, basis, coef, varExplained] = hcBasis(hc,cType,bType)
%
% Brief description
%   Approximate the hypercube of photon data with respect to a mean value,
%   basis functions, and per pixel coefficients.  The scene data can be
%   saved in this format to make the file much more compact.
%
% INPUTS
%  hc:    Hypercube data
%  bType: Basis calculation type
%           if < 1, a fraction specifying required variance explained
%           if >= 1, a number of bases 
%  mType:  Mean removal computation  
%           'mean svd'  - pull out the mean before the svd
%           'canonical' - leave the mean as part of the basis calculation (default)
%                         In this case imgMean is returned as empty.
%
% RETURNS
%  imgMean:   Mean SPD of all the pixels  (nWave,1)
%  basis:     Basis functions (.basis and .wave)
%  coef:      RGB format (row,col,nBases)
%  varExplained:  The variance explained by the basis approximation
%
% Description:
%   The hypercube image data (photons) are approximated using a set of
%   basis functions.  To reconstruct the photon data from the mean, basis
%   function and coefficients you can use this:
%
%     d = RGB2XWFormat(coef)*basis'+ repmat(imgMean,row*col,1);
%     hcimage(XW2RGBFormat(d,row,col));   % Show the iamge
%
% Copyright ImagEval Consultants, LLC, 2012.
%
% See also:  
%   hcimage, and hc<TAB>, s_sceneHCCompress, ieSaveMultiSpectralImage
%

%% Check arguments
if ieNotDefined('hc'), error('Hypercube data required'); end
if ieNotDefined('bType'), bType = 0.995; end
if ieNotDefined('mType'), mType = 'canonical'; end

% The basis methods are
%  1 - Return the mean in the first column and the svd basis in the 2nd
%  through higher components
%  2 -  When the image is large, we might sample points randomly and find a
%  best 'statistical' svd from these random samples
imgMean = [];

mType = ieParamFormat(mType);
switch mType
    case 'meansvd'
        % Suppose the original data are d, and they are stored in (wave x
        % space) format, in the transpose of XW.
        % d = wMean + hcBasis*hcCoefs;
        %
        % vcReadImage does this:
        %  tmp = load(fullname);
        %  mcCOEF = tmp.mcCOEF; basis = tmp.basis;
        %  photons = imageLinearTransform(mcCOEF,basis.basis');
        %
        % The imageLinearTransform routine applies a right side multiply to
        % the data.  Specifically, if an image point is represented by the
        % row vector, p = [R,G,B] the matrix transforms each color point,
        % p, to an output vector pT

        [row,col,~] = size(hc);
        % Convert so rows are space and columns are wavelength
        hc = RGB2XWFormat(hc);
        
        % Remove the mean
        imgMean = mean(hc,1);   % vcNewGraphWin; plot(imgMean)
        hc = hc - repmat(imgMean,row*col,1);
        %
        % Compute the svd.  hc = U * S * basis'
        [~, S, basis] = svd(hc,'econ');
        S = diag(S);
        relativeVariance = cumsum(S.^2)/sum(S.^2);
        
        % Find the number of bases to keep
        if bType < 1
            % Percent explained sent in
            nbases = find(relativeVariance > bType, 1 );
        elseif bType >= 1
            % Person just told us how many bases
            nbases = bType;
        end

        % Clip the unwanted basis terms
        basis = basis(:,1:nbases);
        % vcNewGraphWin; plot(basis(:,1:nbases))
        
        % Find the basis coefficients
        coef = hc*basis;
       
        % Have a look:   hcimage(XW2RGBFormat(d,row,col))
        
        % Make the coefficients an RGB image so we can use
        % imageLinearTransform in vcReadImage
        coef = XW2RGBFormat(coef,row,col);
        %
        % tmp = imageLinearTransform(coef,basis');
        % tmp = RGB2XWFormat(tmp);
        % tmp = tmp + repmat(imgMean,row*col,1);
        % tmp = XW2RGBFormat(tmp,row,col);
        % hcimage(tmp)
    case 'canonical'
        % Do not pull out the mean.  Just fit
        %  d = C*weights, where the columns of C are the basis functions.
        %  The first one will be pretty close to the mean.
        [row,col,~] = size(hc);
        % Convert so rows are space and columns are wavelength
        hc = RGB2XWFormat(hc);
        
        % Compute the svd.  hc = U * S * basis'
        [~, S, basis] = svd(hc,'econ');
        S = diag(S);
        relativeVariance = cumsum(S.^2)/sum(S.^2);
        
        % Find the number of bases to keep
        if bType < 1
            % Percent explained sent in
            nbases = find(relativeVariance > bType, 1 );
        elseif bType >= 1
            % Person just told us how many bases
            nbases = bType;
        end

        % Clip the unwanted basis terms
        basis = basis(:,1:nbases);
        % vcNewGraphWin; plot(basis(:,1:nbases))
        
        % Find the basis coefficients
        coef = hc*basis;
        % To get back to the original hc data
        %  d = coef*basis'+ repmat(imgMean,row*col,1);
        % Have a look:   hcimage(XW2RGBFormat(d,row,col))
        
        % Make the coefficients an RGB image so we can use
        % imageLinearTransform in vcReadImage
        coef = XW2RGBFormat(coef,row,col);
        
    otherwise
        error('Unknown method %s\n',mType);
end
varExplained = relativeVariance(nbases);

return