function [varExplained, nBases] = sceneToFile(fname,scene,bType,mType,comment)
% Write scene data in the hyperspectral and multispectralfile format
%
%   [varExplained,nBases] = sceneToFile(fname,scene,bType,mType,[comment])
%
% If the bFlag is empty, it saves a file containing photons, wave,
% illuminant structure and a comment.
%
% If the bFlag is a value (double), the function builds a linear model
% basis to represent (and compress) the photon data. It saves the linear
% model, model coefficients, illuminant structure, and a comment. The
% linear model format removes the mean of the photons, builds a linear
% model, and stores the mean, linear model, and coefficients for each
% pixel.
%
%Inputs
% fname:  The full name of the output file
% scene:  ISETBIO scene structure
% bType:  Basis calculation type
%         Empty  - No compression, just save photons, wave, comment,
%            illuminant
%         A value between 0 and 1 specifying the fraction of variance
%            explained by the linear model compression (default, 0.99)
%         An integer >= 1 specifies the number of basis functions
% mType:  Mean computation
%         Remove the mean ('meansvd') or not ('canonical', default) before
%         calculating svd 
% comment:  Optional, default is just the scene name
%
%Return
% varExplained - Fraction of variance explained by the linear model
% nBases       - Number of basis functions saved
%
%Examples:
%   scene = sceneCreate;
%   vcAddAndSelectObject(scene); sceneWindow;
%   sceneToFile('deleteMe',scene,0.999);
%   scene2 = sceneFromFile('deleteMe','multispectral');
%   vcAddAndSelectObject(scene2); sceneWindow;
%
%   sceneToFile('deleteMe',scene,[]);
%
% (c) Imageval Consulting, LLC 2013

% TODO:
%   Add depth image as potential output, not just dist

if ieNotDefined('fname'), error('Need output file name for now'); end
if ieNotDefined('scene'), error('scene structure required'); end
if ieNotDefined('bType'), bType = [];  end  % See hcBasis
if ieNotDefined('mType'), mType = 'mean svd';  end  % Remove the mean first
if ieNotDefined('comment'), comment = sprintf('Scene: %s',sceneGet(scene,'name')); end

% We need to save the key variables
photons    = sceneGet(scene,'photons');
wave       = sceneGet(scene,'wave');
illuminant = sceneGet(scene,'illuminant');
wAngular        = sceneGet(scene,'fov');
distance       = sceneGet(scene,'distance');
name       = sceneGet(scene,'name');

spectrum = sceneGet(scene, 'spectrum');
type     = sceneGet(scene, 'type');
magnification = sceneGet(scene, 'magnification');
data = sceneGet(scene, 'data'); 

if isempty(bType)
    % No compression.
    save(fname,'photons','wave','comment','illuminant','wAngular','distance','name',...
        'spectrum', 'type', 'magnification', 'data');
    varExplained = 1;
    nBases = length(wave);
else
    % Figure out the basis functions using hypercube computation
    photons = photons(1:3:end,1:3:end,:);
    [imgMean, basisData, ~, varExplained] = hcBasis(photons,bType,mType);
    clear photons;
    
    % Plot the basis functions
    %   wList = sceneGet(scene,'wave');
    %   vcNewGraphWin;
    %   for ii = 1:size(basisData,2)
    %       plot(wList,basisData(:,ii)); hold on
    %   end   
    
    photons           = sceneGet(scene,'photons');
    [photons,row,col] = RGB2XWFormat(photons);
    switch ieParamFormat(mType)
        case 'canonical'
            coef = photons*basisData;
            
        case 'meansvd'
            photons = photons - repmat(imgMean,row*col,1);
            coef = photons*basisData;
            
        otherwise
            error('Unknown mType: %s\n',mType);
    end
    coef = XW2RGBFormat(coef,row,col);

    % Save the coefficients and basis
    basis.basis = basisData;
    basis.wave  = wave;
    ieSaveMultiSpectralImage(fname,coef,basis,comment,imgMean,illuminant,fov,dist,name);
    nBases = size(coef,3);
end

end  % End function
