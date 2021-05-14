function il = illuminantModernize(illuminant)
% Convert old format illuminant structures to the modern format
%
%   illuminant = illuminantModernize(illuminant)
%
% If the structure is already modern, just return.  We test modern by
% whether it has a 'type','data.min',and 'data.max' field.
%
% The old format had these fields:
%
%           data: [31x1 double]  (energy units)
%     wavelength: [1x31 double]
%
% There were some other old formats that had
%          data.photons
%
% If the illuminant has these string fields, they will be copied too.
%
%        comment:
%        name:
%
% We use spd2cct to name the illuminant.
%
% (c) Imageval Consulting, LLC 2012

if isfield(illuminant,'type') && ...
        ~checkfields(illuminant,'data','min') && ...
        ~checkfields(illuminant,'data','max')
    % Has a type and no min/max in data.
    % Must be modern.
    il = illuminant;
    return;
else
    if ~isfield(illuminant,'data')
        error('No illuminant data ');
    end
    if ~isfield(illuminant,'wavelength')
        if isfield(illuminant.spectrum,'wave')
            illuminant.wavelength = illuminant.spectrum.wave;
        else
            error('No wavelength or spectrum.wavelength slot');
        end
    end
    
    % Build
    il = illuminantCreate;
    il = illuminantSet(il,'wavelength',illuminant.wavelength);
    
    % The data are a mess in older versions.  Sometimes they are in
    % il.data.photons and sometimes just in il.data.  We handle both cases
    % here.
    if isfield(illuminant.data,'photons')
        il = illuminantSet(il,'energy',double(illuminant.data.photons));
    elseif isnumeric(illuminant.data)
        il = illuminantSet(il,'energy',double(illuminant.data));
    end
    
    
    if isfield(illuminant,'name')
        il = illuminantSet(il,'name',illuminant.name);
    else
        % This is a good way to name an unknown illuminant.  Find its
        % correlated color temperature and name it that.
        w = illuminantGet(il,'wave');
        spd = illuminantGet(il,'energy');
        cct = spd2cct(w,spd);
        il = illuminantSet(il,'name',sprintf('CCT %.0f',cct));
    end
    
    if isfield(illuminant,'comment'),
        il = illuminantSet(il,'comment',illuminant.comment);
    end
end

end
