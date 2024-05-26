function il = illuminantSet(il,param,val,varargin)
% Set parameter value for illuminant structure
%
%   il = illuminantSet(il,param,val,varargin)
%
% The illuminant structure has two formats.
%
% It can be a simple vector, which defines an SPD for the entire image.  It
% can also be an RGB format spectral data set that has a separate
% illuminant SPD at every point. We refer to this as a 'spatial-spectral'
% illuminant.
%
% Parameters
%
% (c) Imageval Consulting, LLC, 2012
%
% See also:  illuminantCreate, illuminantGet
%

% Examples:
%{
il = illuminantCreate;    % Creates the illuminant structure, no data
il = illuminantSet(il,'name','outdoor');
photons = illuminantGet(il,'photons');
tmp = illuminantSet(il,'photons',photons);
wave = illuminantGet(il,'wave');
tmp = illuminantSet(il,'wave',wave(1:2:end));
energy = illuminantGet(il,'energy');
tmp = illuminantSet(il,'energy',energy);
%}

%% Parameter checking

if ~exist('il','var') || isempty(il), error('illuminant structure required'); end
if ~exist('param','var') || isempty(param), error('param required'); end
if ~exist('val','var') , error('val is required'); end

%%
param = ieParamFormat(param);
switch param
    case 'name'
        il.name = val;
    case 'type'
        if ~strcmpi(val,'illuminant'), error('Type must be illuminant'); end
        il.type = val;
    case 'photons'
        % il = illuminantSet(il,'photons',data);
        % Use single precision because we may have an illuminant that is
        % spectral spatial.
        il.data.photons = single(val);

    case 'energy'
        % User sent in energy.  We convert to photons and set.
        % We need to handle the spatial spectral case properly.
        % See s_sceneIlluminantSpace
        wave = illuminantGet(il,'wave');
        if ndims(val) > 2 %#ok<ISMAT>
            [val,r,c] = RGB2XWFormat(val);
            val = Energy2Quanta(wave,val')';
            val = XW2RGBFormat(val,r,c);
            il = illuminantSet(il,'photons',val);
        else
            % For set of a vector to be a column vector
            il = illuminantSet(il,'photons',Energy2Quanta(wave,val(:)));
        end
    case {'wave','wavelength'}
        % il = illuminantSet(il,'wave',wave)
        %
        % Interpolate the illuminant photons
        oldW = illuminantGet(il,'wave');
        newW = val(:);
        if isequal(newW(:),oldW(:))
            % Nothing to interpolate
            return;
        end

        il.spectrum.wave = newW;
        photons = illuminantGet(il,'photons');
        if ~isempty(photons)
            if isvector(photons)
                % Interpolate the spectral illuminant vector
                %
                if length(photons) == length(newW)
                    % If p has the same length as newW, let's assume it
                    % was already changed by the user.  This must have
                    % been put here a long time ago.  Might not be
                    % needed any more.
                    disp('Illuminant photons appear to have been changed already.')
                elseif length(photons) == length(oldW)
                    % Adjust the sampling.  We know how.
                    photons = interp1(oldW,photons,newW,'linear',min(photons(:)*1e-3)');
                    il = illuminantSet(il,'photons',photons);
                end
            elseif ndims(photons) == 3
                % Interpolate the spatial-spectral illuminant
                %
                % Unlike the case below, we always interpolate.  Same
                % method as sceneInterpolateW.
                row = size(photons,1); col = size(photons,2);
                photons = interp1(oldW,RGB2XWFormat(photons)',newW, 'linear')';
                photons = XW2RGBFormat(photons,row,col);
                il = illuminantSet(il,'photons',photons);
            else    
                % Confused.
                error('Photons and wavelength sample points not interpretable');
            end           
        else
            disp('No illuminant photons.  Should not happen.');
        end

    case 'comment'
        il.comment = val;
    otherwise
        error('Unknown illuminant parameter %s\n',param)
end

end
