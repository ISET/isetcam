function [scene,I] = sceneFromFile(I, imType, meanLuminance, dispCal, ...
    wList, basisAlter, varargin)
% Create an ISETCam scene structure by reading data from a file
%
% Synopsis:
%
%   [scene, I] = sceneFromFile(imageData, imageType, [meanLuminance], ...
%                     [display], [wave], [doSub], [ambient], [oSample])
%
% Inputs:
%  imageData: Typically, this is the name of an RGB image file.  But, it
%             may also be
%              * RGB data, rather than the file name
%              * A file that contains a scene structure
%  imageType: 'multispectral' or 'rgb' or 'monochrome'
%              When 'rgb', the imageData might be RGB format.
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
%
% Returns;
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
%}
%{
   [scene,fname] = sceneFromFile;
%}
%{
   fullFileName = vcSelectImage;
   imgType = ieImageType(fullFileName);
   scene = sceneFromFile(fullFileName,imgType);
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
   wList = 400:100:700;
   scene = sceneFromFile(imread(fName),'rgb',100,dispCal,wList);
   sceneWindow(scene);
%}
%{
  meanLuminance= 10;
  thisDisplay = displayCreate;
  h = harmonicP('row',2048,'col',2048);
  img = imageHarmonic(h);
  img = floor(ieScale(img,0,255));
  tic
  scene = sceneFromFile(img,'monochrome',meanLuminance,thisDisplay,600);
  toc
%}

%% Parameter set up

if notDefined('I')
    % If imageData is not sent in, we ask the user for a filename.
    % The user may or may not have set the imageType.  Sigh.
    if notDefined('imType'), [I,imType] = vcSelectImage;
    else, I = vcSelectImage(imType);
    end
    if isempty(I), scene = []; return; end
end

if ischar(I)
    % I is a file name.  We determine whether it is a Matlab file and
    % contains a scene variable.  If so, we return that and end
    [p,n,e] = fileparts(I);
    
    % No extension, so check whether the mat-file exists
    if isempty(e), I = fullfile(p,[n,'.mat']); end
    if exist(I,'file')
        if strcmp(I((end-2):end),'mat')
            if ieVarInFile(I, 'scene'), load(I,'scene'); return; end
        end
    else, error('No file named %s\n',I);
    end
end

% Newly added basisalter
if notDefined('basisAlter')
    basisAlter = 'none';
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
        
        if ischar(dispCal), d = displayCreate(dispCal);
        elseif isstruct(dispCal) && isequal(dispCal.type, 'display')
            d = dispCal;
        else
            error('Bad display information.');
        end
        
        if exist('wList','var')
            d = displaySet(d,'wave',wList);
        end
        wave  = displayGet(d, 'wave');
        
        % get additional parameter values
        if ~isempty(varargin), doSub = varargin{1}; else, doSub = false; end
        if length(varargin) > 2, sz = varargin{3};  else, sz = []; end
        
        % read radiance / reflectance
        switch ieParamFormat(basisAlter)
            case 'none'
                photons = vcReadImage(I, imType, d, doSub, sz);
            case {'xyzmatch', 'xyznonneg', 'xyznonnegstrict'}
                % This is the case we want XYZ of image + basis could equal 
                % to XYZ of img convert from srgb to xyz space.
                % 
                srgb2xyz = colorTransformMatrix('srgb2xyz');
                XYZcmf = ieReadSpectra('XYZEnergy.mat', wave);
                primarySPD = displayGet(d, 'spd primaries'); % basis
                if max(I(:)) > 1
                    I = im2double(I);
                end
                [Ixw, r, c] = RGB2XWFormat(I);
                XYZBasis = XYZcmf' * primarySPD;
                if isequal(basisAlter, 'xyzmatch')
                    T = pinv(XYZBasis) * srgb2xyz;
                elseif isequal(basisAlter, 'xyznonnegstrict')
                    % XYZBasis = XYZcmf' * primarySPD;
                    T = zeros(size(primarySPD, 2), size(Ixw, 2));
                    for ii = 1:size(Ixw, 2)
                        T(:,ii) = lsqlin(XYZBasis, srgb2xyz(:,ii), -primarySPD,...
                                        zeros(size(primarySPD, 1), 1));
                    end
                elseif isequal(basisAlter, 'xyznonneg')
                    % XYZBasis = XYZcmf' * primarySPD;
                    % Downsample the image to size (32, 32, 3) for okay
                    % speed. Since the image should be blurred, hope the
                    % downsample won't hurt too much.
                    Ids = imresize(I, [32, 32]);
                    Idsxw = RGB2XWFormat(Ids);
                    T0 = pinv(XYZBasis) * srgb2xyz;
                    fun = @(T)sum((XYZBasis * T - srgb2xyz).^2, 'all');
                    nonlcon = @(Tsol)basisConstrainCreate(Tsol, primarySPD, double(Idsxw));
                    [T, ~] = fmincon(fun, T0, [], [], [], [], [], [], nonlcon);
                end
                
             I = XW2RGBFormat(Ixw * T', r, c);
             % spdCheck = primarySPD * T * Ixw'; min(spdCheck(:))
             %{ 
                recXYZ = XW2RGBFormat((XYZcmf' * primarySPD * T * Ixw')', r, c);
                ieNewGraphWin; imagesc(recXYZ);
             %}
        end
        
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
        
        if length(varargin) > 1, il = varargin{2}; else, il = []; end
        
        % Initialize
        if isempty(il) && ~displayGet(d, 'is emissive')
            error('illuminant required for reflective display');
        end
        if isempty(il)
            il    = illuminantCreate('d65', wave);
            % Replace default with display white point SPD
            il    = illuminantSet(il, 'energy', sum(displayGet(d,'spd'),2));
        end
        scene = sceneSet(scene, 'illuminant', il);
        
        % Compute photons for reflective display
        % For reflective display, until this step the photon variable
        % stores reflectance information
        if ~displayGet(d, 'is emissive')
            il_photons = illuminantGet(il, 'photons', wave);
            il_photons = reshape(il_photons, [1 1 length(wave)]);
            photons = bsxfun(@times, photons, il_photons);
        end
        
        % Set viewing distance
        scene = sceneSet(scene, 'distance', displayGet(d, 'distance'));
        
        % Set field of view
        if ischar(I), imgSz = size(imread(I), 2);
        else, imgSz = size(I, 2);
        end
        imgFov = imgSz * displayGet(d, 'deg per dot');
        scene  = sceneSet(scene, 'h fov', imgFov);
        scene  = sceneSet(scene,'distance',displayGet(d,'viewing distance'));
        
    case {'multispectral','hyperspectral'}
        if ~exist(I,'file'), error('Name of existing file required for multispectral'); end
        if notDefined('wList'), wList = []; end
        
        scene = sceneCreate('multispectral');
        
        % The illuminant structure has photon representation and a
        % standard Create/Get/Set group of functions.
        [photons, il, basis] = vcReadImage(I,imType,wList);
        
        % vcNewGraphWin; imageSPD(photons,basis.wave);
        
        % Override the default spectrum with the basis function
        % wavelength sampling.
        scene = sceneSet(scene,'wave',basis.wave);
        
        % Sometimes we store scene names in the file, too
        if ischar(I) && ieVarInFile(I,'name')
            load(I,'name')
            scene = sceneSet(scene,'name',name);
        end
    otherwise
        error('Unknown image type')
end

%% Put all the parameters in place and return
%{
if ieSessionGet('gpu compute')
    photons = gpuArray(photons);
end
%}

if ischar(I)
    scene = sceneSet(scene, 'filename', I);
else
    scene = sceneSet(scene,'filename','numerical');
end

scene = sceneSet(scene, 'photons', photons);
scene = sceneSet(scene, 'illuminant', il);

% Name the scene with the file name or just announce that we received rgb
% data.  Also, check whether the file contains 'fov' and 'dist' variables
% and stick them into the scene if they are there
if ischar(I)
    [~, n, ~] = fileparts(I);  % This will be the name
    if strcmp(I((end-2):end),'mat') && ieVarInFile(I,'fov')
        load(I,'fov'); scene = sceneSet(scene,'fov',fov);
    end
    if strcmp(I((end-2):end),'mat') && ieVarInFile(I,'dist')
        load(I,'dist'), scene = sceneSet(scene,'distance',dist);
    end
else, n = 'rgb image';
end

if exist('d', 'var'), n = [n ' - ' displayGet(d, 'name')]; end
scene = sceneSet(scene,'name',n);

if ~notDefined('meanLuminance')
    scene = sceneAdjustLuminance(scene,meanLuminance); % Adjust mean
end

if ~notDefined('wList')
    % I think the scene should match wList by this time.
    if ~isequal(wList,sceneGet(scene,'wave'))
        scene = sceneSet(scene, 'wave', wList);
    end
end

end

function [c, ceq] = basisConstrainCreate(T, basis, imgXW)
% https://www.mathworks.com/matlabcentral/answers/102051-how-do-i-pass-additional-parameters-to-the-constraint-and-objective-functions-in-the-optimization-to
c = -basis * T * imgXW';
ceq = [];
end