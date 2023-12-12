function scene = sceneVernier(scene, type, params)
% scene for vernier acuity
%
% Syntax:
%   scene = sceneVernier(scene, [type], [params])
%
% Description:
%    Create a scene for vernier activity. There are a selection of default
%    values for params if none are supplied, they can be scene below.
%
%    There are examples located in the code below. To access, type 'edit
%    sceneVernier.m' into the Command Window.
%
% Inputs:
%    scene  - The scene structure
%    type   - (Optional) The type of scene. Default 'display'. Options are
%             'display' and 'object'.
%        'display' - scene is created from an image on display
%        'object'  - scene is created from the object structure which
%                    contains specific parameters.  
%    params - (Optional) A structure containing the Vernier parameters. The
%             parameters, based on scene type, and their defaults are
%             listed below:
%        General (regardless of type):
%            sceneSz    - Scene resolution. Default 64.
%            barWidth   - Bar width in pixels. Default 1.
%            offset     - Displacement in pixels. Default 1.
%            meanLum    - Mean luminance. Default is pulled from scene.
%        Display
%            lineSpace  - Spacing between the lines in pixels. 
%            display    - Display name or structure. Default 'LCD-Apple'.
%            barLength  - Length of the line segment in number of pixels.
%            barColor   - Bar color, 0~1 RGB value. Default from the
%                         default displayCreate configuration.
%            bgColor    - Background color, 0~1 RGB. Default from the
%                         default displayCreate configuration.
%        Object
%            il         - Illuminance. Default 'equal photons'.
%            barReflect - Bar reflectance. Default 0.6.
%            bgReflect  - Background reflectance. Default 0.3.
%
% Outputs:
%    scene  - The modified scene structure
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * [Note: JNM - lineSpace isn't referenced in this function or in
%      displayCreate. Should it be left here? I don't know its default
%      value or anything aside from the already-provided text about it.]

% History:
%    xx/xx/xx  HJ   Created
%    02/01/18  jnm  Formatting

% Examples:
%{
    clear p;
    p.sceneSz = 64;
    p.barWidth = 5;
    p.offset = 3;
    p.meanLum = 10;
    p.lineSpace = 1;
    p.barColor = [1 0.5 0.5];
    p.bgColor = [0 0 0];
    s = sceneCreate('vernier', 'display', p);
    vcAddObject(s);
    sceneWindow;
%}

% check inputs
if notDefined('scene'), error('scene requried'); end
if notDefined('type'), type = 'display'; end

% init parameters from params
if isfield(params, 'sceneSz'), sz = params.sceneSz; else, sz = 64; end
if isfield(params, 'barWidth')
    width = params.barWidth;
else
    width = 1;
end
if isfield(params, 'offset'), offset = params.offset; else, offset = 1; end

% Set scene parameters based on type
switch type
    case 'object'
        % Init bar and background reflectance parameter
        if isfield(params, 'barReflect')
            lineReflectance = params.barReflect;
        else
            lineReflectance = 0.6;
        end
        
        if isfield(params, 'bgReflect')
            backReflectance = params.bgReflect;
        else
            backReflectance = 0.3;
        end
        
        scene = sceneSet(scene, 'name', sprintf('vernier-%d', offset));
        
        %% We make the image square
        if isscalar(sz), r = sz; c = sz; else, r = sz(1); c = sz(2); end
        
        % Make the column number odd so we can really center the top line
        if ~isodd(c), c = c + 1; end
        
        % Vernier line size and offset
        % Top and bottom half rows and columns
        % Columns containing top line, shifted offset/2
        topCols = (1:width) + round((c - width) / 2) - floor(offset / 2);
        
        % Columns containing bottom line, shifted offset from top columns
        % With this algorithm, the width of the
        botCols = topCols + offset;
        
        % Split the rows, too
        topHalf = round(r / 2);
        topRows = 1:topHalf;
        botRows = (topHalf + 1):r;
        
        %% Init spectrum
        if ~isfield(scene, 'spectrum')
            scene = initDefaultSpectrum(scene, 'hyperspectral');
        end
        wave = sceneGet(scene, 'wave');
        nWave = sceneGet(scene, 'nwave');
        
        %% Make the photon data
        if isfield(params, 'il')
            il = params.il;
        else
            il = illuminantCreate('equal photons', wave);
        end
        scene = sceneSet(scene, 'illuminant', il);
        illP = sceneGet(scene, 'illuminant photons');
        
        photons = ones(r, c, nWave);
        for ii = 1 : nWave
            topBar = lineReflectance * illP(ii) * ...
                photons(topRows, topCols, ii);
            botBar = lineReflectance * illP(ii) * ...
                photons(botRows, botCols, ii);
            photons(:, :, ii) = backReflectance * ...
                photons(:, :, ii) * illP(ii);
            photons(topRows, topCols, ii) = topBar;
            photons(botRows, botCols, ii) = botBar;
        end
        
        scene = sceneSet(scene, 'photons', photons);
    case 'display'
        % Init related parameters
        if isfield(params, 'display')
            display = params.display;
        else
            display = displayCreate('LCD-Apple');
        end
        if ischar(display), display = displayCreate(display); end
        
        Img = imageVernier(params);
        
        % Create scene from the RGB data
        scene = sceneFromFile(Img, 'rgb', [], display);
        
    otherwise
        error('unknown vernier scene type');
end

if isfield(params, 'meanLum') && ~isempty(params.meanLum)
    scene = sceneAdjustLuminance(scene, params.meanLum);
end

end