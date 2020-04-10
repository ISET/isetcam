function txt = oiDescription(oi)
%Generate optical image text description for window
%
% Syntax
%   txt = oiDescription(oi,[handles])
%
% Description
%  Writes the OI description for the box on the upper right of the
%  window. Manages cases of diffraction-limited, shift-invariant, and
%  ray trace separately.
%
% Copyright ImagEval Consultants, LLC, 2003.

% if ieNotDefined('handles'), handles = ieSessionGet('oihandles'); end

txt = sprintf('\nOptical image\n');

if isempty(oi), txt = 'No image'; return;
else, sz = oiGet(oi,'size');
    if isempty(oiGet(oi,'photons')), txt = addText(txt,sprintf('  No image\n'));
    else
        str = sprintf('  Size:  [%.0f, %.0f] samples\n',sz(1),sz(2));
        txt = addText(txt,str);

        u = round(log10(oiGet(oi,'height','m')));
        if (u >= 0 ),     str = sprintf('  Hgt,wdth: [%.2f, %.2f] m\n',oiGet(oi,'height','m'),oiGet(oi,'width','m'));
        elseif (u >= -3), str = sprintf('  Hgt,wdth: [%.2f, %.2f] mm\n',oiGet(oi,'height','mm'),oiGet(oi,'width','mm'));
        else,             str = sprintf('  Hgt,wdth: [%.2f, %.2f] um\n',oiGet(oi,'height','um'),oiGet(oi,'width','um'));
        end
        txt = addText(txt,str);

        u = round(log10(oiGet(oi,'sampleSize')));
        if (u >= 0 ),     str = sprintf('  Sample: %.2f  m\n',oiGet(oi,'sampleSize','m'));
        elseif (u >= -3), str = sprintf('  Sample: %.2f mm\n',oiGet(oi,'sampleSize','mm'));
        else,             str = sprintf('  Sample: %.2f um\n',oiGet(oi,'sampleSize','um'));
        end
        txt = addText(txt,str);

        wave = oiGet(oi,'wave');
        spacing = oiGet(oi,'binwidth');
        str = sprintf('  Wave: %.0d:%.0d:%.0d nm\n',min(wave(:)),spacing,max(wave(:)));
        txt = addText(txt,str);

        meanIll = oiGet(oi,'meanilluminance');
        if ~isempty(meanIll)
            txt = addText(txt, sprintf('  Illum:   %.1f lux\n',meanIll));
        end
    end
end

% Write out the optics parameters, either DL, SI or RT
optics = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');

switch lower(opticsModel)
    case {'diffractionlimited','dlmtf'}
        txt = [txt, sprintf('Optics (DL)\n')];
        txt = [txt, sprintf('  Mag:  %.2e\n',opticsGet(optics,'magnification'))];
        diameter = opticsGet(optics,'aperture diameter','mm');
        txt = [txt, sprintf('  Diameter:  %.2f mm\n',diameter)];

    case {'skip'}
        txt = [txt, sprintf('Skip OTF\n')];
        % Not sure that we should have this when we skip the MTF - BW
        diameter = opticsGet(optics,'aperture diameter','mm');
        txt = [txt, sprintf('  Diameter:  %.2f mm\n',diameter)];
        
    case 'shiftinvariant'
        txt = [txt, sprintf('Optics (SI)\n')];
        % See above
        % txt = [txt, sprintf('  Mag:  %.2e\n',opticsGet(optics,'magnification'))];
        diameter = opticsGet(optics,'aperture diameter','mm');
        txt = [txt, sprintf('  Diameter:  %.2f mm\n',diameter)];
        
        fnumber = opticsGet(optics,'fnumber');
        txt = [txt, sprintf('  F/#:  %.2f mm\n',fnumber)];

    case 'raytrace'
        txt = [txt, sprintf('Optics (RT)\n')];
        name = opticsGet(optics,'rtname');
        if isempty(name)
            lensFile = opticsGet(optics,'lensfile');
            if ~isempty(lensFile), [~,name,~] = fileparts(lensFile);
            else, name = 'None';
            end
        end
        txt = addText(txt,sprintf('  Name:   %s\n',name));

        rtFOV = opticsGet(optics,'rtfov');
        if isempty(rtFOV), rtFOV = 0; end
        txt = addText(txt,sprintf('  Fov: %.0f deg\n',rtFOV));
        m = opticsGet(optics,'rtmagnification');
        if isempty(m), m = 0; end
        txt = [txt, sprintf('  Mag:      %.2e\n',m)];

        efl = opticsGet(optics,'rtEffectiveFocalLength','mm');
        if isempty(efl), efl = 0; end
        txt = [txt, sprintf('  Foc length: %.1f mm\n',efl)];

        efn = opticsGet(optics,'rtEffectiveFnumber');
        if isempty(efn), efn = 0; end
        txt = [txt, sprintf('  Eff. f/#:      %.1f\n',efn)];

        if efn ~= 0
            % diameter = opticsGet(optics,'diameter','mm');
            txt = [txt, sprintf('  Diameter:  %.2f mm\n',efl/efn)];
        end
        
    case 'iset3d'
        txt = [txt, sprintf('Optics (iset3d)\n')];
        name = opticsGet(optics,'name');
        txt = addText(txt,sprintf('  Name:   %s\n',name));

        diameter = opticsGet(optics,'aperture diameter','mm');
        txt = [txt, sprintf('  Diameter:  %.2f mm\n',diameter)];
        if checkfields(oi,'optics','lens')
            d = oiGet(oi,'lens density');
            txt = [txt, sprintf('  Lens density:  %.2f \n',d)];
        end
        
        %     case 'usersupplied'
        %         txt = [txt, sprintf('Optics (User)\n')];
        
    otherwise
        error('Unknown optics model %s. ',opticsModel);
end

return;