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
%
% See also:  illuminantCreate, illuminantGet
%
% Examples:
%   il = illuminantCreate;    % Creates the illuminant structure, no data
%   il = illuminantSet(il,'name','outdoor');
%   il = illuminantSet(il,'photons', photons);
%  or
%   il = illuminantSet(il,'energy',e);  % Converts to energy for you
%
% (c) Imageval Consulting, LLC, 2012

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
        % Need to interpolate data sets and reset when wave is adjusted.
        % We aren't handling spatial-spectral here properly.
        
        oldW = illuminantGet(il,'wave');
        newW = val(:);
        il.spectrum.wave = newW;
        if isequal(newW(:),oldW(:))
            % Nothing to interpolate
            return;
        end

        switch ndims(il.data.photons)
            case 3
                % Interpolate the spatial-spectral illuminant
                % Have a look at sceneInterpolateW for how to do this.
                error('Spatial spectral illuminant interpolation.  Write it.');
            case 1
                % Interpolate the spectral vector for the illuminant
                % photons.
                p = illuminantGet(il,'photons');
                if ~isempty(p)
                    % We need to handle the spatial spectral and purely
                    % spectral cases differently here.  This can break
                    % sceneFromFile when we set the wavelength and we need to
                    % interpolate.
                    %
                    % If p has the same length as newW, let's assume it was already
                    % changed.  Otherwise, if it has the length of oldW, we should
                    % try to interpolate it.
                    if length(p) == length(newW)
                        % Sample length of photons already equal to newW.  No
                        % problem.
                    elseif length(p) == length(oldW)
                        % Adjust the sampling.
                        newP = interp1(oldW,p,newW,'linear',min(p(:)*1e-3)');
                        il = illuminantSet(il,'photons',newP);
                    else
                        error('Photons and wavelength sample points not interpretable');
                    end
                    % vcNewGraphWin; plot(newW,newP);                    
                end
            otherwise
                error('Unknown illuminant photon dimensionality.');        
        end
    case 'comment'
        il.comment = val;
    otherwise
        error('Unknown illuminant parameter %s\n',param)
end

end
