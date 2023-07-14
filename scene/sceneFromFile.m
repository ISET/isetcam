function scene = sceneFromFile(inputData, imType, meanLuminance, dispCal, ...
    wList, illEnergy, scaleReflectance)
% Create an ISETCam scene structure by reading data from a file
%
% Synopsis:
%
%   [scene, I] = sceneFromFile(inputData, imageType, [meanLuminance], ...
%                     [display], [wave],[illEnergy],[scaleReflectance])
%
% Input:
%  inputData: Typically, this is the name of an RGB image file.  But, it
%             may also be
%              * RGB data, rather than the file name
%              * A file that contains a scene structure
%  imageType: 'spectral', 'rgb' or 'monochrome'
%              When 'rgb', the imageData might be RGB format. 'spectral'
%              includes both multispectral and hyperspectral.
%  meanLuminance: If a value is sent in, set scene to this meanLuminance.
%                 If empty, do nothing.  Based on ISETBio. Until June
%                 2023, ISETCam used a different assumption (set it to
%                 100 if undefined).
%  dispCal:   A display structure used to convert RGB to spectral data.
%
%             For the typical case an emissive display the illuminant SPD is
%             modeled and set to the white point of the display.
%
%             displayCreate implements a special case (by default) we call
%             'reflectance-display'.  That display has the properties that
%             the RGB data are rendered under a D65 illuminant and the
%             surface reflectances fall within a 3D linear model of natural
%             surface reflectances.
%             Unusual cases:
%              (a) If sub-pixel modeling is required varargin{1} is set to
%                  true, (default is false)
%              (b) If a reflective display is modeled, the illuminant is
%                  required and passed in as varargin{2}
%  wList:     The scene wavelength samples
%  illEnergy: Use this as the illuminant energy.  It must have the
%             same wavelength sampling as wList.
%  scaleReflectance:  Adjust the illEnergy level so that the maximum
%             reflectance is 0.95.  Default: true:
%
% Optional key/val pairs
%   N/A
%
% Output;
%   scene:    The ISETCam scene structure
%
% Description
%  The data in the image file are converted into spectral format and placed
%  in an ISETcam scene data structure. The allowable imageTypes are
%  monochrome, rgb, multispectral and hyperspectral. If you do not specify
%  and we cannot infer, then you may be asked.
%
%  If the image is RGB format, you may specify a display calibration file
%  (dispCal). This file contains display calibration data that are used to
%  convert the RGB values into a spectral radiance image. If you do not
%  define the dispCal, the default display file 'lcdExample' will be used.
%
%  You may specify the wavelength sampling (wList) for the returned scene.
%
%  The default illuminant for an RGB file is the display white point.
%  The mean luminance can be set to over-ride this value.
%
% See examples
%   ieExamplesPrint('sceneFromFile');
%
% See also
%   vcSelectImage, ieImageType

% Examples:
%
%{
   scene = sceneFromFile;
   sceneWindow(scene);
%}
%{
   imgType = 'rgb'; meanLuminance = 10;
   fullFileName = vcSelectImage;
   scene = sceneFromFile(fullFileName,imgType,meanLuminance);
   sceneWindow(scene);
%}
%{
   wList = [400:50:700];
   fullFileName = fullfile(isetRootPath,'data','images', ...
                   'multispectral','StuffedAnimals_tungsten-hdrs');
   scene = sceneFromFile(fullFileName,'multispectral',[],[],wList);
   sceneWindow(scene);
%}
%{
   meanLuminance=[];
   dispCal = 'OLED-Sony.mat';
   fName = fullfile(isetRootPath,'data','images','rgb','eagle.jpg');
   wList = 400:10:700;
   scene = sceneFromFile(imread(fName),'rgb',100,dispCal,wList);
   sceneWindow(scene);
%}
%{
  meanLuminance= 10;
  thisDisplay = displayCreate;
  h = harmonicP('row',2048,'col',2048);
  img = imageHarmonic(h);
  img = floor(ieScale(img,0,255));
  scene = sceneFromFile(img,'monochrome',meanLuminance,thisDisplay,600);
  sceneWindow(scene);
%}
%{
%}

%% Parameter set up

if notDefined('illEnergy'), illEnergy = []; end
if notDefined('scaleReflectance'), scaleReflectance = true; end

if notDefined('inputData')
    % If imageData is not sent in, we ask the user for a filename.
    % The user may or may not have set the imageType.  Sigh.
    if notDefined('imType'), [inputData,imType] = vcSelectImage;
    else, inputData = vcSelectImage(imType);
    end
    if isempty(inputData), scene = []; return; end
end

if ischar(inputData)
    % I is a file name.  We determine whether it is a Matlab file and
    % contains a scene variable.  If so, we return that and end
    [p,n,e] = fileparts(inputData);

    % No extension, so check whether the mat-file exists
    if isempty(e), inputData = fullfile(p,[n,'.mat']); end
    if exist(inputData,'file')
        if strcmp(inputData((end-2):end),'mat')
            if ieVarInFile(inputData, 'scene'), load(inputData,'scene'); return; end
        end
    else, error('No file named %s\n',inputData);
    end
end


%% Determine the photons and illuminant structure

% We need to know the image type (rgb or multispectral).  Try to figure it
% out if it is not sent in
if notDefined('imType'), error('imType required.'); end
imType = ieParamFormat(imType);

switch lower(imType)
    case {'monochrome','rgb'}  % 'unispectral'
        % init display structure
        if notDefined('dispCal')
            warning('Default display is used to create scene');
            dispCal = displayCreate;
        end

        if ischar(dispCal), theDisplay = displayCreate(dispCal);
        elseif isstruct(dispCal) && isequal(dispCal.type, 'display')
            theDisplay = dispCal;
        else
            error('Bad display information.');
        end

        if exist('wList','var')
            theDisplay = displaySet(theDisplay,'wave',wList);
        end
        wave  = displayGet(theDisplay, 'wave');

        % get additional parameter values
        % if ~isempty(varargin), doSub = varargin{1}; else, doSub = false; end
        % if length(varargin) > 2, sz = varargin{3};  else, sz = []; end

        doSub = false; sz = [];

        % Get the scene spectral radiance using the display model
        photons = vcReadImage(inputData, imType, theDisplay, doSub, sz);

        % Match the display wavelength and the scene wavelength
        scene = sceneCreate('rgb');
        scene = sceneSet(scene, 'wave', wave);

        % This code handles both emissive and reflective displays.  The
        % white point is set a little differently.
        %
        % (a) For emissive display, set the illuminant SPD to the white
        % point of the display if ambient lighting is not set.
        % (b) For reflective display, the illuminant is required and should
        % be passed in in varargin{2}

        % Initialize the whole illuminant struct
        if isempty(illEnergy) 
            if ~displayGet(theDisplay, 'is emissive')
                % Reflective
                error('illuminant energy specification required for reflective display');
            else
                % Use the sum of the primaries
                illEnergy = sum(displayGet(theDisplay,'spd'),2);
            end
        end
        il = illuminantCreate('D65',wave);
        il = illuminantSet(il,'energy',illEnergy);

        % Compute photons for reflective display
        % For reflective display, until this step the photon variable
        % stores reflectance information
        if ~displayGet(theDisplay, 'is emissive')
            % The display is reflective, not emissive
            il_photons = illuminantGet(il, 'photons', wave);
            il_photons = reshape(il_photons, [1 1 length(wave)]);
            photons = bsxfun(@times, photons, il_photons);
        end

        % Set viewing distance
        scene = sceneSet(scene, 'distance', displayGet(theDisplay, 'distance'));

        % Set field of view
        %         if ischar(inputData), imgSz = size(imread(inputData), 2);
        %         else, imgSz = size(inputData, 2);
        %         end
        imgSz = size(photons,2);
        imgFov = imgSz * displayGet(theDisplay, 'deg per dot');
        scene  = sceneSet(scene, 'h fov', imgFov);
        scene  = sceneSet(scene,'distance',displayGet(theDisplay,'viewing distance'));

    case {'spectral','multispectral','hyperspectral'}
        if ~exist(inputData,'file'), error('Name of existing file required for multispectral'); end
        if notDefined('wList'), wList = []; end

        scene = sceneCreate('multispectral');

        % The illuminant structure has photon representation and a
        % standard Create/Get/Set group of functions.
        [photons, il, basis] = vcReadImage(inputData,imType,wList);

        % vcNewGraphWin; imageSPD(photons,basis.wave);

        % Override the default spectrum with the basis function
        % wavelength sampling.
        scene = sceneSet(scene,'wave',basis.wave);

        % Sometimes we store scene names in the file, too
        if ischar(inputData) && ieVarInFile(inputData,'name')
            load(inputData,'name')
            scene = sceneSet(scene,'name',name);
        end
    otherwise
        error('Unknown image type')
end

%% Put the remaining parameters in place and return

if ischar(inputData)
    scene = sceneSet(scene, 'filename', inputData);
else
    scene = sceneSet(scene,'filename','numerical');
end

scene = sceneSet(scene, 'photons', photons);
scene = sceneSet(scene, 'illuminant', il);

% Name the scene with the file name or just announce that we received rgb
% data.  
% Also, check whether the file contains 'fov' and 'dist' variables
% and adjust the scene, over-riding what we did, if they are there.
if ischar(inputData)
    [~, n, ~] = fileparts(inputData);  % This will be the name
    if strcmp(inputData((end-2):end),'mat') && ieVarInFile(inputData,'fov')
        load(inputData,'fov'); scene = sceneSet(scene,'fov',fov);
    end
    if strcmp(inputData((end-2):end),'mat') && ieVarInFile(inputData,'dist')
        load(inputData,'dist'), scene = sceneSet(scene,'distance',dist);
    end
else, n = 'rgb image';
end

if exist('theDisplay', 'var'), n = [n ' - ' displayGet(theDisplay, 'name')]; end
scene = sceneSet(scene,'name',n);

if ~notDefined('meanLuminance')
    % We have a value.
    scene = sceneAdjustLuminance(scene,meanLuminance); % Adjust mean
end

if scaleReflectance
    % Adjust illuminant level to a max reflectance 0.95. If the
    % reflectances are expected to be dark, set this to false.
    r = sceneGet(scene,'reflectance');
    maxR = max(r(:));    
    if maxR > 0.95
        illEnergy = sceneGet(scene,'illuminant energy');
        scene = sceneSet(scene,'illuminant energy',illEnergy*maxR);
    end
    disp('Adjusted illuminant level for max reflectance near 1.')
end

end

%{
function [c, ceq] = basisConstrainCreate(T, basis, imgXW)
% https://www.mathworks.com/matlabcentral/answers/102051-how-do-i-pass-additional-parameters-to-the-constraint-and-objective-functions-in-the-optimization-to
c = -basis * T * imgXW';
ceq = [];
end
%}

%{
        % read radiance / reflectance
        switch ieParamFormat(basisAlter)
            case 'none'
                photons = vcReadImage(I, imType, d, doSub, sz);
            case {'xyzmatch', 'xyznonneg', 'xyznonnegstrict'}
                % This is the case we want XYZ of image + basis could equal 
                % to XYZ of img convert from srgb to xyz space.
                % 
                % Get srgb2xyz matrix
                srgb2xyz = colorTransformMatrix('srgb2xyz');
                srgb2xyzCol = srgb2xyz';
                XYZcmf = double(ieReadSpectra('XYZEnergy.mat', wave));
                basisF = double(displayGet(d, 'spd primaries')); % basis
                if max(I(:)) > 1
                    I = im2double(I);
                end
                [Ixw, r, c] = RGB2XWFormat(I);
                XYZBasis = XYZcmf' * basisF;
                % For each pixel with p = [R, G, B], the XYZ value would be:
                % XYZval = srgb2xyz' * p'; where p is n x 3
                % The goal is to apply a T such that the mapped XYZ will match with sRGB
                % display:
                % XYZval =  XYZcmf' * basis * T * p'
                % So the goal is to make srgb2xyz' = T * XYZcmf' * basis, aka:
                % XYZcmf' * basis * T = srgb2xyz';
                T = pinv(XYZBasis) * srgb2xyzCol;
                % If current pixel values create negative values, apply a
                % ratio on three channels to make it nonnegative.
                if isequal(basisAlter, 'xyznonneg')
                    spectraRec = basisF * T * Ixw';
                    sumF = sum(basisF * T * [1, 1, 1]', 2);
                    ratio = spectraRec./sumF;
                    rMin = min(ratio(:));
                    if rMin < 0
                        Ixw = Ixw + abs(rMin) + 100 * eps;
                    end
                end
%{
                img = XW2RGBFormat(Ixw, r, c);
                ieNewGraphWin; imagesc(img);
                ieNewGraphWin; imagesc(I);
                spectraCheck = basisF * T * Ixw';
                tmp = min(spectraCheck', [], 2);
                res = find(tmp < 0);
                size(res)
%}
             I = XW2RGBFormat(Ixw * T', r, c);
             % spdCheck = primarySPD * T * Ixw'; min(spdCheck(:))
%{
                recXYZ = XW2RGBFormat((XYZcmf' * primarySPD * T * Ixw')', r, c);
                ieNewGraphWin; imagesc(recXYZ);
%}
             photonXW = Energy2Quanta(wave, (basisF * T * Ixw'))';
             photons = XW2RGBFormat(photonXW, r, c);
        end
%}
